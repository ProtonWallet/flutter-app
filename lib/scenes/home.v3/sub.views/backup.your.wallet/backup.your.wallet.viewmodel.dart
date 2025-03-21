import 'dart:async';

import 'package:wallet/managers/features/wallet.list/wallet.list.bloc.model.dart';
import 'package:wallet/managers/providers/backup.alert.timer.provider.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/backup.your.wallet/backup.your.wallet.coordinator.dart';

abstract class BackupYourWalletViewModel
    extends ViewModel<BackupYourWalletCoordinator> {
  BackupYourWalletViewModel(
    super.coordinator,
  );

  void showSetupBackup() {
    coordinator.showSetupBackup();
  }

  Future<void> remindMeLater();

  String getWalletName();
}

class BackupYourWalletViewModelImpl extends BackupYourWalletViewModel {
  final BackupAlertTimerProvider backupAlertTimerProvider;
  final WalletMenuModel walletMenuModel;

  BackupYourWalletViewModelImpl(
    super.coordinator,
    this.backupAlertTimerProvider,
    this.walletMenuModel,
  );

  @override
  Future<void> loadData() async {
    sinkAddSafe();
  }

  @override
  Future<void> move(NavID to) async {}

  @override
  String getWalletName() {
    return walletMenuModel.walletName;
  }

  @override
  Future<void> remindMeLater() async {
    await backupAlertTimerProvider.remindMeLater();
  }
}
