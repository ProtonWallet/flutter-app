import 'dart:async';

import 'package:cryptography/cryptography.dart';
import 'package:sentry/sentry.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/helper/walletkey_helper.dart';
import 'package:wallet/managers/app.state.manager.dart';
import 'package:wallet/managers/manager.dart';
import 'package:wallet/managers/preferences/preferences.manager.dart';
import 'package:wallet/managers/providers/connectivity.provider.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/providers/models/wallet.key.dart';
import 'package:wallet/managers/services/exchange.rate.service.dart';
import 'package:wallet/managers/services/service.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/rust/api/bdk_wallet/account.dart';
import 'package:wallet/rust/api/proton_api.dart' as proton_api;
import 'package:wallet/rust/common/errors.dart';
import 'package:wallet/rust/proton_api/event_routes.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/rust/proton_api/wallet.dart';
import 'package:wallet/rust/proton_api/wallet_account.dart';
import 'package:wallet/rust/proton_api/wallet_settings.dart';

typedef RecoveryCallback = Future<void> Function(List<LoadingTask> failedTask);

// TODO(fix): handle user and settings event.
class EventLoop extends Service implements Manager {
  final UserManager userManager;
  final DataProviderManager dataProviderManager;
  final AppStateManager appStateManager;
  final ConnectivityProvider connectivityProvider;

  // workaround need to improve this
  final PreferencesManager shared;
  String latestEventId = "";
  int internetCheckCounter = 0;
  int recoveryCheckCounter = 0;
  late RecoveryCallback? onRecovery;

  ///
  StreamSubscription? connectivitySub;

  EventLoop(
    this.userManager,
    this.dataProviderManager,
    this.appStateManager,
    this.connectivityProvider,
    this.shared, {
    required super.duration,
  });

  @override
  Future<void> start() async {
    connectivitySub ??= connectivityProvider.stream.listen((state) {
      if (state is ConnectivityUpdated) {
        if (onUpdateing) {
          // because of the muon timout can't detect internet drop or not. we can improve this logic later
          Future.delayed(const Duration(seconds: 5), onUpdate);
        } else {
          onUpdate();
        }
      }
    });
    super.start();
  }

  void setRecoveryCallback(RecoveryCallback onRecovery) {
    this.onRecovery = onRecovery;
  }

  @override
  Future<Duration?> onUpdate() async {
    // because of the muon timout can't detect internet drop or not.
    // other wise we can check updating to drop multiple triggters.
    onUpdateing = true;

    /// check if app state is no connectivity
    if (!appStateManager.isConnectivityOK) {
      ///recheck connectivity
      final result = await connectivityProvider.hasConnectivity();

      /// if tried 6 times then try to hit server
      if (result || internetCheckCounter > 6) {
        /// try event loop
        internetCheckCounter = 0;
        checkRecovery = true;
      } else {
        /// fall back timmer. [6 times] * [10 seconds] = 1 minute
        internetCheckCounter++;
        return const Duration(seconds: 10);
      }
    }

    if (!appStateManager.isHomeInitialed) {
      // recover from internet or server error
      if (appStateManager.failedTask.isNotEmpty) {
        await stateRecovery(appStateManager.failedTask);
      }

      await stateRecovery([LoadingTask.homeRecheck]);
      // check if internet is available
    } else {
      if (appStateManager.failedTask.isNotEmpty) {
        await stateRecovery(appStateManager.failedTask);
      }
      if (checkRecovery) {
        checkRecovery = false;
        await stateRecovery([LoadingTask.homeRecheck]);
      }
      final count =
          await shared.read("proton_wallet_app_k_sync_error_count") ?? 0;
      if (count > 0) {
        await stateRecovery([LoadingTask.syncRecheck]);
      }

      ///
      if (latestEventId.isEmpty) {
        await fetchEventID();
      }

      if (latestEventId.isNotEmpty) {
        await fetchEvents();
      }

      await sidePollingTask();

      onUpdateing = false;
    }

    final nextWaiting = await appStateManager.getEventloopDuration();
    return Duration(seconds: nextWaiting);
  }

  Future<void> stateRecovery(List<LoadingTask> tasks) async {
    try {
      if (onRecovery != null) {
        await onRecovery?.call(tasks);
      }
    } on BridgeError catch (e, stacktrace) {
      appStateManager.updateStateFrom(e);
      logger.e("Event Loop error: $e stacktrace: $stacktrace");
      recoveryCheckCounter++;
    } catch (e, stacktrace) {
      logger.e("Event Loop error: $e stacktrace: $stacktrace");
      recoveryCheckCounter++;
    }
  }

