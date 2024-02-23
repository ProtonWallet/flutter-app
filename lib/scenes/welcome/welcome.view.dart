import 'dart:convert';

import 'package:flutter_gen/gen_l10n/locale.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wallet/channels/platform.channel.dart';
import 'package:wallet/components/backgroud.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/helper/local_toast.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/helper/secure_storage_helper.dart';
import 'package:wallet/helper/user.session.dart';
import 'package:wallet/network/api.helper.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/welcome/signup.button.dart';
import 'package:wallet/scenes/welcome/welcome.viewmodel.dart';
import 'package:wallet/scenes/welcome/welcome.image.dart';

class WelcomeView extends ViewBase<WelcomeViewModel> {
  WelcomeView(WelcomeViewModel viewModel)
      : super(viewModel, const Key("WelcomeView"));

  static const _appChannel = MethodChannel('com.example.wallet/app.view');

  // TODO:: move the logics to Viewmodel
  Future<void> loginResume() async {
    // TODO:: test this logic
    if (await SecureStorageHelper.get("sessionId") != "") {
      if (context.mounted) {
        UserSessionProvider userSessionProvider =
            Provider.of<UserSessionProvider>(context, listen: false);
        userSessionProvider.login(
            await SecureStorageHelper.get("userId"),
            await SecureStorageHelper.get("userMail"),
            await SecureStorageHelper.get("userName"),
            await SecureStorageHelper.get("userDisplayName"),
            await SecureStorageHelper.get("sessionId"),
            await SecureStorageHelper.get("accessToken"),
            await SecureStorageHelper.get("refreshToken"),
            await SecureStorageHelper.get("userKeyID"),
            await SecureStorageHelper.get("userPrivateKey"),
            await SecureStorageHelper.get("userPassphrase"));
        APIHelper.init(
            userSessionProvider.userSession.accessToken,
            userSessionProvider.userSession.sessionId,
            userSessionProvider.userSession.userKeyID);
        if (context.mounted) {
          viewModel.coordinator.move(ViewIdentifiers.home, context);
        }
      }
    }
  }

