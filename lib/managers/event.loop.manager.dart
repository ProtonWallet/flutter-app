import 'dart:async';

import 'package:sentry/sentry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/api.service.manager.dart';
import 'package:wallet/managers/app.state.manager.dart';
import 'package:wallet/managers/manager.dart';
import 'package:wallet/managers/preferences/preferences.keys.dart';
import 'package:wallet/managers/preferences/preferences.manager.dart';
import 'package:wallet/managers/providers/connectivity.provider.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/services/exchange.rate.service.dart';
import 'package:wallet/managers/services/service.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/rust/api/bdk_wallet/account.dart';
import 'package:wallet/rust/api/errors.dart';
import 'package:wallet/rust/proton_api/event_routes.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/rust/proton_api/wallet.dart';
import 'package:wallet/rust/proton_api/wallet_account.dart';
import 'package:wallet/rust/proton_api/wallet_settings.dart';

typedef RecoveryCallback = Future<void> Function(List<LoadingTask> failedTask);

class EventLoop extends Service implements Manager {
  final UserManager userManager;
  final WalletManager walletManager;
  final DataProviderManager dataProviderManager;
  final AppStateManager appStateManager;
  final ConnectivityProvider connectivityProvider;
  final ProtonApiServiceManager apiServiceManager;

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
    this.walletManager,
    this.dataProviderManager,
    this.appStateManager,
    this.connectivityProvider,
    this.shared,
    this.apiServiceManager, {
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
    if (appStateManager.isInBackground) {
      /// skip eventloop if app in background
      final nextWaiting = await appStateManager.getEventloopDuration();
      return Duration(seconds: nextWaiting);
    }

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
      final count = await shared.read(PreferenceKeys.syncErrorCount) ?? 0;
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
      final eventClient = apiServiceManager.getApiService().getEventClient();
      final String? savedLatestEventId = await getLatestEventId();
      latestEventId =
          savedLatestEventId ?? await eventClient.getLatestEventId();
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
    try {
      final eventClient = apiServiceManager.getApiService().getEventClient();
      final events = await eventClient.collectEvents(
        latestEventId: latestEventId,
      );
      for (final event in events) {
        // check wallet key events
        if (event.walletKeyEvents != null) {
          for (final walletKeyEvent in event.walletKeyEvents!) {
            final ApiWalletKey? walletKey = walletKeyEvent.walletKey;
            if (walletKey != null) {
              await dataProviderManager.walletKeysProvider.saveApiWalletKeys(
                [walletKey],
              );
            }
          }
        }
        if (event.walletEvents != null) {
          for (WalletEvent walletEvent in event.walletEvents!) {
            if (walletEvent.action == 0) {
              final serverWalletID = walletEvent.id;
              // Will also delete account
              await dataProviderManager.walletDataProvider
                  .deleteWalletByServerID(serverWalletID);
              continue;
            }
            final ApiWallet? walletData = walletEvent.wallet;
            if (walletData != null) {
              final walletID = walletData.id;
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
                migrationRequired: walletData.migrationRequired ?? 0,
                legacy: walletData.legacy ?? 0,
              );
            }
          }
        }

        if (event.walletAccountEvents != null) {
          for (final walletAccountEvent in event.walletAccountEvents!) {
            if (walletAccountEvent.action == 0) {
              final accountID = walletAccountEvent.id;
              await dataProviderManager.walletDataProvider.deleteWalletAccount(
                accountID: accountID,
              );
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
                account.stopGap,
              );
            }
          }
        }
        if (event.walletSettingEvents != null) {
          for (final walletSettingEvent in event.walletSettingEvents!) {
            final ApiWalletSettings? walletSettings =
                walletSettingEvent.walletSettings;
            if (walletSettings != null) {
              await dataProviderManager.walletDataProvider
                  .updateShowWalletRecovery(
                walletID: walletSettings.walletId,
                showWalletRecovery: walletSettings.showWalletRecovery ?? true,
              );
            }
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
              final contactID = contactEvent.id;
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

        if (event.protonUserSettings != null) {
          /// reload protonUserSettings directly since it should not change often
          /// we can add local db if needed
          await dataProviderManager.userDataProvider.syncProtonUserSettings();

          /// the deviceRecovery in userSetting will also affect enabledRecovery status
          /// so need to sync protonUser to see if we need to update the enabledRecovery status
          await dataProviderManager.userDataProvider.syncProtonUser();
        }

        if (event.protonUser != null) {
          /// reload protonUser directly since it should not change often
          /// we can add local db if needed
          await dataProviderManager.userDataProvider.syncProtonUser();
        }

        /// update event id
        latestEventId = event.eventId;
        await setLatestEventId(latestEventId);
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
    } catch (e, stacktrace) {
      logger.e("polling error: $e stacktrace: $stacktrace");
    }
    try {
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

  Future<void> handleBitcoinAddress() async {
    final userID = userManager.userInfo.userId;
    final walletModels = await DBHelper.walletDao!.findAllByUserID(userID);
    for (final walletModel in walletModels) {
      final accountModels = await DBHelper.accountDao!.findAllByWalletID(
        walletModel.walletID,
      );
      for (final accountModel in accountModels) {
        final FrbAccount? account = await walletManager.loadWalletWithID(
          walletModel.walletID,
          accountModel.accountID,
          serverScriptType: accountModel.scriptType,
        );

        await walletManager.ensureReceivedAddressNotGotReused(
            account!, accountModel);

        /// resync the email address in case that user update it on web
        /// and mobile didn't get event loop yet
        await dataProviderManager.walletDataProvider.syncEmailAddresses(
          walletModel.walletID,
          accountModel.accountID,
        );
        final accountAddressIDs = await WalletManager.getAccountAddressIDs(
          accountModel.accountID,
        );

        final bool enabledBvE = accountAddressIDs.isNotEmpty;

        /// skip address pool check if user didn't enable BvE for this wallet account
        if (!enabledBvE) {
          continue;
        }

        try {
          await walletManager.handleBitcoinAddressRequests(
            account,
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
          await walletManager.bitcoinAddressPoolHealthCheck(
            account,
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

  Future<void> setLatestEventId(String latestEventId) async {
    final preferences = await SharedPreferences.getInstance();
    preferences.setString(PreferenceKeys.latestEventId, latestEventId);
  }

  Future<String?> getLatestEventId() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(PreferenceKeys.latestEventId);
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

  @override
  Future<void> reload() async {}

  @override
  Priority getPriority() {
    return Priority.level5;
  }
}
