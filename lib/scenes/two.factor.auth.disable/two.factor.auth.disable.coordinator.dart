import 'package:wallet/managers/api.service.manager.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';

import 'two.factor.auth.disable.view.dart';
import 'two.factor.auth.disable.viewmodel.dart';

class TwoFactorAuthDisableCoordinator extends Coordinator {
  late ViewBase widget;

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    final apiServices = serviceManager.get<ProtonApiServiceManager>();
    final dataProvider = serviceManager.get<DataProviderManager>();
    final viewModel = TwoFactorAuthDisableViewModelImpl(
      this,
      apiServices.getUsersApiClient(),
      apiServices.getSettingsApiClient(),
      dataProvider.protonUserDataProvider,
    );
    widget = TwoFactorAuthDisableView(
      viewModel,
    );
    return widget;
  }
}
