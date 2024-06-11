import 'dart:async';

import 'package:wallet/constants/app.config.dart';
import 'package:wallet/constants/env.dart';
import 'package:wallet/helper/extension/stream.controller.dart';
import 'package:wallet/managers/channels/native.view.channel.dart';
import 'package:wallet/managers/channels/platform.channel.state.dart';
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
  final NativeViewChannel nativeChannel;
  final UserManager userManager;
  final DataProviderManager dataProviderManager;

  WelcomeViewModelImpl(
    super.coordinator,
    this.nativeChannel,
    this.userManager,
    this.dataProviderManager,
  );

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
    // welcome start send event to native for
    env = appConfig.apiEnv;
    _subscription = nativeChannel.stream.listen(handleStateChanges);

    // PackageInfo packageInfo = await PackageInfo.fromPlatform();
    // setState(() {
    //   _appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
    // });
    datasourceChangedStreamController.sinkAddSafe(this);
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  Future<void> handleStateChanges(NativeLoginState state) async {
    if (state is NativeLoginSucess) {
      await userManager.nativeLogin(state.userInfo);
      await dataProviderManager.login(state.userInfo.userId);
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
        break;
      case NavID.nativeSignup:
        if (mobile) {
          coordinator.showNativeSignup();
        }
        break;
      default:
        break;
    }
  }
}
