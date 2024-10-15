import 'dart:async';

import 'package:wallet/constants/app.config.dart';
import 'package:wallet/constants/env.dart';
import 'package:wallet/managers/api.service.manager.dart';
import 'package:wallet/managers/channels/native.view.channel.dart';
import 'package:wallet/managers/channels/platform.channel.state.dart';
import 'package:wallet/managers/manager.factory.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/welcome/welcome.coordinator.dart';

abstract class WelcomeViewModel extends ViewModel<WelcomeCoordinator> {
  WelcomeViewModel(super.coordinator);

  bool isLoginToHomepage = false;
}

class WelcomeViewModelImpl extends WelcomeViewModel {
  final ManagerFactory serviceManager;
  final NativeViewChannel nativeChannel;
  final UserManager userManager;

  WelcomeViewModelImpl(
    super.coordinator,
    this.nativeChannel,
    this.userManager,
    this.serviceManager,
  );

  bool hadLocallogin = false;

  late StreamSubscription<NativeLoginState> _subscription;

  late ApiEnv env;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Future<void> loadData() async {
    env = appConfig.apiEnv;
    _subscription = nativeChannel.stream.listen(handleStateChanges);
    sinkAddSafe();
  }

  Future<void> handleStateChanges(NativeLoginState state) async {
    if (state is NativeLoginSucess) {
      isLoginToHomepage = true;
      sinkAddSafe();
      await userManager.nativeLogin(state.userInfo);
      await serviceManager.login(state.userInfo.userId);
      coordinator.showHome(env);
      isLoginToHomepage = false;
    }
  }

  @override
  Future<void> move(NavID to) async {
    switch (to) {
      case NavID.nativeSignin:
        if (mobile) {
          coordinator.showNativeSignin();
        } else {
          final apiServiceManager = serviceManager.get<ProtonApiServiceManager>();
          await apiServiceManager.initalOldApiService();
          coordinator.showFlutterSignin(env);
        }
      case NavID.nativeSignup:
        if (mobile) {
          coordinator.showNativeSignup();
        }
      default:
        break;
    }
  }
}
