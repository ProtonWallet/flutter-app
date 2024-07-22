import 'package:wallet/managers/api.service.manager.dart';
import 'package:wallet/managers/app.state.manager.dart';
import 'package:wallet/managers/local.auth.manager.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';

import 'package:wallet/scenes/security.setting/security.setting.view.dart';
import 'package:wallet/scenes/security.setting/security.setting.viewmodel.dart';
import 'package:wallet/scenes/two.factor.auth.disable/two.factor.auth.disable.coordinator.dart';
import 'package:wallet/scenes/two.factor.auth/two.factor.auth.coordinator.dart';

class SecuritySettingCoordinator extends Coordinator {
  late ViewBase widget;

  void showTwoFactorAuthSetup() {
    final view = TwoFactorAuthCoordinator().start();
    showInBottomSheet(view);
  }

  void showTwoFactorAuthDisable() {
    final view = TwoFactorAuthDisableCoordinator().start();
    showInBottomSheet(view);
  }

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    final appState = serviceManager.get<AppStateManager>();
    final localAuth = serviceManager.get<LocalAuthManager>();
    final apiService = serviceManager.get<ProtonApiServiceManager>();
    final dataProvider = serviceManager.get<DataProviderManager>();

    final viewModel = SecuritySettingViewModelImpl(
      this,
      appState,
      localAuth,
      apiService.getProtonUsersApiClient(),
      dataProvider.userDataProvider,
    );
    widget = SecuritySettingView(
      viewModel,
    );
    return widget;
  }
}