  Future<void> fetchEventID() async {
    try {
      final String? savedLatestEventId = await WalletManager.getLatestEventId();
      latestEventId = savedLatestEventId ?? await proton_api.getLatestEventId();
    } on BridgeError catch (e, stacktrace) {
      appStateManager.updateStateFrom(e);
      logger.e("Event Loop error: $e stacktrace: $stacktrace");
      Sentry.captureException(e, stackTrace: stacktrace);
    } catch (e, stacktrace) {
      logger.e("Event Loop error: $e stacktrace: $stacktrace");
      Sentry.captureException(e, stackTrace: stacktrace);
    }
  }

  Future<void> fetchEvents() async {
    logger.i("event loop runOnce()");
    final Map<String, List<ApiWalletKey>> walletID2ProtonWalletKey = {};
    try {
      final events =
          await proton_api.collectEvents(latestEventId: latestEventId);
      for (ProtonEvent event in events) {
        if (event.walletKeyEvents != null) {
          for (WalletKeyEvent walletKeyEvent in event.walletKeyEvents!) {
            final ApiWalletKey? walletKey = walletKeyEvent.walletKey;
            if (walletKey != null) {
              final String serverWalletID = walletKey.walletId;
              if (!walletID2ProtonWalletKey.containsKey(serverWalletID)) {
                walletID2ProtonWalletKey[serverWalletID] = [];
              }
              walletID2ProtonWalletKey[serverWalletID]!.add(walletKey);

              await WalletManager.setWalletKey([walletKey]);
            }
          }
        }
        if (event.walletEvents != null) {
          for (WalletEvent walletEvent in event.walletEvents!) {
            if (walletEvent.action == 0) {
              final String serverWalletID = walletEvent.id;
              await dataProviderManager.walletDataProvider
                  .deleteWalletByServerID(
                serverWalletID,
              ); // Will also delete account
              continue;
            }
            final ApiWallet? walletData = walletEvent.wallet;

            if (walletData != null) {
              SecretKey? secretKey;
              final String walletID = walletData.id;
              if (walletID2ProtonWalletKey.containsKey(walletID)) {
                for (ApiWalletKey? apiWalletKey
                    in walletID2ProtonWalletKey[walletID]!) {
                  try {
                    if (apiWalletKey == null) {
                      continue;
                    }
                    final WalletKey walletKey = WalletKey.fromApiWalletKey(
                      apiWalletKey,
                    );
                    final userKey =
                        await userManager.getUserKey(walletKey.userKeyId);

                    secretKey = WalletKeyHelper.decryptWalletKey(
                      userKey,
                      walletKey,
                    );

                    // TODO(fix): fix me use it
                    final bool isValidWalletKeySignature =
                        await WalletKeyHelper.verifySecretKeySignature(
                      userKey,
                      walletKey,
                      secretKey,
                    );
                    logger.i(
                      "isValidWalletKeySignature = $isValidWalletKeySignature",
                    );
                    break;
                  } catch (e) {
                    continue;
                  }
                }
              }
              const int status = WalletModel.statusActive;
              await dataProviderManager.walletDataProvider.insertOrUpdateWallet(
                userID: userManager.userID,
                name: walletData.name,
                encryptedMnemonic: walletData.mnemonic!,
                passphrase: walletData.hasPassphrase,
                imported: walletData.isImported,
                priority: walletData.priority,
                status: status,
                type: walletData.type,
                fingerprint: walletData.fingerprint ?? "",
                walletID: walletID,
                publickey: null,
                showWalletRecovery: walletData.isImported == 0 ? 1 : 0,
              );
            }
          }
        }
        if (event.walletAccountEvents != null) {
          for (final walletAccountEvent in event.walletAccountEvents!) {
            if (walletAccountEvent.action == 0) {
              final String serverAccountID = walletAccountEvent.id;
              await dataProviderManager.walletDataProvider
                  .deleteWalletAccountByServerID(serverAccountID);
              continue;
            }
            final ApiWalletAccount? account = walletAccountEvent.walletAccount;
            if (account != null) {
              await dataProviderManager.walletDataProvider
                  .insertOrUpdateAccount(
                account.walletId,
                account.label,
                account.scriptType,
                account.derivationPath,
                account.id,
                account.fiatCurrency,
                account.poolSize,
                account.priority,
                account.lastUsedIndex,
              );
            }
          }
        }
        if (event.walletSettingEvents != null) {
          for (final walletSettingEvent in event.walletSettingEvents!) {
            final ApiWalletSettings? _ = walletSettingEvent.walletSettings;
          }
        }
        if (event.walletUserSettings != null) {
          final ApiWalletUserSettings settings = event.walletUserSettings!;
          await dataProviderManager.userSettingsDataProvider
              .insertUpdate(settings);
        }
        if (event.walletTransactionEvents != null) {
          for (final walletTransactionEvent in event.walletTransactionEvents!) {
            final WalletTransaction? walletTransaction =
                walletTransactionEvent.walletTransaction;
            final WalletModel? walletModel = await DBHelper.walletDao!
                .findByServerID(walletTransaction!.walletId);
            if (walletModel == null) {
              logger.e("message: walletModel is null");
              continue;
            }
            await dataProviderManager.serverTransactionDataProvider
                .handleWalletTransaction(
              walletTransaction,
              notifyDataUpdate: true,
            );
          }
        }

        if (event.contactEmailEvents != null) {
          bool hasAction = false;
          for (final contactEvent in event.contactEmailEvents!) {
            if (contactEvent.action == 0) {
              final String contactID = contactEvent.id;
              await dataProviderManager.contactsDataProvider.delete(contactID);
              hasAction = true;
              continue;
            }
            final mail = contactEvent.contactEmail;
            if (mail != null) {
              await dataProviderManager.contactsDataProvider.insertUpdate(mail);
              hasAction = true;
            }
          }
          if (hasAction) {
            await dataProviderManager.contactsDataProvider.reloadCache();
          }
        }

        /// update event id
        latestEventId = event.eventId;
        await WalletManager.setLatestEventId(latestEventId);
      }
      await appStateManager.resetEventloopDuration();
      appStateManager.isConnectivityOK = true;
    } on BridgeError catch (e, stacktrace) {
      appStateManager.updateStateFrom(e);
      logger.e("Event Loop error: $e stacktrace: $stacktrace");
      Sentry.captureException(e, stackTrace: stacktrace);
    } catch (e, stacktrace) {
      logger.e("Event Loop error: $e stacktrace: $stacktrace");
      Sentry.captureException(e, stackTrace: stacktrace);
    }
  }

