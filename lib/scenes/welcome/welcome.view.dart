import 'dart:convert';

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
import 'package:wallet/network/api.helper.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/welcome/signup.button.dart';
import 'package:wallet/scenes/welcome/welcome.viewmodel.dart';
import 'package:wallet/scenes/welcome/welcome.image.dart';

import '../../helper/user.session.dart';

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
        userInfo["sessionId"] ?? "zq575ffcf32xmlqcl3h657ntlltsu2cm",
        userInfo["accessToken"] ?? "osxl4zajfnxvr5s5ljxjwq5v3itqbk3x",
        userInfo["refreshToken"] ?? "c23vayrxwnhiyne6tmsz2jhztw6a7ffg",
        userInfo["userKeyID"] ??
            "j_rkbyAESrnaOvhBHmCD5X-J0YzvaGW6x2pM3BSR8v34q_wrvFYFi6rod6JxmQ0VlZS4-qVKBRGLnqOSJV4MaA==",
        userInfo["userPrivateKey"] ?? '''-----BEGIN PGP PRIVATE KEY BLOCK-----
Version: ProtonMail

xYYEZa424xYJKwYBBAHaRw8BAQdAzOjoPpNo11uWEwg8f1zVeJeFOTaZ64l0
YlntRsRf9Zj+CQMIUj1rfyZGy4tgfz3+t29XTnQIc/7/wTkJzTRFfz5k/3TP
875/yVCn/LYg9Vy3FLMMcixhrH0KAQWuA41UX1Ffiqlu88Bwv33rbj6b/xVS
Gc01UHJvdG9uV2FsbGV0QHByb3Rvbi5ibGFjayA8UHJvdG9uV2FsbGV0QHBy
b3Rvbi5ibGFjaz7CjwQTFggAQQUCZa424wkQznO5oB54VSAWIQTbuvQeXaY/
zBo9rZzOc7mgHnhVIAIbAwIeAQIZAQMLCQcCFQgDFgACBScJAgcCAAB9pwEA
5cDC5r/QrnIlkr8xJUAOse2JqvEOhsFef2g46Lmo3dMBAPWIhyLzPy1CkP/V
uWPF0iIDwGaKa3u7uIF331kBWMoLx4sEZa424xIKKwYBBAGXVQEFAQEHQLTJ
k0mE6UM7J2gVR4XoAk0fud9dX5DQn2N/0cT4sCYrAwEKCf4JAwi6M/RSTQed
V2BSqFH+IKUV9IvwXWE3LSB8tx7e11kW+E9o5QRq5MdHTs1qF1pnUiTPTMeo
EnTer97/Jnjp1CCiEFZP85HQOO9NVKk9QDoIwngEGBYIACoFAmWuNuMJEM5z
uaAeeFUgFiEE27r0Hl2mP8waPa2cznO5oB54VSACGwwAAJlZAP0QYjT9glxj
ROPOOJcfggwp5HI1PjMNGreNKPo6BmTwNAD/XlgtiutzElIMp0uTokeTae7N
M3bzanKu/hKuhAM3kgw=
=I2GF
-----END PGP PRIVATE KEY BLOCK-----''',
        userInfo["userPassphrase"] ?? "A4gFne6iUsqRFKnUGI75gVRVE/sqnay");
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
          LocalToast.showErrorToast(context, "Login failed!");
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
        return buildMobile();
      default:
        return buildDesktop();
    }
  }

  Widget buildDesktop() {
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
                          "Go Home".toUpperCase(),
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

  Widget buildMobile() {
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
                    text: "Create Account",
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
                  child: const Text('Sign in'),
                ),
              ),
              SizedBoxes.box8,
              CupertinoButton(
                onPressed: () {
                  mockUserSession();
                  viewModel.coordinator.move(ViewIdentifiers.home, context);
                },
                color: ProtonColors.interactionNorm,
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
