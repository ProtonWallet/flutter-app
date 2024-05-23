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
        sessionId: "np5rpe76pk7w5ohirowoqvo4k6lqakse",
        accessToken: "nwlmo67dmuaikx6f3bhf77ucwsqwkqmj",
        refreshToken: "55lznzxlo27evjtg7iitap5wfoc4b6yo",
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


  Future<void> mockLoginAtlasPro() async {
    // TODO:: set userInfo by flutter login result
    UserInfo userInfo = UserInfo(
        userId: "ffdya2Juf_4GYwZXDpM4A7Dz9BIRTj2JzUxtli9qvIgm3cA0eOCRk9sCEGti3ReMhJ8rSgmXN7xZRa8f7V04ZQ==",
        userMail: "pro@proton.me",
        userName: "pro",
        userDisplayName: "pro",
        sessionId: "p6yo5o44ldcnnhtwyfbq6naapwa3w4xm",
        accessToken: "6vu3yypjibcwiui5wmp3pla72g3qxjgp",
        refreshToken: "aar43d4vx5ys64z2xohbnu5ls33nqvb5",
        scopes: "full,locked,self,payments,keys,parent,user,loggedin,nondelinquent,verified,settings,wallet",
        userKeyID: "4Xi8TArBe1WYfrFoJF5_wIDF0shMe5ACAqOArU6hjpUNoC0O0c_Zu5Afz11gGU1eeDu5Aanp_EUkpd44kjQ2lg==",
        userPrivateKey: '''-----BEGIN PGP PRIVATE KEY BLOCK-----
Version: ProtonMail

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
ydJHDOOvI+zz/2tadhbwT6A=
=GaA/
-----END PGP PRIVATE KEY BLOCK-----''',
        userPassphrase: "75bOe1zUf192xooCCVzSdi1lE1yoFlC");
    await userManager.login(userInfo);
  }
}
