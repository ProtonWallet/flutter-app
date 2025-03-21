import 'dart:async';
import 'package:wallet/managers/providers/backup.alert.timer.provider.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/backup.your.proton/backup.your.proton.coordinator.dart';

abstract class BackupYourProtonViewModel
    extends ViewModel<BackupYourProtonCoordinator> {
  BackupYourProtonViewModel(
    super.coordinator,
  );

  void showRecovery() {
    coordinator.showRecovery();
  }

  Future<void> remindMeLater();
}

class BackupYourProtonViewModelImpl extends BackupYourProtonViewModel {
  final BackupAlertTimerProvider backupAlertTimerProvider;

  BackupYourProtonViewModelImpl(
    super.coordinator,
    this.backupAlertTimerProvider,
  );

  @override
  Future<void> loadData() async {
    sinkAddSafe();
  }

  @override
  Future<void> move(NavID to) async {}

  @override
  Future<void> remindMeLater() async {
    await backupAlertTimerProvider.remindMeLater();
  }
}
