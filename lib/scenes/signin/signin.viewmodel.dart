import 'dart:async';

import 'package:wallet/constants/app.config.dart';
import 'package:wallet/constants/env.dart';
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
  final UserManager userManager;
  final ProtonApiService apiService;

  SigninViewModelImpl(super.coordinator, this.userManager, this.apiService);

  bool hadLocallogin = false;
  final datasourceChangedStreamController =
      StreamController<SigninViewModel>.broadcast();

  late ApiEnv env;

  @override
  void dispose() {
    datasourceChangedStreamController.close();
  }

  @override
  Future<void> loadData() async {
    env = appConfig.apiEnv;
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  @override
  Future<void> move(NavID to) async {
    switch (to) {
      case NavID.nativeSignin:
        break;
      case NavID.nativeSignup:
        break;
      case NavID.home:
        coordinator.showHome(env);
      default:
        break;
    }
  }

  @override
  Future<void> signIn(String username, String password) async {
    try {
      var authCredential =
          await apiService.login(username: username, password: password);
      userManager.flutterLogin(authCredential);
      coordinator.showHome(env);
    } catch (e) {
      errorMessage = e.toString();
      datasourceChangedStreamController.add(this);
    }
  }
}
