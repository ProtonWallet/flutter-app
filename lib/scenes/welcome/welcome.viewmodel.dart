import 'dart:async';

import 'package:wallet/constants/app.config.dart';
import 'package:wallet/constants/env.dart';
import 'package:wallet/managers/app.state.manager.dart';
import 'package:wallet/managers/channels/native.view.channel.dart';
import 'package:wallet/managers/channels/platform.channel.state.dart';
import 'package:wallet/managers/manager.factory.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/welcome/welcome.coordinator.dart';

abstract class WelcomeViewModel extends ViewModel<WelcomeCoordinator> {
  WelcomeViewModel(super.coordinator);

  bool initialized = false;
  String appVersion = '';
}

class WelcomeViewModelImpl extends WelcomeViewModel {
  final ManagerFactory serviceManager;
  final NativeViewChannel nativeChannel;
  final UserManager userManager;
  final AppStateManager appStateManger;
  final DataProviderManager dataProviderManager;

  WelcomeViewModelImpl(
    super.coordinator,
    this.nativeChannel,
    this.userManager,
    this.dataProviderManager,
    this.appStateManger,
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
    // welcome start send event to native for
    env = appConfig.apiEnv;
    _subscription = nativeChannel.stream.listen(handleStateChanges);
    // PackageInfo packageInfo = await PacageInfo.fromPlatform();
    // setState(() {
    //   _appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
    // });
    sinkAddSafe();
  }

  Future<void> handleStateChanges(NativeLoginState state) async {
    if (state is NativeLoginSucess) {
      await userManager.nativeLogin(state.userInfo);
      await serviceManager.login(state.userInfo.userId);
      coordinator.showHome(env);
    }
  }

  @override
  Future<void> move(NavID to) async {
    switch (to) {
      case NavID.nativeSignin:
        if (mobile) {
          coordinator.showNativeSignin();
        } else {
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
