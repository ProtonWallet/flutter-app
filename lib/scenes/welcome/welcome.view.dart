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
            await SecureStorageHelper.get("userKeyID"));
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
            "H4WhXT8Ga9kYdz4XNY36UiTzvmuLJbkSD4N0s3vuiIm8PoqIPLYNk8MxdCm18PSyEz8YCL6GUDVc4-potp8DKQ==",
        userInfo["userMail"] ?? "willwallet1@proton.black",
        userInfo["userName"] ?? "willwallet1",
        userInfo["userDisplayName"] ?? "willwallet1",
        userInfo["sessionId"] ?? "ekg56qctbmjmrjbf4i5kuomwdrju4x6n",
        userInfo["accessToken"] ?? "4ghy7gxgjy623nu3ya5akljhgck3wejb",
        userInfo["refreshToken"] ?? "gpaz4wdteci7butrhfw5i3nnn73kcwv5",
        userInfo["userKeyID"] ??
            "igZ0nMBnUFMrgrWLGZbJql93OcOR0X9VfB01ODV6smpI4zTayqtVKJMLtBNytm074SLG8PH7wu3jfQkJf4IIig==");
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
              userInfo["userKeyID"] ?? "");
          APIHelper.init(
              userSessionProvider.userSession.accessToken,
              userSessionProvider.userSession.sessionId,
              userSessionProvider.userSession.userKeyID);
          viewModel.coordinator.move(ViewIdentifiers.home, context);
        } else {
          LocalToast.showToast(context, "Login failed!",
              isWarning: true,
              icon: const Icon(Icons.warning, color: Colors.white),
              duration: 2);
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
