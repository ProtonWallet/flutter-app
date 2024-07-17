import 'package:flutter/widgets.dart';
import 'package:wallet/constants/env.dart';
import 'package:wallet/managers/channels/platform.channel.manager.dart';
import 'package:wallet/rust/api/api_service/proton_api_service.dart';
import 'package:wallet/scenes/app/app.view.dart';
import 'package:wallet/scenes/app/app.viewmodel.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/home.v3/home.coordinator.dart';
import 'package:wallet/scenes/welcome/welcome.coordinator.dart';

late ProtonApiService protonApiService; //temp. will need to move to manager

class AppCoordinator extends Coordinator {
  late ViewBase widget;

  AppCoordinator();

  @override
  void end() {}

  @override
  Widget start() {
    final viewModel = AppViewModelImpl(this, serviceManager);
    widget = AppView(
      viewModel,
      const SplashView(),
    );
    return widget;
  }

  void showHome(ApiEnv env) {
    final nativeViewChannel = serviceManager.get<PlatformChannelManager>();
    final view = HomeCoordinator(env, nativeViewChannel).start();

    pushReplacement(view);
  }

  void showWelcome(ApiEnv env) {
    final nativeViewChannel = serviceManager.get<PlatformChannelManager>();
    final view =
        WelcomeCoordinator(nativeViewChannel: nativeViewChannel).start();
    pushReplacement(view);
  }
}
