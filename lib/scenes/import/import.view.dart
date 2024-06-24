import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wallet/components/alert.custom.dart';
import 'package:wallet/components/bottom.sheets/passphrase.tutorial.dart';
import 'package:wallet/components/bottom.sheets/seed.phrase.tutorial.dart';
import 'package:wallet/components/close.button.v1.dart';
import 'package:wallet/components/textfield.text.v2.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/import/import.viewmodel.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/theme/theme.font.dart';
import 'package:wallet/l10n/generated/locale.dart';

class ImportView extends ViewBase<ImportViewModel> {
  const ImportView(ImportViewModel viewModel)
      : super(viewModel, const Key("ImportView"));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
            height: double.infinity,
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24.0)),
              color: ProtonColors.backgroundProton,
            ),
            child: Center(
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.all(defaultPadding),
                  child: SingleChildScrollView(
                      child: Column(children: <Widget>[
                    Align(
                        alignment: Alignment.centerLeft,
                        child: CloseButtonV1(onPressed: () {
                          Navigator.of(context).pop();
                        })),
                    SizedBoxes.box18,
                    Text(S.of(context).import_wallet_header,
                        style: FontManager.body2Regular(ProtonColors.textWeak)),
                    SizedBoxes.box18,
                    TextFieldTextV2(
                      labelText: S.of(context).wallet_name,
                      maxLength: maxAccountNameSize,
                      hintText: S.of(context).wallet_name_hint,
                      textController: viewModel.nameTextController,
                      myFocusNode: viewModel.nameFocusNode,
                      validation: (String _) {
                        return "";
                      },
                    ),
                    SizedBoxes.box12,
                    AlertCustom(
                      content: S.of(context).what_is_seed_phrase,
                      onTap: () {
                        SeedPhraseTutorialSheet.show(context);
                      },
                      canClose: false,
                      leadingWidget: SvgPicture.asset(
                          "assets/images/icon/alert_info.svg",
                          fit: BoxFit.fill,
                          width: 22,
                          height: 22),
                      border: Border.all(
                        color: Colors.transparent,
                        width: 0,
                      ),
                      backgroundColor: ProtonColors.purple1Background,
                      color: ProtonColors.purple1Text,
                    ),
                    SizedBoxes.box12,
                    viewModel.isPasteMode
                        ? buildPasteMode(context)
                        : buildManualInputMode(context),
                    SizedBoxes.box24,
                    ExpansionTile(
                        shape: const Border(),
                        initiallyExpanded: false,
                        title: Text(S.of(context).my_wallet_has_passphrase,
                            style:
                                FontManager.body2Median(ProtonColors.textWeak)),
                        iconColor: ProtonColors.textHint,
                        collapsedIconColor: ProtonColors.textHint,
                        children: [
                          AlertCustom(
                            content: S.of(context).what_is_wallet_passphrase,
                            onTap: () {
                              PassphraseTutorialSheet.show(context);
                            },
                            canClose: false,
                            leadingWidget: SvgPicture.asset(
                                "assets/images/icon/alert_info.svg",
                                fit: BoxFit.fill,
                                width: 22,
                                height: 22),
                            border: Border.all(
                              color: Colors.transparent,
                              width: 0,
                            ),
                            backgroundColor: ProtonColors.purple1Background,
                            color: ProtonColors.purple1Text,
                          ),
                          SizedBoxes.box12,
                          TextFieldTextV2(
                            labelText: S.of(context).your_passphrase_optional,
                            textController: viewModel.passphraseTextController,
                            myFocusNode: viewModel.passphraseFocusNode,
                            validation: (String _) {
                              return "";
                            },
                            isPassword: true,
                          )
                        ]),
                    const SizedBox(height: 40),
                    ButtonV5(
                        onPressed: () async {
                          EasyLoading.show(
                              status: "creating wallet..",
                              maskType: EasyLoadingMaskType.black);
                          await viewModel.importWallet();
                          viewModel.coordinator.end();
                          EasyLoading.dismiss();
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            if (viewModel.errorMessage.isEmpty) {
                              CommonHelper.showSnackbar(
                                  context, S.of(context).wallet_imported);
                            } else {
                              CommonHelper.showSnackbar(
                                  context, viewModel.errorMessage,
                                  isError: true);
                            }
                          }
                        },
                        enable: viewModel.isValidMnemonic,
                        text: S.of(context).import_button,
                        width: MediaQuery.of(context).size.width,
                        textStyle: FontManager.body1Median(ProtonColors.white),
                        backgroundColor: ProtonColors.protonBlue,
                        height: 48),
                    const SizedBox(height: 20),
                  ]))),
            )));
  }

  Widget buildPasteMode(BuildContext context) {
    return Column(children: [
      // GestureDetector(
      //     onTap: () {
      //       viewModel.switchToManualInputMode();
      //     },
      //     child: Text(S.of(context).import_manual_input,
      //         style: FontManager.body2Median(ProtonColors.protonBlue))),
      // SizedBoxes.box8,
      TextFieldTextV2(
        labelText: S.of(context).your_mnemonic,
        hintText: S.of(context).your_mnemonic_hint,
        textController: viewModel.mnemonicTextController,
        myFocusNode: viewModel.mnemonicFocusNode,
        maxLines: 6,
        validation: (String strMnemonic) {
          var check = viewModel.mnemonicValidation(strMnemonic);
          if (check.$1 == false) {
            return S.of(context).not_a_valid_mnemonic + check.$2;
          }
          return "";
        },
        isPassword: false,
        onFinish: () {
          viewModel.mnemonicTextController.text =
              viewModel.mnemonicTextController.text.trim();
          var check = viewModel
              .mnemonicValidation(viewModel.mnemonicTextController.text);
          viewModel.updateValidMnemonic(check.$1);
        },
      ),
    ]);
  }

  bool verifyMnemonic(String strMnemonic) {
    final RegExp regex = RegExp(r'^[a-z ]*$');
    bool matchPattern = regex.hasMatch(strMnemonic);
    if (matchPattern == false) {
      logger.i("pattern not match!");
      return false;
    }
    int mnemonicLength = strMnemonic.split(" ").length;
    if (mnemonicLength != 12 && mnemonicLength != 18 && mnemonicLength != 24) {
      logger.i("length not match! ($mnemonicLength)");
      return false;
    }
    return true;
  }

  Widget buildManualInputMode(BuildContext context) {
    return Column(children: [
      GestureDetector(
          onTap: () {
            viewModel.switchToPasteMode();
          },
          child: Text(S.of(context).import_paste_input,
              style: FontManager.body2Median(ProtonColors.protonBlue))),
      SizedBoxes.box8,
      const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(),
          Column(),
        ],
      ),
    ]);
  }
}
