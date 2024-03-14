import 'package:wallet/helper/wallet_manager.dart';
import 'package:wallet/rust/api/proton_api.dart' as proton_api;
import 'package:wallet/rust/proton_api/event_routes.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/rust/proton_api/wallet.dart';
import 'package:wallet/rust/proton_api/wallet_account.dart';
import 'package:wallet/rust/proton_api/wallet_settings.dart';

class EventLoop {
  static const int loopDuration = 30;
  bool _isRunning = false;
  String latestEventId = "";

  Future<void> start() async {
    if (!_isRunning) {
      _isRunning = true;
      latestEventId = await proton_api.getLatestEventId();
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
    try {
      List<ProtonEvent> events =
          await proton_api.collectEvents(latestEventId: latestEventId);
      for (ProtonEvent event in events) {
        latestEventId = event.eventId;
        if (event.walletEvents != null) {
          for (WalletEvent walletEvent in event.walletEvents!) {
            ProtonWallet? wallet = walletEvent.wallet;
            // TODO::
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
        if (event.walletKeyEvents != null) {
          for (WalletKeyEvent walletKeyEvent in event.walletKeyEvents!) {
            ProtonWalletKey? walletKey = walletKeyEvent.walletKey;
            // TODO::
          }
        }
        if (event.walletSettingEvents != null) {
          for (WalletSettingsEvent walletSettingEvent
              in event.walletSettingEvents!) {
            WalletSettings? walletSettings = walletSettingEvent.walletSettings;
            // TODO::
          }
        }
        if (event.walletUserSettings != null) {
          ApiUserSettings userSettings = event.walletUserSettings!;

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
