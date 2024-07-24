import 'package:cryptography/cryptography.dart';
import 'package:provider/provider.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/helper/walletkey_helper.dart';
import 'package:wallet/managers/app.state.manager.dart';
import 'package:wallet/managers/manager.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/providers/models/wallet.key.dart';
import 'package:wallet/managers/services/exchange.rate.service.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/managers/wallet/proton.wallet.manager.dart';
import 'package:wallet/managers/wallet/proton.wallet.provider.dart'
    as proton_wallet_provider;
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/rust/api/bdk_wallet/account.dart';
import 'package:wallet/rust/api/proton_api.dart' as proton_api;
import 'package:wallet/rust/common/errors.dart';
import 'package:wallet/rust/proton_api/event_routes.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/rust/proton_api/wallet.dart';
import 'package:wallet/rust/proton_api/wallet_account.dart';
import 'package:wallet/rust/proton_api/wallet_settings.dart';
import 'package:wallet/scenes/core/coordinator.dart';

// TODO(fix): handle user and settings event.
class EventLoop implements Manager {
  final UserManager userManager;
  final ProtonWalletManager protonWalletManager;
  final DataProviderManager dataProviderManager;
  final AppStateManager appStateManager;
  bool _isRunning = false;
  String latestEventId = "";
  late proton_wallet_provider.ProtonWalletProvider protonWalletProvider;

  EventLoop(
    this.protonWalletManager,
    this.userManager,
    this.dataProviderManager,
    this.appStateManager,
  );

  Future<void> start() async {
    if (!_isRunning) {
      _isRunning = true;
      protonWalletProvider =
          Provider.of<proton_wallet_provider.ProtonWalletProvider>(
              Coordinator.rootNavigatorKey.currentContext!,
              listen: false);
      final String? savedLatestEventId = await WalletManager.getLatestEventId();
      latestEventId = savedLatestEventId ?? await proton_api.getLatestEventId();
      await _run();
    }
  }

  Future<void> _run() async {
    while (_isRunning) {
      await runOnce();
      final nextWaiting = await appStateManager.getEventloopDuration();
      await Future.delayed(Duration(seconds: nextWaiting));
    }
  }

  Future<void> runOnce() async {
    logger.i("event loop runOnce()");
    final Map<String, List<ApiWalletKey>> walletID2ProtonWalletKey = {};
    try {
      final List<ProtonEvent> events =
          await proton_api.collectEvents(latestEventId: latestEventId);
      for (ProtonEvent event in events) {
        latestEventId = event.eventId;
        await WalletManager.setLatestEventId(latestEventId);
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
                      serverWalletID); // Will also delete account
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
              String decryptedWalletName = walletData.name;
              try {
                secretKey ??= await WalletManager.getWalletKey(walletID);
                decryptedWalletName = await WalletKeyHelper.decrypt(
                  secretKey,
                  decryptedWalletName,
                );
              } catch (e) {
                logger.e(e.toString());
              }
              await dataProviderManager.walletDataProvider.insertOrUpdateWallet(
                userID: userManager.userID,
                name: decryptedWalletName,
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
          for (WalletAccountEvent walletAccountEvent
              in event.walletAccountEvents!) {
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
          for (WalletSettingsEvent walletSettingEvent
              in event.walletSettingEvents!) {
            final ApiWalletSettings? _ = walletSettingEvent.walletSettings;
          }
        }
        if (event.walletUserSettings != null) {
          final ApiWalletUserSettings settings = event.walletUserSettings!;
          await dataProviderManager.userSettingsDataProvider
              .insertUpdate(settings);
        }
        if (event.walletTransactionEvents != null) {
          for (WalletTransactionEvent walletTransactionEvent
              in event.walletTransactionEvents!) {
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
          for (ContactEmailEvent contactEvent in event.contactEmailEvents!) {
            if (contactEvent.action == 0) {
              final String contactID = contactEvent.id;
              await dataProviderManager.contactsDataProvider.delete(contactID);
              continue;
            }
            final mail = contactEvent.contactEmail;
            if (mail != null) {
              await dataProviderManager.contactsDataProvider.insertUpdate(mail);
            }
          }
        }
      }
      await appStateManager.resetEventloopDuration();
    } on BridgeError catch (e, stacktrace) {
      appStateManager.handleError(e);
      logger.e("Event Loop error: $e stacktrace: $stacktrace");
    } catch (e, stacktrace) {
      logger.e("Event Loop error: $e stacktrace: $stacktrace");
    }
    try {
      await polling();
    } catch (e, stacktrace) {
      logger.e("polling error: $e stacktrace: $stacktrace");
    }
  }

  Future<void> polling() async {
    await handleBitcoinAddress();
    await ExchangeRateService.runOnce(
        dataProviderManager.userSettingsDataProvider.fiatCurrency);
    final ProtonExchangeRate exchangeRate =
        await ExchangeRateService.getExchangeRate(
            dataProviderManager.userSettingsDataProvider.fiatCurrency);
    dataProviderManager.userSettingsDataProvider
        .updateExchangeRate(exchangeRate);
    await dataProviderManager.blockInfoDataProvider.syncBlockHeight();

    // TODO(fix): add logic here
    // fetch for account setting's exchange rate, used for sidebar balance
    // for (AccountModel accountModel
    //     in protonWalletProvider.protonWallet.accounts) {
    //   FiatCurrency fiatCurrency =
    //       WalletManager.getAccountFiatCurrency(accountModel);
    //   await ExchangeRateService.runOnce(fiatCurrency);
    //   // ProtonExchangeRate exchangeRate = await ExchangeRateService.getExchangeRate(fiatCurrency);
    // }
  }

  // TODO(fix): fix me handle the !
  Future<void> handleBitcoinAddress() async {
    final userID = userManager.userInfo.userId;
    final walletModels = await DBHelper.walletDao!.findAllByUserID(userID);
    for (WalletModel walletModel in walletModels) {
      final accountModels =
          await DBHelper.accountDao!.findAllByWalletID(walletModel.walletID);
      for (AccountModel accountModel in accountModels) {
        final FrbAccount? account = await WalletManager.loadWalletWithID(
          walletModel.walletID,
          accountModel.accountID,
          serverScriptType: accountModel.scriptType,
        );

        final List<String> accountAddressIDs =
            await WalletManager.getAccountAddressIDs(accountModel.accountID);
        if (accountAddressIDs.isEmpty) {
          continue;
        }

        try {
          await WalletManager.handleBitcoinAddressRequests(
            account!,
            walletModel.walletID,
            accountModel.accountID,
          );
        } catch (e) {
          logger.e("handleBitcoinAddressRequests error: $e");
        }
        try {
          await WalletManager.bitcoinAddressPoolHealthCheck(
            account!,
            walletModel.walletID,
            accountModel.accountID,
          );
        } catch (e) {
          logger.e("bitcoinAddressPoolHealthCheck error: $e");
        }
      }
    }
  }

  void stop() {
    _isRunning = false;
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
  Future<void> login(String userID) async {}
}
