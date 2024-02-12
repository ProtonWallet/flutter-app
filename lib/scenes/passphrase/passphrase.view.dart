import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wallet/components/alert.warning.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/components/onboarding/content.dart';
import 'package:wallet/components/textfield.password.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/passphrase/passphrase.viewmodel.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/theme/theme.font.dart';
import 'package:flutter_gen/gen_l10n/locale.dart';

class SetupPassPhraseView extends ViewBase<SetupPassPhraseViewModel> {
  SetupPassPhraseView(SetupPassPhraseViewModel viewModel)
      : super(viewModel, const Key("SetupPassPhraseView"));

  @override
  Widget buildWithViewModel(BuildContext context,
      SetupPassPhraseViewModel viewModel, ViewSize viewSize) {
    return Scaffold(
        body: viewModel.isAddingPassPhrase
            ? buildAddPassPhrase(context, viewModel, viewSize)
            : buildMain(context, viewModel, viewSize));
  }

  Widget buildAddPassPhrase(BuildContext context,
      SetupPassPhraseViewModel viewModel, ViewSize viewSize) {
    return SingleChildScrollView(
        child: Stack(children: [
      Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          margin: const EdgeInsets.only(left: 40, right: 40),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBoxes.box20,
                Text(S.of(context).your_passphrase_optional,
                    style: FontManager.titleHeadline(
                        Theme.of(context).colorScheme.primary),
                    textAlign: TextAlign.center),
                SizedBoxes.box8,
                Text(
                  "For additional security you can use a passphrase. Note that you will need this passphrase to access your wallet.",
                  style: FontManager.body1Median(
                      Theme.of(context).colorScheme.primary),
                  textAlign: TextAlign.center,
                ),
                SizedBoxes.box24,
                AlertWarning(
                    content:
                        "Store your passphrase at a safe location. Without the passphrase, even Proton cannot recover your funds.",
                    width: MediaQuery.of(context).size.width),
                SizedBoxes.box24,
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    "Passphrase",
                    style: FontManager.captionMedian(
                        Theme.of(context).colorScheme.primary),
                    textAlign: TextAlign.left,
                  ),
                ),
                TextFieldPassword(
                    width: MediaQuery.of(context).size.width,
                    controller: viewModel.passphraseTextController),
                SizedBoxes.box24,
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    "Confirm Passphrase",
                    style: FontManager.captionMedian(
                        Theme.of(context).colorScheme.primary),
                    textAlign: TextAlign.left,
                  ),
                ),
                TextFieldPassword(
                    width: MediaQuery.of(context).size.width,
                    controller: viewModel.passphraseTextConfirmController),
              ])),
      AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ProtonColors.textNorm),
          onPressed: () {
            viewModel.updateState(false);
          },
        ),
      ),
      Container(
          padding: const EdgeInsets.only(bottom: 50),
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.only(left: 40, right: 40),
          height: MediaQuery.of(context).size.height,
          // AppBar default height is 56
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ButtonV5(
                    onPressed: () {
                      if (viewModel.checkPassphrase()) {
                        this.viewModel.updateDB();
                        viewModel.coordinator
                            .move(ViewIdentifiers.setupReady, context);
                      } else {
                        const snackBar = SnackBar(
                          content: Text('Passphrase are not equal!'),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    },
                    text: "Save Passphrase",
                    width: MediaQuery.of(context).size.width,
                    textStyle: FontManager.body1Median(ProtonColors.white),
                    height: 48),
              ]))
    ]));
  }

  Widget buildMain(BuildContext context, SetupPassPhraseViewModel viewModel,
      ViewSize viewSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 2,
          color: ProtonColors.backgroundSecondary,
          child: Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height / 7,
                  bottom: MediaQuery.of(context).size.height / 7),
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 100.0,
                ),
                child: SvgPicture.asset(
                  'assets/images/wallet_creation/passphrase_icon.svg',
                  fit: BoxFit.contain,
                ),
              )),
        ),
        Container(
          alignment: Alignment.topCenter,
          width: MediaQuery.of(context).size.width,
          child: OnboardingContent(
              totalPages: 6,
              currentPage: 5,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 2,
              title: "Your passphrase (optional)",
              content:
                  "For additional security you can use a passphrase. Note that you will need this passphrase to access your wallet.",
              children: [
                ButtonV5(
                    onPressed: () {
                      this.viewModel.updateDB();
                      viewModel.coordinator
                          .move(ViewIdentifiers.setupReady, context);
                    },
                    text: "Continue without Passphrase",
                    width: MediaQuery.of(context).size.width,
                    textStyle: FontManager.body1Median(ProtonColors.white),
                    height: 48),
                SizedBoxes.box12,
                ButtonV5(
                    onPressed: () {
                      viewModel.updateState(true);
                    },
                    text: "Yes, use a Passphrase",
                    width: MediaQuery.of(context).size.width,
                    backgroundColor: ProtonColors.white,
                    borderColor: ProtonColors.interactionNorm,
                    textStyle:
                        FontManager.body1Median(ProtonColors.interactionNorm),
                    height: 48),
              ]),
        ),
      ],
    );
  }
}
