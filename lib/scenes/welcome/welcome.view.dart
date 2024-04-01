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
        userId: userInfo["userId"] ??
            "ffdya2Juf_4GYwZXDpM4A7Dz9BIRTj2JzUxtli9qvIgm3cA0eOCRk9sCEGti3ReMhJ8rSgmXN7xZRa8f7V04ZQ==",
        userMail: userInfo["userMail"] ?? "ProtonWallet@proton.black",
        userName: userInfo["userName"] ?? "ProtonWallet",
        userDisplayName: userInfo["userDisplayName"] ?? "ProtonWallet",
        sessionId: userInfo["sessionId"] ?? "q6kuz2imdqjvfpmxdhzgslo6qxmkbgeu",
        accessToken:
            userInfo["accessToken"] ?? "3232uoliqe4dm3itautb2rikqvudcalx",
        refreshToken:
            userInfo["refreshToken"] ?? "yt7eq6cuy6rmbaspbwy6ip4gkltxkeo5",
        scopes: userInfo["scopes"] ?? "full",
        userKeyID: userInfo["userKeyID"] ??
            "8iEjB8IwOGvKSQrz03Eu6QWEKK8-5gmahR5nLwO4J734l_zxY6TcXaYduZgfTm94pcr5UCZYIf_CALIHJ65LjQ==",
        userPrivateKey: userInfo["userPrivateKey"] ??
            '''-----BEGIN PGP PRIVATE KEY BLOCK-----
Version: ProtonMail

xYYEZebYaBYJKwYBBAHaRw8BAQdAFzA4dSnGH0IXY/d+wGAjLhARAJQVbt4n
CJtz9XZ0j/3+CQMIeMuH1I6AQqBgAAAAAAAAAAAAAAAAAAAAABHY0xSjI30p
3HuV9I3SRmR7wHjbcK8mTYmz8/c/KqGnA03SIJiZH0KxAsKEwYxHwrBYQ++v
RM07bm90X2Zvcl9lbWFpbF91c2VAZG9tYWluLnRsZCA8bm90X2Zvcl9lbWFp
bF91c2VAZG9tYWluLnRsZD7CjAQQFgoAPgWCZebYaAQLCQcICZCAiPd+sxrq
JwMVCAoEFgACAQIZAQKbAwIeARYhBATVFZI0zvYzVwSRP4CI936zGuonAAAH
gQD+MM7zA2Ex5u6YO0/otR1yPfJqEz/M794U7GjHHcoSBXoA/iMgKeHCpMWH
+xPs0/cxu6uFm6h9qtDbC2rHY1JrrCgJx4sEZebYaBIKKwYBBAGXVQEFAQEH
QMvaayaa5DUhL6vBJ4+5BvhxcY4/9xQnNCkkImbotkcJAwEIB/4JAwiM0res
s6MXbWAAAAAAAAAAAAAAAAAAAAAAsHiHUZpTl05p15xdRSzjY9FI8ZmF3pem
H1Fo9NtGHstuqDrNLt3UWt5UBddR3ui3PwJhPygVwngEGBYKACoFgmXm2GgJ
kICI936zGuonApsMFiEEBNUVkjTO9jNXBJE/gIj3frMa6icAAM8cAP9OH3qv
oIwMw9Hne8UxiYfUzgNEz9GDag3z3tgupEMp7gD/bA+Hf8TMTMhcU7nqEN/a
wQY+jJXAXl46XDaJETkdMgE=
=VDHo
-----END PGP PRIVATE KEY BLOCK-----
''',
        userPassphrase:
            userInfo["userPassphrase"] ?? "mL5KrCOVlJQAMgD89gwvUHqZgfMDCj.");
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
                        if (Platform.isWindows) {
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
