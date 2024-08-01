import 'package:wallet/managers/api.service.manager.dart';
import 'package:wallet/managers/app.state.manager.dart';
import 'package:wallet/managers/features/proton.recovery/proton.recovery.bloc.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/recovery.phone/recovery.phone.view.dart';
import 'package:wallet/scenes/recovery.phone/recovery.phone.viewmodel.dart';

class RecoveryPhoneCoordinator extends Coordinator {
  late ViewBase widget;

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    final userManager = serviceManager.get<UserManager>();
    final apiServiceManager = serviceManager.get<ProtonApiServiceManager>();
    final dataProviderManager = serviceManager.get<DataProviderManager>();
    final appStateManager = serviceManager.get<AppStateManager>();

    final ProtonRecoveryBloc protonRecoveryBloc = ProtonRecoveryBloc(
      userManager,
      apiServiceManager.getProtonUsersApiClient(),
      dataProviderManager.userDataProvider,
      apiServiceManager.getSettingsApiClient(),
      appStateManager,
    );

    final viewModel = RecoveryPhoneViewModelImpl(
      this,
      protonRecoveryBloc,
      apiServiceManager.getProtonUsersApiClient(),
    );
    widget = RecoveryPhoneView(
      viewModel,
    );
    return widget;
  }
}
