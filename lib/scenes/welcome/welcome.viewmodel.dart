import 'dart:async';
import 'dart:io';

import 'package:wallet/constants/app.config.dart';
import 'package:wallet/constants/env.dart';
import 'package:wallet/helper/extension/stream.controller.dart';
import 'package:wallet/managers/channels/native.view.channel.dart';
import 'package:wallet/managers/channels/platform.channel.state.dart';
import 'package:wallet/managers/user.manager.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/welcome/welcome.coordinator.dart';

abstract class WelcomeViewModel extends ViewModel<WelcomeCoordinator> {
  WelcomeViewModel(super.coordinator);

  bool initialized = false;
}

class WelcomeViewModelImpl extends WelcomeViewModel {
  final NativeViewChannel nativeChannel;
  final UserManager userManager;

  WelcomeViewModelImpl(super.coordinator, this.nativeChannel, this.userManager);

  bool hadLocallogin = false;

  late StreamSubscription<NativeLoginState> _subscription;
  final datasourceChangedStreamController =
      StreamController<WelcomeViewModel>.broadcast();

  late ApiEnv env;

  @override
  void dispose() {
    _subscription.cancel();
    datasourceChangedStreamController.close();
  }

  @override
  Future<void> loadData() async {
    env = appConfig.apiEnv;
    nativeChannel.initalNativeApiEnv(appConfig.apiEnv);
    _subscription = nativeChannel.stream.listen(handleStateChanges);
    await _loginResume();
    datasourceChangedStreamController.sinkAddSafe(this);
  }

  Future<void> _loginResume() async {
    if (!hadLocallogin) {
      hadLocallogin = true;
      if (await userManager.sessionExists()) {
        await userManager.tryRestoreUserInfo();
        coordinator.showHome(env);
      }
    }
  }

  Future<void> mockUserSession() async {
    // await mockUserSessionPro();
    // await mockUserSessionProductionDCL();
    // await mockUserSessionProductionTest();
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  bool isMobile() {
    return Platform.isAndroid || Platform.isIOS;
  }

  void handleStateChanges(NativeLoginState state) {
    if (state is NativeLoginSucess) {
      userManager.login(state.userInfo);
      coordinator.showHome(env);
    }
  }

  @override
  Future<void> move(NavID to) async {
    switch (to) {
      case NavID.nativeSignin:
        if (isMobile()) {
          coordinator.showNativeSignin(env);
        } else {
          coordinator.showFlutterSignin(env);
        }
        break;
      case NavID.nativeSignup:
        if (isMobile()) {
          coordinator.showNativeSignup(env);
        } else {
          await mockUserSession();
          coordinator.showHome(env);
        }
        break;
      default:
        break;
    }
  }
}
