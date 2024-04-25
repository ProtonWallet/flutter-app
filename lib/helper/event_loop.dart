import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:provider/provider.dart';
import 'package:wallet/constants/address.key.dart';
import 'package:wallet/helper/bdk/helper.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/exchange.rate.service.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/helper/secure_storage_helper.dart';
import 'package:wallet/helper/user.settings.provider.dart';
import 'package:wallet/helper/wallet_manager.dart';
import 'package:wallet/helper/walletkey_helper.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/wallet.model.dart';
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

class EventLoop {
  static const int loopDuration = 10;
  bool _isRunning = false;
  String latestEventId = "";
  late UserSettingProvider userSettingProvider;

  Future<void> start() async {
    if (!_isRunning) {
      _isRunning = true;
      userSettingProvider = Provider.of<UserSettingProvider>(
          Coordinator.navigatorKey.currentContext!,
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
    Map<String, List<ProtonWalletKey>> walletID2ProtonWalletKey = {};
    try {
      List<ProtonEvent> events =
          await proton_api.collectEvents(latestEventId: latestEventId);
      for (ProtonEvent event in events) {
        latestEventId = event.eventId;
        await WalletManager.setLatestEventId(latestEventId);
        if (event.walletKeyEvents != null) {
          for (WalletKeyEvent walletKeyEvent in event.walletKeyEvents!) {
            ProtonWalletKey? walletKey = walletKeyEvent.walletKey;
            if (walletKey != null) {
              String serverWalletID = walletKey.walletId;
              if (!walletID2ProtonWalletKey.containsKey(serverWalletID)) {
                walletID2ProtonWalletKey[serverWalletID] = [];
              }
              walletID2ProtonWalletKey[serverWalletID]!.add(walletKey);
            }
          }
        }
        if (event.walletEvents != null) {
          for (WalletEvent walletEvent in event.walletEvents!) {
            if (walletEvent.action == 0) {
              String serverWalletID = walletEvent.id;
              await WalletManager.deleteWalletByServerWalletID(
                  serverWalletID); // Will also delete account
            }
            ProtonWallet? walletData = walletEvent.wallet;

            String userPrivateKey =
                await SecureStorageHelper.get("userPrivateKey");
            String userPassphrase =
                await SecureStorageHelper.get("userPassphrase");

            String encodedEncryptedEntropy = "";
            Uint8List entropy = Uint8List(0);
            if (walletData != null) {
              String serverWalletID = walletData.id;
              if (walletID2ProtonWalletKey.containsKey(serverWalletID)) {
                for (ProtonWalletKey? walletKey
                    in walletID2ProtonWalletKey[serverWalletID]!) {
                  try {
                    // try to decrypt
                    encodedEncryptedEntropy = walletKey!.walletKey;
                    entropy = proton_crypto.decryptBinary(userPrivateKey,
                        userPassphrase, base64Decode(encodedEncryptedEntropy));
                    break;
                  } catch (e) {
                    continue;
                  }
                }
              }
              if (entropy.isNotEmpty) {
                SecretKey secretKey =
                    WalletKeyHelper.restoreSecretKeyFromEntropy(entropy);
                await WalletManager.setWalletKey(serverWalletID, secretKey);
              }
              // int status = entropy.isNotEmpty
              //     ? WalletModel.statusActive
              //     : WalletModel.statusDisabled;
              int status = WalletModel.statusActive;
              await WalletManager.insertOrUpdateWallet(
                  userID: 0,
                  name: walletData.name,
                  encryptedMnemonic: walletData.mnemonic!,
                  passphrase: walletData.hasPassphrase,
                  imported: walletData.isImported,
                  priority: walletData.priority,
                  status: status,
                  type: walletData.type,
                  serverWalletID: serverWalletID);
            }
          }
        }
        if (event.walletAccountEvents != null) {
          for (WalletAccountEvent walletAccountEvent
              in event.walletAccountEvents!) {
            WalletAccount? account = walletAccountEvent.walletAccount;
            if (account != null) {
              int walletID = await WalletManager.getWalletIDByServerWalletID(
                  account.walletId);
              WalletManager.insertOrUpdateAccount(walletID, account.label,
                  account.scriptType, account.derivationPath, account.id);
            }
          }
        }
        if (event.walletSettingEvents != null) {
          for (WalletSettingsEvent walletSettingEvent
              in event.walletSettingEvents!) {
            WalletSettings? _ = walletSettingEvent.walletSettings;
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
      await WalletManager.initMuon(WalletManager.apiEnv);
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
        try {
          WalletManager.handleBitcoinAddressRequests(
              wallet, walletModel.serverWalletID, accountModel.serverAccountID);
        } catch (e) {
          logger.e("handleBitcoinAddressRequests error: ${e.toString()}");
        }
        try {
          WalletManager.bitcoinAddressPoolHealthCheck(
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
}
