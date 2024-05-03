import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wallet/constants/app.config.dart';
import 'package:wallet/constants/env.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/helper/secure_storage_helper.dart';
import 'package:wallet/helper/user.session.dart';
import 'package:wallet/network/api.helper.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/welcome/welcome.coordinator.dart';

abstract class WelcomeViewModel extends ViewModel<WelcomeCoordinator> {
  WelcomeViewModel(super.coordinator);
}

class WelcomeViewModelImpl extends WelcomeViewModel {
  WelcomeViewModelImpl(super.coordinator);
  static const _appChannel = MethodChannel('com.example.wallet/app.view');

  late UserSessionProvider userSessionProvider;

  bool hadLocallogin = false;
  final datasourceChangedStreamController =
      StreamController<WelcomeViewModel>.broadcast();

  late ApiEnv env;

  @override
  void dispose() {
    _appChannel.setMethodCallHandler(null);
    datasourceChangedStreamController.close();
  }

  Future<void> _localLogin() async {
    if (!hadLocallogin) {
      hadLocallogin = true;
      if (await SecureStorageHelper.instance.get("sessionId") != "") {
        // need also check if current session is same env with current env

        loginResume();
        // LocalAuth.authenticate("Authenticate to login").then((auth) {
        //   if (auth) {
        //     ((coordinator).widget as WelcomeView).loginResume();
        //   }
        // });
      } else {
        _appChannel.setMethodCallHandler(_handleMethodCall);
      }
    }
  }

  @override
  Future<void> loadData() async {
    env = appConfig.apiEnv;
    userSessionProvider = Provider.of<UserSessionProvider>(
        Coordinator.navigatorKey.currentContext!);
    _localLogin();
  }

  Future<void> loginResume() async {
    if (await SecureStorageHelper.instance.get("sessionId") != "") {
      await userSessionProvider.login(
          userId: await SecureStorageHelper.instance.get("userId"),
          userMail: await SecureStorageHelper.instance.get("userMail"),
          userName: await SecureStorageHelper.instance.get("userName"),
          userDisplayName:
              await SecureStorageHelper.instance.get("userDisplayName"),
          sessionId: await SecureStorageHelper.instance.get("sessionId"),
          accessToken: await SecureStorageHelper.instance.get("accessToken"),
          refreshToken: await SecureStorageHelper.instance.get("refreshToken"),
          scopes: await SecureStorageHelper.instance.get("scopes"),
          userKeyID: await SecureStorageHelper.instance.get("userKeyID"),
          userPrivateKey:
              await SecureStorageHelper.instance.get("userPrivateKey"),
          userPassphrase:
              await SecureStorageHelper.instance.get("userPassphrase"));
      APIHelper.init(
          userSessionProvider.userSession.accessToken,
          userSessionProvider.userSession.sessionId,
          userSessionProvider.userSession.userKeyID);
      coordinator.showHome(env);
    }
  }

  Future<void> mockUserSession() async {
    await mockUserSessionPro();
    // await mockUserSessionQQQQ();
    // await mockUserSessionCCCC();
  }

