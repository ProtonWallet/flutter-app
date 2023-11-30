import 'package:flutter/material.dart';
import 'package:wallet/components/backgroud.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/welcome/login_signup_button.dart';
import 'package:wallet/scenes/welcome/welcome.viewmodel.dart';
import 'package:wallet/scenes/welcome/welcome_image.dart';

class WelcomeView extends ViewBase<WelcomeViewModel> {
  const WelcomeView(WelcomeViewModel viewModel)
      : super(viewModel, const Key("WelcomeView"));
  @override
  Widget buildWithViewModel(
      BuildContext context, WelcomeViewModel viewModel, ViewSize viewSize) {
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
    return const Background(
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
