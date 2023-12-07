import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallet/channels/platform.channel.dart';
import 'package:wallet/components/backgroud.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/welcome/signup.button.dart';
import 'package:wallet/scenes/welcome/welcome.viewmodel.dart';
import 'package:wallet/scenes/welcome/welcome.image.dart';

class WelcomeView extends ViewBase<WelcomeViewModel> {
  WelcomeView(WelcomeViewModel viewModel)
      : super(viewModel, const Key("WelcomeView"));

  static const _appChannel = MethodChannel('com.example.wallet/app.view');
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'flutter.navigation.to.home':
        String data = call.arguments;
        logger.d("Data received from Swift: $data");
        viewModel.coordinator.move(ViewIdentifiers.home, context);
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
