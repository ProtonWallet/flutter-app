import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/components/onboarding/content.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/setup/onboard.viewmodel.dart';
import 'package:wallet/theme/theme.font.dart';

class SetupOnboardView extends ViewBase<SetupOnboardViewModel> {
  SetupOnboardView(SetupOnboardViewModel viewModel)
      : super(viewModel, const Key("SetupOnboardView"));

  @override
  Widget buildWithViewModel(BuildContext context,
      SetupOnboardViewModel viewModel, ViewSize viewSize) {
    return Scaffold(
      body: buildNoHistory(context, viewModel, viewSize),
    );
  }

  Widget buildNoHistory(BuildContext context, SetupOnboardViewModel viewModel,
      ViewSize viewSize) {
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
              alignment: Alignment.center,
              height: MediaQuery.of(context).size.height / 2,
              child: SizedBox(
                width: 190.8,
                height: 44.15,
                child: SvgPicture.asset(
                  'assets/images/wallet_creation/logo.svg',
                  fit: BoxFit.fill,
                ),
              )),
          if (viewModel.hasAccount)
            AppBar(
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: ProtonColors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
        ]),
        OnboardingContent(
          totalPages: 2,
          currentPage: 1,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 2,
          title: S.of(context).financial_freedom_,
          content: S.of(context).get_started_and_,
          children: [
            ButtonV5(
                onPressed: () {
                  viewModel.coordinator
                      .move(ViewIdentifiers.setupCreate, context);
                },
                text: S.of(context).create_new_wallet,
                width: MediaQuery.of(context).size.width,
                textStyle: FontManager.body1Median(ProtonColors.white),
                height: 48),
            SizedBoxes.box12,
            ButtonV5(
                onPressed: () {
                  viewModel.coordinator
                      .move(ViewIdentifiers.importWallet, context);
                },
                text: S.of(context).import_your_wallet,
                width: MediaQuery.of(context).size.width,
                backgroundColor: ProtonColors.white,
                borderColor: ProtonColors.interactionNorm,
                textStyle:
                    FontManager.body1Median(ProtonColors.interactionNorm),
                height: 48),
          ],
        ),
      ],
    );
  }
}
