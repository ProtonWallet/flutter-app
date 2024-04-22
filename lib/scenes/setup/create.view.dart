import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/components/onboarding/content.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/setup/create.viewmodel.dart';
import 'package:wallet/theme/theme.font.dart';

class SetupCreateView extends ViewBase<SetupCreateViewModel> {
  SetupCreateView(SetupCreateViewModel viewModel)
      : super(viewModel, const Key("SetupCreateView"));

  @override
  Widget buildWithViewModel(
      BuildContext context, SetupCreateViewModel viewModel, ViewSize viewSize) {
    return Scaffold(body: buildInProgress(context, viewModel, viewSize));
  }

  Widget buildInProgress(
      BuildContext context, SetupCreateViewModel viewModel, ViewSize viewSize) {
    return Column(
      children: <Widget>[
        SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 3,
            child: Stack(children: [
              Container(
                  alignment: Alignment.topCenter,
                  child: Container(
                    color: Colors.red,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 3,
                    child:
                        Assets.images.walletCreation.bg.svg(fit: BoxFit.fill),
                  )),
              for (int i = 0; i < viewModel.animatedSquares.length; i++)
                AnimatedPositioned(
                  duration: Duration(seconds: Random().nextInt(3) + 2),
                  left: viewModel.isAnimationStart
                      ? MediaQuery.of(context).size.width + 100
                      : -(Random().nextInt((i ~/ 10 * 100) + 1) + 20)
                          .toDouble(),
                  width: viewModel.animatedSquares[i].squareSize,
                  height: viewModel.animatedSquares[i].squareSize,
                  // Adjust the spacing between squares
                  top: viewModel.animatedSquares[i].top,
                  // Adjust the top position
                  child: Container(
                    width: viewModel.animatedSquares[i].squareSize,
                    // Adjust the size of the square
                    height: viewModel.animatedSquares[i].squareSize,
                    color: Colors.white.withAlpha(
                        viewModel.animatedSquares[i].visible
                            ? viewModel.animatedSquares[i].alpha
                            : 0),
                  ),
                ),
              Container(
                  alignment: Alignment.center,
                  height: MediaQuery.of(context).size.height / 3,
                  child: SizedBox(
                    height: 57,
                    child: Assets.images.walletCreation.title
                        .svg(fit: BoxFit.fitHeight),
                  )),
            ])),
        Expanded(
            child: OnboardingContent(
          totalPages: 2,
          currentPage: 1,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 3 * 2,
          title: S.of(context).financial_freedom_,
          content: S.of(context).get_started_and_,
        )),
        Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(children: [
              ButtonV5(
                  onPressed: () {},
                  enable: false,
                  text: S.of(context).create_new_wallet,
                  width: MediaQuery.of(context).size.width,
                  textStyle: FontManager.body1Median(ProtonColors.white),
                  backgroundColor: ProtonColors.protonBlue,
                  height: 48),
              SizedBoxes.box12,
              ButtonV5(
                  onPressed: () {},
                  enable: false,
                  text: S.of(context).import_your_wallet,
                  width: MediaQuery.of(context).size.width,
                  backgroundColor: ProtonColors.white,
                  borderColor: ProtonColors.protonBlue,
                  textStyle:
                      FontManager.body1Median(ProtonColors.interactionNorm),
                  height: 48),
            ])),
      ],
    );
  }
}
