import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/locale.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/setup/ready.viewmodel.dart';

import '../../components/onboarding/content.dart';
import '../../constants/proton.color.dart';
import '../../theme/theme.font.dart';

class SetupReadyView extends ViewBase<SetupReadyViewModel> {
  SetupReadyView(SetupReadyViewModel viewModel)
      : super(viewModel, const Key("SetupReadyView"));

  @override
  Widget buildWithViewModel(
      BuildContext context, SetupReadyViewModel viewModel, ViewSize viewSize) {
    return Scaffold(body: buildFinished(context, viewModel, viewSize));
  }

  Widget buildFinished(
      BuildContext context, SetupReadyViewModel viewModel, ViewSize viewSize) {
    return Column(
      children: <Widget>[
        Stack(children: [
          Container(
              alignment: Alignment.topCenter,
              child: Container(
                color: Colors.red,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 2,
                child: SvgPicture.asset(
                  'assets/images/wallet_creation/bg.svg',
                  fit: BoxFit.fill,
                ),
              )),
          Container(
              alignment: Alignment.topLeft,
              height: MediaQuery.of(context).size.height / 2,
              child: Container(
                margin: const EdgeInsets.only(left: 40, top: 40),
                width: 48,
                height: 48,
                child: SvgPicture.asset(
                  'assets/images/wallet_creation/wallet.svg',
                  fit: BoxFit.fill,
                ),
              )),
          Container(
              alignment: Alignment.centerRight,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 2,
              child: Padding(
                  padding: const EdgeInsets.only(right: 30, bottom: 50),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        "Bitcoin Wallet",
                        style: FontManager.body1Bold(ProtonColors.white),
                        textAlign: TextAlign.right,
                      ),
                      Text(
                        "0 BTC",
                        style: FontManager.body1Regular(ProtonColors.white),
                        textAlign: TextAlign.right,
                      ),
                      Text(
                        "bc1p54***3297",
                        style: FontManager.body1Regular(ProtonColors.white),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  )))
        ]),
        OnboardingContent(
            totalPages: 6,
            currentPage: 6,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 2,
            title: "Your Bitcoin Wallet is ready!",
            content: "",
            children: [
              ButtonV5(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) {
                      if (route.settings.name == null) {
                        return false;
                      }
                      return route.settings.name == "[<'HomeNavigationView'>]";
                    });
                  },
                  text: "Open your wallet",
                  width: MediaQuery.of(context).size.width,
                  textStyle: FontManager.body1Median(ProtonColors.white),
                  height: 48)
            ]),
      ],
    );
  }
}
