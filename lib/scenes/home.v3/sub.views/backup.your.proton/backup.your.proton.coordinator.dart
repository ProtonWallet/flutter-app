import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/backup.your.proton/backup.your.proton.view.dart';
import 'package:wallet/scenes/home.v3/sub.views/backup.your.proton/backup.your.proton.viewmodel.dart';
import 'package:wallet/scenes/recovery/recovery.coordinator.dart';

class BackupYourProtonCoordinator extends Coordinator {
  late ViewBase widget;

  BackupYourProtonCoordinator();

  void showRecovery() {
    final view = RecoveryCoordinator().start();
    showInBottomSheet(view);
  }

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    final dataProviderManager = serviceManager.get<DataProviderManager>();
    final viewModel = BackupYourProtonViewModelImpl(
      this,
      dataProviderManager.backupAlertTimerProvider,
    );
    widget = BackupYourProtonView(
      viewModel,
    );
    return widget;
  }
}
