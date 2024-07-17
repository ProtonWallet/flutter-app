import 'package:wallet/managers/api.service.manager.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';

import 'two.factor.auth.view.dart';
import 'two.factor.auth.viewmodel.dart';

class TwoFactorAuthCoordinator extends Coordinator {
  late ViewBase widget;

  TwoFactorAuthCoordinator();

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    final userManager = serviceManager.get<UserManager>();
    final apiServices = serviceManager.get<ProtonApiServiceManager>();
    final dataProvider = serviceManager.get<DataProviderManager>();

    final viewModel = TwoFactorAuthViewModelImpl(
      this,
      userManager,
      apiServices.getUsersApiClient(),
      apiServices.getSettingsApiClient(),
      dataProvider.protonUserDataProvider,
    );
    widget = TwoFactorAuthView(
      viewModel,
    );
    return widget;
  }
}
