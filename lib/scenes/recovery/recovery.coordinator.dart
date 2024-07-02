import 'package:wallet/managers/api.service.manager.dart';
import 'package:wallet/managers/features/proton.recovery.bloc.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/recovery/recovery.view.dart';
import 'package:wallet/scenes/recovery/recovery.viewmodel.dart';

class RecoveryCoordinator extends Coordinator {
  late ViewBase widget;

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    var userManager = serviceManager.get<UserManager>();
    var apiServiceManager = serviceManager.get<ProtonApiServiceManager>();
    ProtonRecoveryBloc protonRecoveryBloc = ProtonRecoveryBloc(
      userManager,
      apiServiceManager.getUsersApiClient(),
    );

    var viewModel = RecoveryViewModelImpl(
      this,
      protonRecoveryBloc,
      apiServiceManager.getUsersApiClient(),
    );
    widget = RecoveryView(
      viewModel,
    );
    return widget;
  }
}
