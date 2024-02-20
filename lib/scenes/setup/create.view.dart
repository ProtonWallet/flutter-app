import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/locale.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/components/onboarding/content.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/setup/create.viewmodel.dart';
import 'package:wallet/theme/theme.font.dart';

class SetupCreateView extends ViewBase<SetupCreateViewModel> {
  SetupCreateView(SetupCreateViewModel viewModel)
      : super(viewModel, const Key("SetupCreateView"));

  @override
  Widget buildWithViewModel(
      BuildContext context, SetupCreateViewModel viewModel, ViewSize viewSize) {
    return Scaffold(
      body: viewModel.inProgress
          ? buildInProgress(context, viewModel, viewSize)
          : buildFinished(context, viewModel, viewSize),
    );
  }

  Widget buildInProgress(
      BuildContext context, SetupCreateViewModel viewModel, ViewSize viewSize) {
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
          for (int i = 0; i < viewModel.animatedSquares.length; i++)
            AnimatedPositioned(
              duration: Duration(seconds: Random().nextInt(3) + 4),
              left: viewModel.isAnimationStart
                  ? MediaQuery.of(context).size.width + 100
                  : -(Random().nextInt((i ~/ 10 * 100) + 1) + 20).toDouble(),
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
              height: MediaQuery.of(context).size.height / 2,
              child: SizedBox(
                height: 57,
                child: SvgPicture.asset(
                  'assets/images/wallet_creation/title.svg',
                  fit: BoxFit.fitHeight,
                ),
              )),
        ]),
        OnboardingContent(
          totalPages: 6,
          currentPage: 2,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 2,
          title: S.of(context).financial_freedom_,
          content: S.of(context).get_started_and_,
          children: [
            ButtonV5(
                onPressed: () {},
                enable: false,
                text: S.of(context).create_new_wallet,
                width: MediaQuery.of(context).size.width,
                textStyle: FontManager.body1Median(ProtonColors.white),
                height: 48),
            SizedBoxes.box12,
            ButtonV5(
                onPressed: () {},
                enable: false,
                text: S.of(context).import_your_wallet,
                width: MediaQuery.of(context).size.width,
                backgroundColor: ProtonColors.white,
                borderColor: ProtonColors.interactionNorm,
                textStyle:
                    FontManager.body1Median(ProtonColors.interactionNorm),
                height: 48),
          ],
        )
      ],
    );
  }

  Widget buildFinished(
      BuildContext context, SetupCreateViewModel viewModel, ViewSize viewSize) {
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
                        S.of(context).bitcoin_wallet,
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
            currentPage: 2,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 2,
            title: S.of(context).your_bitcoin_wallet_created,
            content: S.of(context).your_new_wallet_is_created_,
            children: [
              ButtonV5(
                  onPressed: () {
                    viewModel.coordinator
                        .move(ViewIdentifiers.setupBackup, context);
                  },
                  text: S.of(context).backup_your_wallet,
                  width: MediaQuery.of(context).size.width,
                  textStyle: FontManager.body1Median(ProtonColors.white),
                  height: 48)
            ]),
      ],
    );
  }
}
