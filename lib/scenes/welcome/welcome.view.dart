import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wallet/scenes/core/responsive.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/welcome/login.signup.button.dart';
import 'package:wallet/scenes/welcome/welcom.backgroud.dart';
import 'package:wallet/scenes/welcome/welcome.image.dart';
import 'package:wallet/scenes/welcome/welcome.viewmodel.dart';

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
                          (MediaQuery.of(context).size.height - 600) / 2, 0),
                    ),
                    const WelcomeImage(),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    SizedBox(
                      height: max(
                          (MediaQuery.of(context).size.height - 300) / 2, 0),
                    ),
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
            children: [
              SizedBox(
                height: max((MediaQuery.of(context).size.height - 900) / 2, 0),
              ),
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
}
