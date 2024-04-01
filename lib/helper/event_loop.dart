import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:wallet/helper/secure_storage_helper.dart';
import 'package:wallet/helper/wallet_manager.dart';
import 'package:wallet/helper/walletkey_helper.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/rust/api/proton_api.dart' as proton_api;
import 'package:wallet/rust/proton_api/event_routes.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/rust/proton_api/wallet.dart';
import 'package:wallet/rust/proton_api/wallet_account.dart';
import 'package:wallet/rust/proton_api/wallet_settings.dart';
import 'package:proton_crypto/proton_crypto.dart' as proton_crypto;

class EventLoop {
  static const int loopDuration = 30;
  bool _isRunning = false;
  String latestEventId = "";

  Future<void> start() async {
    if (!_isRunning) {
      _isRunning = true;
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
      }
    } catch (e) {
      // print("EventLoop error: ${e.toString()}");
    }
  }

  void stop() {
    _isRunning = false;
  }
}
