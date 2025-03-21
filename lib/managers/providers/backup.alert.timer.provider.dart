import 'dart:async';

import 'package:wallet/helper/extension/datetime.dart';
import 'package:wallet/managers/features/wallet.list/wallet.list.bloc.model.dart';
import 'package:wallet/managers/preferences/preferences.keys.dart';
import 'package:wallet/managers/preferences/preferences.manager.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/rust/api/api_service/block_client.dart';

class BackupAlertTimerProvider extends DataProvider {
  /// shared preference
  final PreferencesManager shared;

  BackupAlertTimerProvider(
    this.shared,
  );

  Future<void> remindMeLater() async {
    final currentTime = DateTime.now().secondsSinceEpoch();
    int backupWalletAlertNextAlertTime = currentTime;
    final backupWalletAlertReminderCounter =
        await shared.read(PreferenceKeys.backupWalletAlertReminderCounter) ?? 0;

    switch (backupWalletAlertReminderCounter) {
      case 0:
        // next reminder after 3 days
        backupWalletAlertNextAlertTime = currentTime + 60 * 60 * 24 * 3;
      case 1:
        // next reminder after 7 days
        backupWalletAlertNextAlertTime = currentTime + 60 * 60 * 24 * 7;
      case 2:
      default:
        // next reminder after 14 days
        backupWalletAlertNextAlertTime = currentTime + 60 * 60 * 24 * 14;
    }
    await shared.write(
      PreferenceKeys.backupWalletAlertReminderCounter,
      backupWalletAlertReminderCounter + 1,
    );
    await shared.write(
      PreferenceKeys.backupWalletAlertNextAlertTime,
      backupWalletAlertNextAlertTime,
    );
  }

  /// return true if exceed backup remind timer
  /// return false if not exceed backup remind timer
  Future<bool> isExceedTimer() async {
    final backupWalletAlertNextAlertTime =
        await shared.read(PreferenceKeys.backupWalletAlertNextAlertTime) ?? 0;
    final currentTime = DateTime.now().secondsSinceEpoch();

    return currentTime >= backupWalletAlertNextAlertTime;
  }

  @override
  Future<void> clear() async {}

  @override
  Future<void> reload() async {}
}
