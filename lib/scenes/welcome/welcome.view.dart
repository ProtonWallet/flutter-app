import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/button.v5.dart';
import 'package:wallet/scenes/core/responsive.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/welcome/login.signup.button.dart';
import 'package:wallet/scenes/welcome/welcom.backgroud.dart';
import 'package:wallet/scenes/welcome/welcome.image.dart';
import 'package:wallet/scenes/welcome/welcome.viewmodel.dart';
import 'package:wallet/theme/theme.font.dart';

class WelcomeView extends ViewBase<WelcomeViewModel> {
  const WelcomeView(WelcomeViewModel viewModel)
      : super(viewModel, const Key("WelcomeView"));

  @override
  Widget build(BuildContext context) {
    return buildBackground(context);
  }

  Widget buildBackground(BuildContext context) {
    return WelcomBackground(
        child: SingleChildScrollView(
      child: SafeArea(
        child: Responsive(
          desktop: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    SizedBox(
                        height: max(
                            (MediaQuery.of(context).size.height - 600) / 2, 0)),
                    const WelcomeImage(),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    SizedBox(
                        height: max(
                            (MediaQuery.of(context).size.height - 300) / 2, 0)),
                    SizedBox(
                      height: 120,
                      width: 450,
                      child: LoginAndSignupBtn(
                        signupPressed: () {
                          viewModel.move(NavID.nativeSignup);
                        },
                        signinPressed: () {
                          viewModel.move(NavID.nativeSignin);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          mobile: Column(
            children: <Widget>[
              SizedBox(
                  height:
                      max((MediaQuery.of(context).size.height - 900) / 2, 0)),
              const WelcomeImage(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: LoginAndSignupBtn(
                  signupPressed: () {
                    viewModel.move(NavID.nativeSignup);
                  },
                  signinPressed: () {
                    viewModel.move(NavID.nativeSignin);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  // TODO(fix): old build function remove after testing
  Widget buildWelcome(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
    ));
    return Column(
      children: <Widget>[
        Stack(children: [
          Container(
              alignment: Alignment.topCenter,
              child: Container(
                color: Colors.black,
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
                      child: Assets.images.walletCreation.protonWalletLogoLight
                          .svg())),
              SizedBoxes.box32,
              Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: defaultButtonPadding * 2),
                  child: ButtonV5(
                      onPressed: () async {
                        viewModel.move(NavID.nativeSignup);
                      },
                      enable: viewModel.initialized,
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
                        viewModel.move(NavID.nativeSignin);
                      },
                      enable: viewModel.initialized,
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