  Future<void> mockUserSessionCCCC() async {
    Map userInfo = {};
    await userSessionProvider.login(
        userId: userInfo["userId"] ??
            "HB_29cAPkhaWhZsCRwCGuGP5nRajOpeP8wZK3QisI6IGODOgIuRf4-hAMEypQoorfzWw3aby3eYjeUhE2Ou6cw==",
        userMail: userInfo["userMail"] ?? "cccc@pascal.proton.black",
        userName: userInfo["userName"] ?? "cccc",
        userDisplayName: userInfo["userDisplayName"] ?? "cccc",
        sessionId: userInfo["sessionId"] ?? "q6kuz2imdqjvfpmxdhzgslo6qxmkbgeu",
        accessToken:
            userInfo["accessToken"] ?? "3232uoliqe4dm3itautb2rikqvudcalx",
        refreshToken:
            userInfo["refreshToken"] ?? "yt7eq6cuy6rmbaspbwy6ip4gkltxkeo5",
        scopes: userInfo["scopes"] ?? "full",
        userKeyID: userInfo["userKeyID"] ??
            "iQB00Kq8ksPAMdCj2rTtlyC8CUvNPU5agboi_RvJ2-qdBCvzmd4XiEG_GM8B0QdMxiyZ-zV6i9kGD3nRkBXg_Q==",
        userPrivateKey: userInfo["userPrivateKey"] ??
            '''-----BEGIN PGP PRIVATE KEY BLOCK-----
Version: ProtonMail

xYYEZh8vLBYJKwYBBAHaRw8BAQdAb8nsiRniLK9rBRXyNmNDmpwJvWrtKHUy
MJM6g9pjy4L+CQMIzgH1JpmKeEJguTP8ESYuiGx5FuPPAXrDVYXAFMc0vP+2
DtLGJ8SyZa7MPY1zJcHKoMVusdcZCRZzXwOnN1ls6Q1x0Ojez8nl/ZHE//Ww
tM0zY2NjY0BoaXJhc2UucHJvdG9uLmJsYWNrIDxjY2NjQGhpcmFzZS5wcm90
b24uYmxhY2s+wo8EExYIAEEFAmYfLywJENTN8DLoTpYIFiEESV6CU97te5IU
3Ill1M3wMuhOlggCGwMCHgECGQEDCwkHAhUIAxYAAgUnCQIHAgAAdkcBALbd
xZJ8Y2H+dZJPbTS76OhwvSIEgKU1rbCWGq0NaDgfAQCLRht9mnaf9rDEkLAR
Ov0wXNgxB7Rz7qFJt269y6AKAseLBGYfLywSCisGAQQBl1UBBQEBB0DwnBIr
Ubjckd87OZBDchvHqI0lkEHcp+ZHyoRsV4ojJQMBCgn+CQMImIHnTPe3LOVg
dpsEAs7us1DMEKW6gYgjC5ea9UJHXRL8PYHJ9LLPNuLCFkBReUw18ukEcBm1
RIk7y3YZ48CxQDVkxs2L7w3/K7E7ucn/X8J4BBgWCAAqBQJmHy8sCRDUzfAy
6E6WCBYhBEleglPe7XuSFNyJZdTN8DLoTpYIAhsMAAAItgEAm92peQYizaA1
g9/DR6nEUw4EcGUk0g5IgZlmw/6xiW4A/3O4VTY3MfMZQEXzu69P7bJ/sT0C
T6hEc59huSerA/AE
=OS/z
-----END PGP PRIVATE KEY BLOCK-----''',
        userPassphrase:
            userInfo["userPassphrase"] ?? "8kfjLdo84fFCg94AhrnZbMzsHn1SL/S");
    APIHelper.init(
        userSessionProvider.userSession.accessToken,
        userSessionProvider.userSession.sessionId,
        userSessionProvider.userSession.userKeyID);
  }

