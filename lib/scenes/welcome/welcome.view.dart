import 'dart:convert';
import 'dart:io';

import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wallet/channels/platform.channel.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/helper/local_toast.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/helper/secure_storage_helper.dart';
import 'package:wallet/helper/user.session.dart';
import 'package:wallet/network/api.helper.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/welcome/welcome.viewmodel.dart';
import 'package:wallet/theme/theme.font.dart';

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
        await userSessionProvider.login(
            userId: await SecureStorageHelper.get("userId"),
            userMail: await SecureStorageHelper.get("userMail"),
            userName: await SecureStorageHelper.get("userName"),
            userDisplayName: await SecureStorageHelper.get("userDisplayName"),
            sessionId: await SecureStorageHelper.get("sessionId"),
            accessToken: await SecureStorageHelper.get("accessToken"),
            refreshToken: await SecureStorageHelper.get("refreshToken"),
            scopes: await SecureStorageHelper.get("scopes"),
            userKeyID: await SecureStorageHelper.get("userKeyID"),
            userPrivateKey: await SecureStorageHelper.get("userPrivateKey"),
            userPassphrase: await SecureStorageHelper.get("userPassphrase"));
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

  Future<void> mockUserSession() async {
    // TODO:: remove test use code
    UserSessionProvider userSessionProvider =
        Provider.of<UserSessionProvider>(context, listen: false);
    Map userInfo = {};
    await userSessionProvider.login(
        userMail: userInfo["userMail"] ?? "ProtonWallet@proton.black",
        userName: userInfo["userName"] ?? "ProtonWallet",
        sessionId: userInfo["sessionId"] ?? "q6kuz2imdqjvfpmxdhzgslo6qxmkbgeu",
        accessToken:
            userInfo["accessToken"] ?? "3232uoliqe4dm3itautb2rikqvudcalx",
        refreshToken:
            userInfo["refreshToken"] ?? "yt7eq6cuy6rmbaspbwy6ip4gkltxkeo5",
        scopes: userInfo["scopes"] ?? "full",


      userId: 'rSUCW_Qlh8dCCsxWKPXvkUsoDNL5eW9FJUM7WX8jTPrDE3ftOMIfWt-BSuKaw5PZ7EQ6Zsp8HL9Y9qMv4Y5XJQ==',
      userKeyID: '4Xi8TArBe1WYfrFoJF5_wIDF0shMe5ACAqOArU6hjpUNoC0O0c_Zu5Afz11gGU1eeDu5Aanp_EUkpd44kjQ2lg==',
      userPrivateKey: '''-----BEGIN PGP PRIVATE KEY BLOCK-----
Version: ProtonMail

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
ydJHDOOvI+zz/2tadhbwT6A=
=GaA/
-----END PGP PRIVATE KEY BLOCK-----''',
      userPassphrase: '75bOe1zUf192xooCCVzSdi1lE1yoFlC',
      userDisplayName: 'pro',

    );
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
          await SecureStorageHelper.set(
              "appVersion", userInfo["appVersion"] ?? "");
          await SecureStorageHelper.set(
              "userAgent", userInfo["userAgent"] ?? "");
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
          if (context.mounted) {
            viewModel.coordinator.move(ViewIdentifiers.home, context);
          }
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
    return buildWelcome(context);
  }

  Widget buildWelcome(BuildContext context) {
    return Column(
      children: <Widget>[
        Stack(children: [
          Container(
              alignment: Alignment.topCenter,
              child: Container(
                color: Colors.red,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Assets.images.walletCreation.bg.svg(fit: BoxFit.fill),
              )),
          Container(
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                  alignment: Alignment.center,
                  height: 50,
                  child: SizedBox(
                      width: 190.8,
                      height: 44.15,
                      child: Assets.images.walletCreation.protonWalletLogoDark
                          .svg(fit: BoxFit.fill))),
              SizedBoxes.box32,
              Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: defaultButtonPadding * 2),
                  child: ButtonV5(
                      onPressed: () async {
                        if (Platform.isWindows) {
                          await mockUserSession();
                          if (context.mounted) {
                            viewModel.coordinator
                                .move(ViewIdentifiers.home, context);
                          }
                        } else {
                          NativeViewSwitcher.switchToNativeSignup();
                        }
                      },
                      text: S.of(context).signup,
                      width: MediaQuery.of(context).size.width,
                      backgroundColor: ProtonColors.white,
                      borderColor: ProtonColors.interactionNorm,
                      textStyle:
                          FontManager.body1Median(ProtonColors.interactionNorm),
                      height: 48)),
              SizedBoxes.box12,
              Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: defaultButtonPadding * 2),
                  child: ButtonV5(
                      onPressed: () async {
                        if (Platform.isWindows || Platform.isLinux) {
                          await mockUserSession();
                          if (context.mounted) {
                            viewModel.coordinator
                                .move(ViewIdentifiers.home, context);
                          }
                        } else {
                          NativeViewSwitcher.switchToNativeLogin();
                        }
                      },
                      text: S.of(context).login,
                      width: MediaQuery.of(context).size.width,
                      backgroundColor: ProtonColors.white,
                      borderColor: ProtonColors.interactionNorm,
                      textStyle:
                          FontManager.body1Median(ProtonColors.interactionNorm),
                      height: 48)),
            ]),
          ),
        ])
      ],
    );
  }
}
