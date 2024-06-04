import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:provider/provider.dart';
import 'package:wallet/constants/address.key.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/helper/bdk/helper.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/exchange.rate.service.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/manager.dart';
import 'package:wallet/helper/user.settings.provider.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/managers/wallet/proton.wallet.manager.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/helper/walletkey_helper.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/managers/wallet/proton.wallet.manager.dart'
    as proton_wallet_provider;
import 'package:wallet/rust/api/proton_api.dart' as proton_api;
import 'package:wallet/rust/proton_api/contacts.dart';
import 'package:wallet/rust/proton_api/event_routes.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/rust/proton_api/wallet.dart';
import 'package:wallet/rust/proton_api/wallet_account.dart';
import 'package:wallet/rust/proton_api/wallet_settings.dart';
import 'package:proton_crypto/proton_crypto.dart' as proton_crypto;
import 'package:wallet/scenes/core/coordinator.dart';

class EventLoop implements Manager {
  final UserManager userManager;
  final ProtonWalletManager protonWalletManager;
  static const int loopDuration = 10;
  bool _isRunning = false;
  String latestEventId = "";
  late UserSettingProvider userSettingProvider;
  late proton_wallet_provider.ProtonWalletProvider protonWalletProvider;

  EventLoop(this.protonWalletManager, this.userManager);

  Future<void> start() async {
    if (!_isRunning) {
      _isRunning = true;
      userSettingProvider = Provider.of<UserSettingProvider>(
          Coordinator.rootNavigatorKey.currentContext!,
          listen: false);
      protonWalletProvider =
          Provider.of<proton_wallet_provider.ProtonWalletProvider>(
              Coordinator.rootNavigatorKey.currentContext!,
              listen: false);
      String? savedLatestEventId = await WalletManager.getLatestEventId();
      latestEventId = savedLatestEventId ?? await proton_api.getLatestEventId();
      await _run();
    }
  }

  Future<void> _run() async {
    while (_isRunning) {
      await runOnce();
      await Future.delayed(const Duration(seconds: loopDuration));
    }
  }