  Future<void> mockUserSessionQQQQ() async {
    Map userInfo = {};
    await userSessionProvider.login(
        userId: userInfo["userId"] ??
            "G3ttUCkgf5731XGaCbugQ4e_3iDlc6oGfz5Ene78PmAf5RLQcZQ0r9BsOelSU_RIivzzpV1p5WYMgklcBdm-aA==",
        userMail: userInfo["userMail"] ?? "qqqq@pascal.proton.black",
        userName: userInfo["userName"] ?? "qqqq",
        userDisplayName: userInfo["userDisplayName"] ?? "qqqq",
        sessionId: userInfo["sessionId"] ?? "q6kuz2imdqjvfpmxdhzgslo6qxmkbgeu",
        accessToken:
            userInfo["accessToken"] ?? "3232uoliqe4dm3itautb2rikqvudcalx",
        refreshToken:
            userInfo["refreshToken"] ?? "yt7eq6cuy6rmbaspbwy6ip4gkltxkeo5",
        scopes: userInfo["scopes"] ?? "full",
        userKeyID: userInfo["userKeyID"] ??
            "PgAdNsuQAuUp2i8uJbMXLTrXol5VCgml_lFqEBtjyayHScOjI6hqP_Xr5hrog6FvUsrQO1MNV0ym-e-SzAZ0jQ==",
        userPrivateKey: userInfo["userPrivateKey"] ??
            '''-----BEGIN PGP PRIVATE KEY BLOCK-----
Version: ProtonMail

xYYEZhzI3hYJKwYBBAHaRw8BAQdAkUyUhAs+tlJ1LBxFMv/aQKRzUddHr45M
21O/MUiXTXv+CQMIQCmstOCpoh9g9xO1fbetUjBgH/aO7CPhyGFr81Aw3ivg
YMcvylJg6Xkjq/X1Y1yJ0n+zy48Z146GZouk6dprku2ayd7cyEyaN4WFHTuK
uM0zcXFxcUBqZW5uZXIucHJvdG9uLmJsYWNrIDxxcXFxQGplbm5lci5wcm90
b24uYmxhY2s+wo8EExYIAEEFAmYcyN4JEDR0JLtF/00cFiEEjyTjumBSE+mp
iFR2NHQku0X/TRwCGwMCHgECGQEDCwkHAhUIAxYAAgUnCQIHAgAAQn8A/12i
9Sx5D3AFgznEc1E2tPf0RytBht9qMcuyPjK4GJZZAQCi7+pSvvXoaeMP5CE0
jfYyk6VF/LtYYYwCRmBV5gcUBMeLBGYcyN4SCisGAQQBl1UBBQEBB0C8ccC+
9BBauDcW2/g8/2CMsXSINn66Ut6BdXeX3jWDSwMBCgn+CQMIHnvBYbVKQN9g
ljaAoaotsrftCCUIpe0nTdHSlEDZpnL0pJcrnp7YR4WNnaoZAuh8F+7mhJLx
ITyYDemUV+miag9KBFAfoSYIlNIx5ik6T8J4BBgWCAAqBQJmHMjeCRA0dCS7
Rf9NHBYhBI8k47pgUhPpqYhUdjR0JLtF/00cAhsMAADC0wEAub+gjx6+h05s
+MiG8742805q061G7RGxW++x28OeZL4BAMPo1tshEAbK7h4kfy+c7gnTVmP7
F24EdYKKQW+rWlkP
=8SuV
-----END PGP PRIVATE KEY BLOCK-----''',
        userPassphrase:
            userInfo["userPassphrase"] ?? "8kfjLdo84fFCg94AhrnZbMzsHn1SL/S");
    APIHelper.init(
        userSessionProvider.userSession.accessToken,
        userSessionProvider.userSession.sessionId,
        userSessionProvider.userSession.userKeyID);
  }