  void mockUserSession() {
    // TODO:: remove test use code
    UserSessionProvider userSessionProvider =
        Provider.of<UserSessionProvider>(context, listen: false);
    Map userInfo = {};
    userSessionProvider.login(
        userInfo["userId"] ??
            "ffdya2Juf_4GYwZXDpM4A7Dz9BIRTj2JzUxtli9qvIgm3cA0eOCRk9sCEGti3ReMhJ8rSgmXN7xZRa8f7V04ZQ==",
        userInfo["userMail"] ?? "ProtonWallet@proton.black",
        userInfo["userName"] ?? "ProtonWallet",
        userInfo["userDisplayName"] ?? "ProtonWallet",
        userInfo["sessionId"] ?? "pkjgxebzpgdeyeksokpipddbck3grij6",
        userInfo["accessToken"] ?? "2k5g2moktwrolyo4bvug3rqxzej6jfge",
        userInfo["refreshToken"] ?? "5p5shsj77okrd5wzskikwbpj7ljl7sy7",
        userInfo["userKeyID"] ??
            "tFiIeutJ52NsS8DN3lIExFV1mbg8_prfetgeerv-wsxoAJMqibBO373Pft0ZQQ1XF9qKPo-EaWjYijYNUoU9pQ==",
        userInfo["userPrivateKey"] ??
            '''-----BEGIN PGP PRIVATE KEY BLOCK-----
Version: ProtonMail

xYYEZcHI+hYJKwYBBAHaRw8BAQdAP95X+OxFf4BIZ6pVof0uGieuTrnlpxOn
07kbnarFd9n+CQMIbH/7cYVS4IJg2yUdFVTAyfaM0gVEeMzGCM8+ZUPe6/qF
AsMkTKFXYSvwwsjw/NwmCGxUGRlbOQilIHhrxRcgNnVZWM9vs+xlt1CUGRJL
NM07bm90X2Zvcl9lbWFpbF91c2VAZG9tYWluLnRsZCA8bm90X2Zvcl9lbWFp
bF91c2VAZG9tYWluLnRsZD7CjAQQFgoAPgWCZcHI+gQLCQcICZC3N9EM+mvd
VwMVCAoEFgACAQIZAQKbAwIeARYhBOkPJufu+pzcnwymRLc30Qz6a91XAAAL
6wD9EMH2oS2Eud7JNoslh8xWac9bT15sUUmGBgwMSWxfyW8A/jb7ubVOBoQv
l0FQpevuWScbCwsNXI97l7j623a+f54Px4sEZcHI+hIKKwYBBAGXVQEFAQEH
QLEg5FwJpuFkUcZlNwrgUL8pqm6tQP5H03kHrlEaRUZpAwEIB/4JAwhObU5t
fQYriWAIzA7e3ZNHBa4Q2LHwxZUz3ACTwua2SXZ5OxD0Io4jFkxiTuETIOnl
LFQzHg+VVXcdEno56hjnsqHFFB7M94bsNjIImFoNwngEGBYKACoFgmXByPoJ
kLc30Qz6a91XApsMFiEE6Q8m5+76nNyfDKZEtzfRDPpr3VcAAAQ2AQCQOIGC
yNzZ8VU8OLu4uKi/U/uQBUcvW5z8W/QkfMiFCwEAm35gvMJB1ScmKCFJNI0t
PguJGsxgNW6mwkszNjYfCQY=
=xVXK
-----END PGP PRIVATE KEY BLOCK-----''',
        userInfo["userPassphrase"] ?? "4sFlJ8gesYLeYyS0cBFQ5biAZPIZyHe");
    APIHelper.init(
        userSessionProvider.userSession.accessToken,
        userSessionProvider.userSession.sessionId,
        userSessionProvider.userSession.userKeyID);
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'flutter.navigation.to.home':
        String data = call.arguments;
        logger.d("Data received from Swift: $data");
        Map<String, dynamic> userInfo = json.decode(data);
        UserSessionProvider userSessionProvider =
            Provider.of<UserSessionProvider>(context, listen: false);
        if (userInfo.containsKey("sessionId") && userInfo["sessionId"] != "") {
          userSessionProvider.login(
              userInfo["userId"] ?? "",
              userInfo["userMail"] ?? "",
              userInfo["userName"] ?? "",
              userInfo["userDisplayName"] ?? "",
              userInfo["sessionId"] ?? "",
              userInfo["accessToken"] ?? "",
              userInfo["refreshToken"] ?? "",
              userInfo["userKeyID"] ?? "",
              userInfo["userPrivateKey"] ?? "",
              userInfo["userPassphrase"] ?? "");
          APIHelper.init(
              userSessionProvider.userSession.accessToken,
              userSessionProvider.userSession.sessionId,
              userSessionProvider.userSession.userKeyID);
          viewModel.coordinator.move(ViewIdentifiers.home, context);
        } else {
          LocalToast.showErrorToast(context, S.of(context).login_failed);
        }
        break;
      default:
        throw PlatformException(
            code: 'Unimplemented',
            details: 'Method ${call.method} is not implemented.');
    }
  }

  @override
  Widget buildWithViewModel(
      BuildContext context, WelcomeViewModel viewModel, ViewSize viewSize) {
    _appChannel.setMethodCallHandler(_handleMethodCall);
    viewModel.localLogin(context);
    switch (viewSize) {
      case ViewSize.mobile:
        return buildMobile(context);
      default:
        return buildDesktop(context);
    }
  }

  Widget buildDesktop(BuildContext context) {
    return Background(
      child: SingleChildScrollView(
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Expanded(
                child: WelcomeImage(),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 450,
                      child: LoginAndSignupBtn(),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: 450,
                      child: ElevatedButton(
                        onPressed: () {
                          mockUserSession();
                          viewModel.coordinator
                              .move(ViewIdentifiers.home, context);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6D4AFF),
                            elevation: 0),
                        child: Text(
                          S.of(context).go_home.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMobile(BuildContext context) {
    return Background(
      child: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const WelcomeImage(),
              SizedBox(
                width: 300,
                child: ButtonV5(
                    text: S.of(context).create_account,
                    onPressed: () {
                      NativeViewSwitcher.switchToNativeSignup();
                    },
                    width: 300,
                    height: 48),
              ),
              SizedBoxes.box12,
              SizedBox(
                width: 300,
                child: CupertinoButton(
                  onPressed: () {
                    NativeViewSwitcher.switchToNativeLogin();
                  },
                  child: Text(S.of(context).sign_in),
                ),
              ),
              SizedBoxes.box8,
              CupertinoButton(
                onPressed: () {
                  mockUserSession();
                  viewModel.coordinator.move(ViewIdentifiers.home, context);
                },
                color: ProtonColors.interactionNorm,
                child: Text(S.of(context).go_home),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