  Future<void> runOnce() async {
    logger.i("event loop runOnce()");
    Map<String, List<ApiWalletKey>> walletID2ProtonWalletKey = {};
    try {
      List<ProtonEvent> events =
          await proton_api.collectEvents(latestEventId: latestEventId);
      for (ProtonEvent event in events) {
        latestEventId = event.eventId;
        await WalletManager.setLatestEventId(latestEventId);
        if (event.walletKeyEvents != null) {
          for (WalletKeyEvent walletKeyEvent in event.walletKeyEvents!) {
            ApiWalletKey? walletKey = walletKeyEvent.walletKey;
            if (walletKey != null) {
              String serverWalletID = walletKey.walletId;
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
              String serverWalletID = walletEvent.id;
              await WalletManager.deleteWalletByServerWalletID(
                  serverWalletID); // Will also delete account
              continue;
            }
            ApiWallet? walletData = walletEvent.wallet;

            UserKey firstKey = await userManager.getFirstKey();

            String userPrivateKey = firstKey.privateKey;
            String userPassphrase = firstKey.passphrase;
            Uint8List entropy = Uint8List(0);
            if (walletData != null) {
              String serverWalletID = walletData.id;
              if (walletID2ProtonWalletKey.containsKey(serverWalletID)) {
                for (ApiWalletKey? walletKey
                    in walletID2ProtonWalletKey[serverWalletID]!) {
                  try {
                    // try to decrypt
                    String pgpBinaryMessage = walletKey?.walletKey ?? "";
                    String signature = walletKey?.walletKeySignature ?? "";

                    entropy = proton_crypto.decryptBinaryPGP(
                        userPrivateKey, userPassphrase, pgpBinaryMessage);
                    String userPublicKey =
                        proton_crypto.getArmoredPublicKey(userPrivateKey);
                    bool isValidWalletKeySignature =
                        proton_crypto.verifyBinarySignatureWithContext(
                            userPublicKey,
                            entropy,
                            signature,
                            gpgContextWalletKey);
                    logger.i(
                        "isValidWalletKeySignature = $isValidWalletKeySignature");
                    break;
                  } catch (e) {
                    continue;
                  }
                }
              }
              SecretKey? secretKey;
              if (entropy.isNotEmpty) {
                secretKey =
                    WalletKeyHelper.restoreSecretKeyFromEntropy(entropy);
              }
              // int status = entropy.isNotEmpty
              //     ? WalletModel.statusActive
              //     : WalletModel.statusDisabled;
              int status = WalletModel.statusActive;
              String decryptedWalletName = walletData.name;
              try {
                secretKey ??= await WalletManager.getWalletKey(serverWalletID);
                decryptedWalletName = await WalletKeyHelper.decrypt(
                    secretKey, decryptedWalletName);
              } catch (e) {
                logger.e(e.toString());
              }
              await WalletManager.insertOrUpdateWallet(
                  userID: 0,
                  name: decryptedWalletName,
                  encryptedMnemonic: walletData.mnemonic!,
                  passphrase: walletData.hasPassphrase,
                  imported: walletData.isImported,
                  priority: walletData.priority,
                  status: status,
                  type: walletData.type,
                  fingerprint: walletData.fingerprint ?? "",
                  serverWalletID: serverWalletID);
            }
          }
        }
        if (event.walletAccountEvents != null) {
          for (WalletAccountEvent walletAccountEvent
              in event.walletAccountEvents!) {
            if (walletAccountEvent.action == 0) {
              String serverAccountID = walletAccountEvent.id;
              await WalletManager.deleteWalletAccountByServerAccountID(
                  serverAccountID);
              continue;
            }
            ApiWalletAccount? account = walletAccountEvent.walletAccount;
            if (account != null) {
              int walletID = await WalletManager.getWalletIDByServerWalletID(
                  account.walletId);
              int internal = 0;
              WalletManager.insertOrUpdateAccount(
                  walletID,
                  account.label,
                  account.scriptType,
                  "${account.derivationPath}/$internal",
                  // Backend store m/$ScriptType/$CoinType/$accountIndex, we need m/$ScriptType/$CoinType/$accountIndex/$internal here
                  account.id,
                  account.fiatCurrency);
            }
          }
        }
        if (event.walletSettingEvents != null) {
          for (WalletSettingsEvent walletSettingEvent
              in event.walletSettingEvents!) {
            ApiWalletSettings? _ = walletSettingEvent.walletSettings;
            // TODO::
          }
        }
        if (event.walletUserSettings != null) {
          ApiUserSettings _ = event.walletUserSettings!;

          // TODO::
        }
        if (event.walletTransactionEvents != null) {
          List<AddressKey> addressKeys = await WalletManager.getAddressKeys();
          for (WalletTransactionEvent walletTransactionEvent
              in event.walletTransactionEvents!) {
            WalletTransaction? walletTransaction =
                walletTransactionEvent.walletTransaction;
            WalletModel? walletModel = await DBHelper.walletDao!
                .getWalletByServerWalletID(walletTransaction!.walletId);
            if (walletModel != null) {
              await WalletManager.handleWalletTransaction(
                  walletModel, addressKeys, walletTransaction);
              protonWalletProvider.setCurrentTransactions();
            }
          }
        }

        if (event.contactEmailEvents != null) {
          for (ContactEmailEvent contactEmailEvent
              in event.contactEmailEvents!) {
            ProtonContactEmails? mail = contactEmailEvent.contactEmail;
            if (mail != null) {
              DBHelper.contactsDao!.insertOrUpdate(mail.id, mail.name,
                  mail.email, mail.canonicalEmail, mail.isProton);
            }
          }
        }
      }
      await polling();
    } catch (e) {
      logger.e("Event Loop error: ${e.toString()}");
    }
  }

  Future<void> polling() async {
    await handleBitcoinAddress();
    await ExchangeRateService.runOnce(
        userSettingProvider.walletUserSetting.fiatCurrency);
    ProtonExchangeRate exchangeRate = await ExchangeRateService.getExchangeRate(
        userSettingProvider.walletUserSetting.fiatCurrency);
    userSettingProvider.updateExchangeRate(exchangeRate);
  }

  Future<void> handleBitcoinAddress() async {
    List<WalletModel> walletModels =
        (await DBHelper.walletDao!.findAll()).cast<WalletModel>();
    for (WalletModel walletModel in walletModels) {
      List<AccountModel> accountModels =
          (await DBHelper.accountDao!.findAllByWalletID(walletModel.id!))
              .cast<AccountModel>();
      for (AccountModel accountModel in accountModels) {
        Wallet wallet = await WalletManager.loadWalletWithID(
            walletModel.id!, accountModel.id!);
        List<String> accountAddressIDs =
            await WalletManager.getAccountAddressIDs(
                accountModel.serverAccountID);
        if (accountAddressIDs.isEmpty) {
          continue;
        }

        try {
          await WalletManager.handleBitcoinAddressRequests(
              wallet, walletModel.serverWalletID, accountModel.serverAccountID);
        } catch (e) {
          logger.e("handleBitcoinAddressRequests error: ${e.toString()}");
        }
        try {
          await WalletManager.bitcoinAddressPoolHealthCheck(
              wallet, walletModel.serverWalletID, accountModel.serverAccountID);
        } catch (e) {
          logger.e("bitcoinAddressPoolHealthCheck error: ${e.toString()}");
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
}
