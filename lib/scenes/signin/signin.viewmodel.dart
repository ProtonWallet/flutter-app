import 'dart:async';

import 'package:wallet/constants/app.config.dart';
import 'package:wallet/constants/env.dart';
import 'package:wallet/managers/app.state.manager.dart';
import 'package:wallet/managers/manager.factory.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/rust/api/api_service/proton_api_service.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/signin/signin.coordinator.dart';

abstract class SigninViewModel extends ViewModel<SigninCoordinator> {
  SigninViewModel(super.coordinator);

  Future<void> signIn(String username, String password);

  String errorMessage = "";
}

class SigninViewModelImpl extends SigninViewModel {
  final ManagerFactory serviceManager;
  final UserManager userManager;
  final AppStateManager appStateManger;
  final ProtonApiService apiService;
  final DataProviderManager dataProviderManager;

  SigninViewModelImpl(
    super.coordinator,
    this.userManager,
    this.apiService,
    this.dataProviderManager,
    this.appStateManger,
    this.serviceManager,
  );

  bool hadLocallogin = false;

  late ApiEnv env;

  @override
  Future<void> loadData() async {
    env = appConfig.apiEnv;
  }

  @override
  Future<void> move(NavID to) async {
    switch (to) {
      case NavID.nativeSignin:
        break;
      case NavID.nativeSignup:
        break;
      case NavID.home:
        break;
      default:
        break;
    }
  }

  @override
  Future<void> signIn(String username, String password) async {
    try {
      final authCredential = await apiService.login(
        username: username,
        password: password,
      );
      userManager.flutterLogin(authCredential);
      await serviceManager.login(authCredential.userId);
      coordinator.showHome(env);
    } catch (e) {
      errorMessage = e.toString();
      sinkAddSafe();
    }
  }
}
