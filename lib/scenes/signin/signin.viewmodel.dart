import 'dart:async';

import 'package:wallet/constants/app.config.dart';
import 'package:wallet/constants/env.dart';
import 'package:wallet/managers/user.manager.dart';
import 'package:wallet/models/native.session.model.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/signin/signin.coordinator.dart';

abstract class SigninViewModel extends ViewModel<SigninCoordinator> {
  SigninViewModel(super.coordinator);

  Future<String> signIn(String username, String password);
}

class SigninViewModelImpl extends SigninViewModel {
  final UserManager userManager;

  SigninViewModelImpl(super.coordinator, this.userManager);

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

  // bool _isMobile() {
  //   return Platform.isAndroid || Platform.isIOS;
  // }

  @override
  Future<void> move(NavID to) async {
    switch (to) {
      case NavID.nativeSignin:
      // if (_isMobile()) {
      //   coordinator.showNativeSignin(env);
      // } else {
      //   coordinator.showHome(env);
      // }
        break;
      case NavID.nativeSignup:
      // if (_isMobile()) {
      //   coordinator.showNativeSignup(env);
      // } else {
      //   coordinator.showHome(env);
      // }
        break;
      case NavID.home:
        coordinator.showHome(env);
      default:
        break;
    }
  }

  @override
  Future<String> signIn(String username, String password) async {
    await mockLogin();
    move(NavID.home);
    return "Error message";
  }

  Future<void> mockLogin() async {
    // TODO:: set userInfo by flutter login result
    UserInfo userInfo = UserInfo(
        userId: "vJxErOgAzrqjwPfvjlhAoDVPoXbDl2URUzd15JcQNwggW6bkwd70KNWozrMpV_d21FITkNqnMAY5WRxwAGclng==",
        userMail: "proton.wallet.test@proton.me",
        userName: "proton.wallet.test",
        userDisplayName: "proton.wallet.test",
        sessionId: "ln226u3gf64fkgpcm2nzb3dd45x6ksl5",
        accessToken: "kqoyuczzfpoem7phteqx6ctpdtjp2tz2",
        refreshToken: "rrxkxzjaenjtw5d2nowwjxagfnrhnkuh",
        scopes: "full,locked,self,payments,keys,parent,user,loggedin,nondelinquent,verified,settings,wallet",
        userKeyID: "54DY3FZ-inMbCA6beQINReu6ziXMErdTiKgmCvATLXJtNGQx9BNo8Iggbgk5IKAXhBOrEWWeq5YcJA6pCvOTDQ==",
        userPrivateKey: '''-----BEGIN PGP PRIVATE KEY BLOCK-----
Version: ProtonMail

xYYEZjhFYhYJKwYBBAHaRw8BAQdAKOpjdQebm9WlooZt2G9JKNlG5P5PPUaq
REgwU+CCVun+CQMIoFofa5ScVDpgYsI1CvjZgu+c3flIRbhJarhtCh54CgIb
pwRh5nwFXNU5EgZxjvLcVXA4rqPdOlelzr3kJSED8c8EwmR7LsiW6OOm6QJW
is07cHJvdG9uLndhbGxldC50ZXN0QHByb3Rvbi5tZSA8cHJvdG9uLndhbGxl
dC50ZXN0QHByb3Rvbi5tZT7CjwQTFggAQQUCZjhFYgkQzqILddLh6gEWIQRN
uUuhzHdGsokjULHOogt10uHqAQIbAwIeAQIZAQMLCQcCFQgDFgACBScJAgcC
AAC+iAD/dd+IhJUoYXQw/aX6BjUtpuxmI0f7kdffcGkGUhVcmiUA/2+O530i
G2n6+xWEfRZzL8hzMu5b5G55qF9WAz3zit4Ox4sEZjhFYhIKKwYBBAGXVQEF
AQEHQHJgB/lGIegRyHjT4OmAImgNcthZc25E56E+kLMj6BBjAwEKCf4JAwiP
0WVmGj71iGDiW0v+ZLFBxUX/8FPLJARdpt3FyEp4QNA7r8by+lNSMVXvnyF0
1VzY972K3H8mnTJPxRageYVMKzjDz9gnrZ0gNZ+6vas/wngEGBYIACoFAmY4
RWIJEM6iC3XS4eoBFiEETblLocx3RrKJI1CxzqILddLh6gECGwwAADXoAP92
fL7PqtDaE/W5tPRukb6NCYRbj2XnPVOs4tRQLUpsRQEA/Lk7PN4BuBvmoUuy
KLmodk0w/yzCywNMXBerDlzf4Qk=
=uf/1
-----END PGP PRIVATE KEY BLOCK-----''',
        userPassphrase: "2aEvGTaaoCTk0C7DTgRyFHmfx9t6l62");
    await userManager.login(userInfo);
  }
}
