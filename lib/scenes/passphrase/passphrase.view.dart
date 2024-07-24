import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/alert.warning.dart';
import 'package:wallet/scenes/components/button.v5.dart';
import 'package:wallet/scenes/components/onboarding/content.dart';
import 'package:wallet/scenes/components/textfield.text.v2.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/passphrase/passphrase.viewmodel.dart';
import 'package:wallet/theme/theme.font.dart';

class SetupPassPhraseView extends ViewBase<SetupPassPhraseViewModel> {
  const SetupPassPhraseView(SetupPassPhraseViewModel viewModel)
      : super(viewModel, const Key("SetupPassPhraseView"));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: ProtonColors.backgroundProton,
          scrolledUnderElevation: 0.0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            // For Android (dark icons)
            statusBarBrightness: Brightness.light,
          ),
          // don't change background color when scroll down
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: ProtonColors.textNorm),
            onPressed: () {
              if (!viewModel.isAddingPassPhrase) {
                Navigator.pop(context);
              } else {
                viewModel.updateState(isAddingPassPhrase: false);
              }
            },
          ),
        ),
        backgroundColor: ProtonColors.backgroundProton,
        resizeToAvoidBottomInset: false,
        body: viewModel.isAddingPassPhrase
            ? buildAddPassPhrase(context)
            : buildMain(context));
  }

  Widget buildAddPassPhrase(BuildContext context) {
    return SingleChildScrollView(
        child: Center(
            child: Stack(children: [
      Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height -
              56 -
              MediaQuery.of(context).padding.top,
          margin: const EdgeInsets.symmetric(horizontal: defaultPadding),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBoxes.box20,
                Text(S.of(context).your_passphrase_optional,
                    style: FontManager.titleHeadline(ProtonColors.textNorm),
                    textAlign: TextAlign.center),
                SizedBoxes.box8,
                Text(
                  S.of(context).for_additional_security_you_can_use_passphrase_,
                  style: FontManager.body1Median(ProtonColors.textNorm),
                  textAlign: TextAlign.center,
                ),
                SizedBoxes.box24,
                AlertWarning(
                    content:
                        S.of(context).store_your_passphrase_at_safe_location_,
                    width: MediaQuery.of(context).size.width),
                SizedBoxes.box24,
                TextFieldTextV2(
                  labelText: S.of(context).passphrase_label,
                  textController: viewModel.passphraseTextController,
                  myFocusNode: FocusNode(),
                  validation: (String _) {
                    return "";
                  },
                  isPassword: true,
                ),
                SizedBoxes.box24,
                TextFieldTextV2(
                  labelText: S.of(context).confirm_passphrase_label,
                  textController: viewModel.passphraseTextConfirmController,
                  myFocusNode: FocusNode(),
                  validation: (String _) {
                    return "";
                  },
                  isPassword: true,
                ),
              ])),
      Container(
          padding: const EdgeInsets.only(bottom: defaultPadding),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height -
              56 -
              MediaQuery.of(context).padding.top,
          // AppBar default height is 56
          margin: const EdgeInsets.symmetric(horizontal: defaultPadding),
          child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
            ButtonV5(
                onPressed: () async {
                  if (viewModel.checkPassphrase()) {
                    EasyLoading.show(maskType: EasyLoadingMaskType.black);
                    await viewModel.updateDB();
                    EasyLoading.dismiss();
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      if (viewModel.errorMessage.isEmpty) {
                        CommonHelper.showSnackbar(
                            context, S.of(context).wallet_created);
                      } else {
                        CommonHelper.showErrorDialog(
                          viewModel.errorMessage,
                        );
                      }
                    }
                  } else {
                    CommonHelper.showSnackbar(
                        context, S.of(context).passphrase_are_not_match);
                  }
                },
                text: S.of(context).save_passphrase_button,
                width: MediaQuery.of(context).size.width,
                textStyle: FontManager.body1Median(ProtonColors.white),
                backgroundColor: ProtonColors.protonBlue,
                height: 48),
          ]))
    ])));
  }

  Widget buildMain(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 3 - 56,
          color: ProtonColors.backgroundProton,
          alignment: Alignment.topCenter,
          child: Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height / 16,
                  bottom: MediaQuery.of(context).size.height / 16),
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 200.0,
                ),
                child: SvgPicture.asset(
                  'assets/images/wallet_creation/passphrase_icon.svg',
                ),
              )),
        ),
        Expanded(
            child: Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 200 : 0),
          child: OnboardingContent(
              totalPages: 2,
              currentPage: 2,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 3 * 2,
              title: S.of(context).your_passphrase_optional,
              content:
                  S.of(context).for_additional_security_you_can_use_passphrase_,
              children: [
                SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: TextFieldTextV2(
                      labelText: S.of(context).wallet_name,
                      maxLength: maxAccountNameSize,
                      textController: viewModel.nameTextController,
                      myFocusNode: viewModel.walletNameFocusNode,
                      validation: (String _) {
                        return "";
                      },
                    )),
              ]),
        )),
        Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(children: [
              ButtonV5(
                  onPressed: () async {
                    EasyLoading.show(maskType: EasyLoadingMaskType.black);
                    await viewModel.updateDB();
                    EasyLoading.dismiss();
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      if (viewModel.errorMessage.isEmpty) {
                        CommonHelper.showSnackbar(
                            context, S.of(context).wallet_created);
                      } else {
                        CommonHelper.showSnackbar(
                            context, viewModel.errorMessage,
                            isError: true);
                      }
                    }
                  },
                  text: S.of(context).continue_without_passphrase_button,
                  width: MediaQuery.of(context).size.width,
                  backgroundColor: ProtonColors.protonBlue,
                  textStyle: FontManager.body1Median(ProtonColors.white),
                  height: 48),
              SizedBoxes.box12,
              ButtonV5(
                  onPressed: () {
                    viewModel.updateState(isAddingPassPhrase: true);
                  },
                  text: S.of(context).yes_use_a_passphrase_button,
                  width: MediaQuery.of(context).size.width,
                  backgroundColor: ProtonColors.white,
                  borderColor: ProtonColors.protonBlue,
                  textStyle: FontManager.body1Median(ProtonColors.protonBlue),
                  height: 48)
            ])),
      ],
    );
  }
}
