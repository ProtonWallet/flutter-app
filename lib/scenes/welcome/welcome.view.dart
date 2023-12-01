import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallet/components/backgroud.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/welcome/login_signup_button.dart';
import 'package:wallet/scenes/welcome/welcome.viewmodel.dart';
import 'package:wallet/scenes/welcome/welcome_image.dart';

class WelcomeView extends ViewBase<WelcomeViewModel> {
  WelcomeView(WelcomeViewModel viewModel)
      : super(viewModel, const Key("WelcomeView"));

  static const _appChannel = MethodChannel('com.example.wallet/app.view');
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'flutter.navigation.to.home':
        String data = call.arguments;
        logger.d("Data received from Swift: $data");
        viewModel.coordinator.move(NavigationAppIdentifiers.home, context);
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
    switch (viewSize) {
      case ViewSize.mobile:
        return buildMobile();
      default:
        return buildDesktop();
    }
  }

  Widget buildDesktop() {
    return const Background(
      child: SingleChildScrollView(
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: WelcomeImage(),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 450,
                      child: LoginAndSignupBtn(),
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
              WelcomeImage(),
              Row(
                children: [
                  Spacer(),
                  Expanded(
                    flex: 8,
                    child: LoginAndSignupBtn(),
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      viewModel.coordinator
                          .move(NavigationAppIdentifiers.home, context);
                    },
                    style: ElevatedButton.styleFrom(
                        primary: const Color(0xFF6D4AFF), elevation: 0),
                    child: Text(
                      "Create Wallet".toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