  Future<void> mockUserSessionPro() async {
    Map userInfo = {};
    await userSessionProvider.login(
        userId: userInfo["userId"] ??
            "ffdya2Juf_4GYwZXDpM4A7Dz9BIRTj2JzUxtli9qvIgm3cA0eOCRk9sCEGti3ReMhJ8rSgmXN7xZRa8f7V04ZQ==",
        userMail: userInfo["userMail"] ?? "ProtonWallet@pascal.proton.black",
        userName: userInfo["userName"] ?? "ProtonWallet",
        userDisplayName: userInfo["userDisplayName"] ?? "ProtonWallet",
        sessionId: userInfo["sessionId"] ?? "q6kuz2imdqjvfpmxdhzgslo6qxmkbgeu",
        accessToken:
            userInfo["accessToken"] ?? "3232uoliqe4dm3itautb2rikqvudcalx",
        refreshToken:
            userInfo["refreshToken"] ?? "yt7eq6cuy6rmbaspbwy6ip4gkltxkeo5",
        scopes: userInfo["scopes"] ?? "full",
        userKeyID: userInfo["userKeyID"] ??
            "4Xi8TArBe1WYfrFoJF5_wIDF0shMe5ACAqOArU6hjpUNoC0O0c_Zu5Afz11gGU1eeDu5Aanp_EUkpd44kjQ2lg==",
        userPrivateKey: userInfo["userPrivateKey"] ??
            '''-----BEGIN PGP PRIVATE KEY BLOCK-----
Version: ProtonMail

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
ydJHDOOvI+zz/2tadhbwT6A=
=GaA/
-----END PGP PRIVATE KEY BLOCK-----''',
        userPassphrase:
            userInfo["userPassphrase"] ?? "75bOe1zUf192xooCCVzSdi1lE1yoFlC");
    APIHelper.init(
        userSessionProvider.userSession.accessToken,
        userSessionProvider.userSession.sessionId,
        userSessionProvider.userSession.userKeyID);
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  bool _isMobile() {
    return Platform.isAndroid || Platform.isIOS;
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'flutter.navigation.to.home':
        String data = call.arguments;
        logger.d("Data received from Swift: $data");
        Map<String, dynamic> userInfo = json.decode(data);
        if (userInfo.containsKey("sessionId") && userInfo["sessionId"] != "") {
          await userSessionProvider.login(
              userId: userInfo["userId"] ?? "",
              userMail: userInfo["userMail"] ?? "",
              userName: userInfo["userName"] ?? "",
              userDisplayName: userInfo["userDisplayName"] ?? "",
              sessionId: userInfo["sessionId"] ?? "",
              accessToken: userInfo["accessToken"] ?? "",
              refreshToken: userInfo["refreshToken"] ?? "",
              scopes: userInfo["scopes"] ?? "",
              userKeyID: userInfo["userKeyID"] ?? "",
              userPrivateKey: userInfo["userPrivateKey"] ?? "",
              userPassphrase: userInfo["userPassphrase"] ?? "");
          logger.i("accessToken = ${userSessionProvider.userSession.accessToken}");
          logger.i("sessionId = ${userSessionProvider.userSession.sessionId}");
          logger.i("userKeyID = ${userSessionProvider.userSession.userKeyID}");
          logger.i("refreshToken = ${userSessionProvider.userSession.refreshToken}");
          logger.i("userPrivateKey = ${userSessionProvider.userSession.userPrivateKey}");
          logger.i("userPassphrase = ${userSessionProvider.userSession.userPassphrase}");
          await SecureStorageHelper.instance
              .set("appVersion", userInfo["appVersion"] ?? "");
          await SecureStorageHelper.instance
              .set("userAgent", userInfo["userAgent"] ?? "");
          APIHelper.init(
              userSessionProvider.userSession.accessToken,
              userSessionProvider.userSession.sessionId,
              userSessionProvider.userSession.userKeyID);
          // EasyLoading.show(
          //       status: "login..", maskType: EasyLoadingMaskType.black);
          // await Future.delayed(const Duration(seconds: 5));
          // EasyLoading.dismiss();
          // await NativeViewSwitcher.restartNative();
          //
          // await Future.delayed(const Duration(seconds: 5));
          // EasyLoading.dismiss();
          coordinator.showHome(env);
        } else {
          // LocalToast.showErrorToast(context, S.of(context).login_failed);
        }
        break;
      default:
        throw PlatformException(
            code: 'Unimplemented',
            details: 'Method ${call.method} is not implemented.');
    }
  }

  @override
  void move(NavigationIdentifier to) {
    switch (to) {
      case ViewIdentifiers.nativeSignin:
        if (_isMobile()) {
          coordinator.showNativeSignin(env);
        } else {
          mockUserSession();
          coordinator.showHome(env);
        }
        break;
      case ViewIdentifiers.nativeSignup:
        if (_isMobile()) {
          coordinator.showNativeSignup(env);
        } else {
          mockUserSession();
          coordinator.showHome(env);
        }
        break;
    }
  }
}
