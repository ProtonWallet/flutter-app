import 'package:wallet/constants/env.dart';
import 'package:wallet/managers/api.service.manager.dart';
import 'package:wallet/managers/app.state.manager.dart';
import 'package:wallet/managers/channels/platform.channel.manager.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/home.coordinator.dart';
import 'package:wallet/scenes/signin/signin.view.dart';
import 'package:wallet/scenes/signin/signin.viewmodel.dart';

class SigninCoordinator extends Coordinator {
  late ViewBase widget;
  @override
  void end() {}

  void showHome(ApiEnv env) {
    final nativeViewChannel = serviceManager.get<PlatformChannelManager>();
    final view = HomeCoordinator(env, nativeViewChannel).start();
    pushReplacement(view);
  }

  @override
  ViewBase<ViewModel> start() {
    final userManager = serviceManager.get<UserManager>();
    final apiServiceManager = serviceManager.get<ProtonApiServiceManager>();
    final apiService = apiServiceManager.getApiService();
    final dataProviderManager = serviceManager.get<DataProviderManager>();
    final appStateManager = serviceManager.get<AppStateManager>();
    final viewModel = SigninViewModelImpl(
      this,
      userManager,
      apiService,
      dataProviderManager,
      appStateManager,
    );
    widget = SigninView(
      viewModel,
    );
    return widget;
  }
}
