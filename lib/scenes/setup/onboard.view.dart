import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wallet/constants/constants.dart';
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
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      body: buildNoHistory(context, viewModel, viewSize),
    );
  }

  Widget buildNoHistory(BuildContext context, SetupOnboardViewModel viewModel,
      ViewSize viewSize) {
    return Column(
      children: [
        SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 3,
            child: Stack(children: [
              Container(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 3,
                    child: SvgPicture.asset(
                      'assets/images/wallet_creation/bg.svg',
                      fit: BoxFit.fill,
                    ),
                  )),
              Container(
                  alignment: Alignment.center,
                  height: MediaQuery.of(context).size.height / 3,
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
                    icon: Icon(Icons.arrow_back, color: ProtonColors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
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
                  onPressed: () {
                    viewModel.move(NavID.setupCreate);
                  },
                  text: S.of(context).create_new_wallet,
                  width: MediaQuery.of(context).size.width,
                  textStyle: FontManager.body1Median(ProtonColors.white),
                  backgroundColor: ProtonColors.protonBlue,
                  height: 48),
              SizedBoxes.box12,
              ButtonV5(
                  onPressed: () {
                    viewModel.move(NavID.importWallet);
                  },
                  text: S.of(context).import_your_wallet,
                  width: MediaQuery.of(context).size.width,
                  backgroundColor: ProtonColors.white,
                  borderColor: ProtonColors.protonBlue,
                  textStyle: FontManager.body1Median(ProtonColors.protonBlue),
                  height: 48),
            ])),
      ],
    );
  }
}
