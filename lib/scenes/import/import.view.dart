import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wallet/scenes/components/bottom.sheets/passphrase.tutorial.dart';
import 'package:wallet/scenes/components/bottom.sheets/seed.phrase.tutorial.dart';
import 'package:wallet/scenes/components/button.v6.dart';
import 'package:wallet/scenes/components/custom.header.dart';
import 'package:wallet/scenes/components/dropdown.button.v2.dart';
import 'package:wallet/scenes/components/textfield.text.v2.dart';
import 'package:wallet/scenes/components/underline.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/helper/avatar.color.helper.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/fiat.currency.helper.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/home.v3/bottom.sheet/welcome.dialog.dart';
import 'package:wallet/scenes/import/import.viewmodel.dart';
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
          child: Column(
            children: [
              CustomHeader(
                title: S.of(context).import_your_wallet,
                closeButtonDirection: AxisDirection.left,
              ),
              Expanded(
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(
                      horizontal: defaultPadding,
                    ),
                    child: SingleChildScrollView(
                        child: Column(children: <Widget>[
                      TextFieldTextV2(
                        labelText: S.of(context).name,
                        maxLength: maxAccountNameSize,
                        hintText: S.of(context).wallet_name_hint,
                        prefixIcon: Padding(
                            padding: const EdgeInsets.all(4),
                            child: CircleAvatar(
                                backgroundColor:
                                    AvatarColorHelper.getBackgroundColor(1),
                                radius: 10,
                                child: SvgPicture.asset(
                                  "assets/images/icon/wallet-1.svg",
                                  fit: BoxFit.scaleDown,
                                  width: 16,
                                  height: 16,
                                ))),
                        alwaysShowHint: true,
                        textController: viewModel.nameTextController,
                        myFocusNode: viewModel.nameFocusNode,
                        validation: (String _) {
                          return "";
                        },
                      ),
                      SizedBoxes.box12,
                      DropdownButtonV2(
                          labelText: S.of(context).setting_fiat_currency_label,
                          width: MediaQuery.of(context).size.width,
                          items: fiatCurrencies,
                          canSearch: true,
                          itemsText: fiatCurrencies
                              .map((v) => FiatCurrencyHelper.getFullName(v))
                              .toList(),
                          itemsLeadingIcons: fiatCurrencies
                              .map((v) => CountryFlag.fromCountryCode(
                                    FiatCurrencyHelper.toCountryCode(v),
                                    shape: const Circle(),
                                    width: 20,
                                    height: 20,
                                  ))
                              .toList(),
                          valueNotifier: viewModel.fiatCurrencyNotifier),
                      SizedBoxes.box12,
                      viewModel.isPasteMode
                          ? buildPasteMode(context)
                          : buildManualInputMode(context),
                      SizedBoxes.box12,
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () {
                            SeedPhraseTutorialSheet.show(context);
                          },
                          child: Underline(
                            child: Text(
                              S.of(context).what_is_seed_phrase,
                              style: FontManager.body2Regular(
                                  ProtonColors.purple1Text),
                            ),
                          ),
                        ),
                      ),
                      SizedBoxes.box24,
                      ExpansionTile(
                          shape: const Border(),
                          initiallyExpanded: false,
                          title: Text(S.of(context).my_wallet_has_passphrase,
                              style: FontManager.body2Median(
                                  ProtonColors.textWeak)),
                          iconColor: ProtonColors.textHint,
                          collapsedIconColor: ProtonColors.textHint,
                          children: [
                            TextFieldTextV2(
                              labelText: S.of(context).passphrase_label,
                              hintText: S.of(context).passphrase_label_hint,
                              alwaysShowHint: true,
                              textController:
                                  viewModel.passphraseTextController,
                              myFocusNode: viewModel.passphraseFocusNode,
                              validation: (String _) {
                                return "";
                              },
                              isPassword: true,
                            ),
                            SizedBoxes.box12,
                            Align(
                              alignment: Alignment.centerLeft,
                              child: GestureDetector(
                                onTap: () {
                                  PassphraseTutorialSheet.show(context);
                                },
                                child: Underline(
                                  child: Text(
                                    S.of(context).what_is_wallet_passphrase,
                                    style: FontManager.body2Regular(
                                        ProtonColors.purple1Text),
                                  ),
                                ),
                              ),
                            ),
                          ]),
                      const SizedBox(height: 40),
                      ButtonV6(
                          onPressed: () async {
                            if (viewModel.isImporting == false) {
                              viewModel.isImporting = true;
                              await viewModel.importWallet();
                              viewModel.coordinator.end();
                              if (context.mounted) {
                                Navigator.of(context).pop();
                                if (viewModel.errorMessage.isEmpty) {
                                  if (viewModel.isFirstWallet) {
                                    WelcomeDialogSheet.show(
                                        context,
                                        viewModel.protonAddresses.firstOrNull
                                                ?.email ??
                                            "");
                                  }
                                  CommonHelper.showSnackbar(
                                      context, S.of(context).wallet_imported);
                                } else {
                                  CommonHelper.showSnackbar(
                                      context, viewModel.errorMessage,
                                      isError: true);
                                }
                              }
                              viewModel.isImporting = false;
                            }
                          },
                          enable: viewModel.isValidMnemonic,
                          text: S.of(context).import_button,
                          width: MediaQuery.of(context).size.width,
                          textStyle:
                              FontManager.body1Median(ProtonColors.white),
                          backgroundColor: ProtonColors.protonBlue,
                          height: 48),
                      const SizedBox(height: 20),
                    ]))),
              ),
            ],
          ),
        ));
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
        alwaysShowHint: true,
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