  Future<void> sidePollingTask() async {
    try {
      /// handlie bitcoin address
      await handleBitcoinAddress();

      /// check block height
      await dataProviderManager.blockInfoDataProvider.syncBlockHeight();

      /// move this to service
      await ExchangeRateService.runOnce(
        dataProviderManager.userSettingsDataProvider.fiatCurrency,
      );

      /// get exchange rate
      final exchangeRate = await ExchangeRateService.getExchangeRate(
        dataProviderManager.userSettingsDataProvider.fiatCurrency,
      );

      /// update exchange rate
      dataProviderManager.userSettingsDataProvider.updateExchangeRate(
        exchangeRate,
      );
    } catch (e, stacktrace) {
      logger.e("polling error: $e stacktrace: $stacktrace");
    }
  }

  // TODO(fix): fix me handle the !
  Future<void> handleBitcoinAddress() async {
    final userID = userManager.userInfo.userId;
    final walletModels = await DBHelper.walletDao!.findAllByUserID(userID);
    for (WalletModel walletModel in walletModels) {
      final accountModels =
          await DBHelper.accountDao!.findAllByWalletID(walletModel.walletID);
      for (final accountModel in accountModels) {
        final FrbAccount? account = await WalletManager.loadWalletWithID(
          walletModel.walletID,
          accountModel.accountID,
          serverScriptType: accountModel.scriptType,
        );

        /// resync the email address in case that user update it on web
        /// and mobile didn't get event loop yet
        await dataProviderManager.walletDataProvider.syncEmailAddresses(
          walletModel.walletID,
          accountModel.accountID,
        );
        final accountAddressIDs = await WalletManager.getAccountAddressIDs(
          accountModel.accountID,
        );
        if (accountAddressIDs.isEmpty) {
          continue;
        }

        try {
          await WalletManager.handleBitcoinAddressRequests(
            account!,
            walletModel.walletID,
            accountModel.accountID,
          );
        } catch (e, stacktrace) {
          await Sentry.captureException(
            e,
            stackTrace: stacktrace,
          );
          logger.e("handleBitcoinAddressRequests error: $e");
        }
        try {
          await WalletManager.bitcoinAddressPoolHealthCheck(
            account!,
            walletModel.walletID,
            accountModel.accountID,
          );
        } catch (e, stacktrace) {
          await Sentry.captureException(
            e,
            stackTrace: stacktrace,
          );
          logger.e("bitcoinAddressPoolHealthCheck error: $e");
        }
      }
    }
  }

  @override
  Future<void> dispose() async {}

  @override
  Future<void> init() async {}

  @override
  Future<void> logout() async {
    stop();
  }

  @override
  void stop() {
    connectivitySub?.cancel();
    super.stop();
  }

  @override
  Future<void> login(String userID) async {}
}
