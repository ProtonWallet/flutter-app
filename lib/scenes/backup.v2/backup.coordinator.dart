import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/scenes/backup.v2/backup.view.dart';
import 'package:wallet/scenes/backup.v2/backup.viewmodel.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';

class SetupBackupCoordinator extends Coordinator {
  late ViewBase widget;
  final int walletID;

  SetupBackupCoordinator(this.walletID);

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    var dataProviderManager = serviceManager.get<DataProviderManager>();
    var viewModel = SetupBackupViewModelImpl(
      this,
      walletID,
      dataProviderManager.walletDataProvider,
    );
    widget = SetupBackupView(
      viewModel,
    );
    return widget;
  }
}
