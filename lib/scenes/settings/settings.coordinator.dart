import 'package:wallet/constants/env.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home/navigation.coordinator.dart';
import 'package:wallet/scenes/settings/settings.view.dart';
import 'package:wallet/scenes/settings/settings.viewmodel.dart';

class SettingsCoordinator extends Coordinator {
  late ViewBase widget;
  @override
  void end() {}

  void showHome(ApiEnv env) {
    var view = HomeNavigationCoordinator(env).start();
    pushReplacement(view);
  }

  @override
  ViewBase<ViewModel> start() {
    var userManager = serviceManager.get<UserManager>();
    // var apiServiceManager = serviceManager.get<ProtonApiServiceManager>();
    // var apiService = apiServiceManager.getApiService();
    // var dataProviderManager = serviceManager.get<DataProviderManager>();
    var viewModel = SettingsViewModelImpl(
      this,
      userManager,
      // apiService,
      // dataProviderManager,
    );
    widget = SettingsView(
      viewModel,
    );
    return widget;
  }
}
