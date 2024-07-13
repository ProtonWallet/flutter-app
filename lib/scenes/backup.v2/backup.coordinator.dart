import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/scenes/backup.v2/backup.view.dart';
import 'package:wallet/scenes/backup.v2/backup.viewmodel.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';

class SetupBackupCoordinator extends Coordinator {
  late ViewBase widget;
  final String walletID;

  SetupBackupCoordinator(this.walletID);

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    final dataProviderManager = serviceManager.get<DataProviderManager>();
    final userManager = serviceManager.get<UserManager>();
    final viewModel = SetupBackupViewModelImpl(
      this,
      walletID,
      dataProviderManager.walletDataProvider,
      userManager.userID,
    );
    widget = SetupBackupView(
      viewModel,
    );
    return widget;
  }
}
