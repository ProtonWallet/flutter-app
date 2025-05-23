import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/avatar.color.helper.dart';
import 'package:wallet/helper/common.helper.dart';
import 'package:wallet/helper/extension/build.context.extension.dart';
import 'package:wallet/helper/extension/svg.gen.image.extension.dart';
import 'package:wallet/helper/external.url.dart';
import 'package:wallet/helper/fiat.currency.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/bottom.sheets/passphrase.tutorial.dart';
import 'package:wallet/scenes/components/bottom.sheets/seed.phrase.tutorial.dart';
import 'package:wallet/scenes/components/button.v6.dart';
import 'package:wallet/scenes/components/custom.header.dart';
import 'package:wallet/scenes/components/dropdown.currency.v1.dart';
import 'package:wallet/scenes/components/textfield.text.v2.dart';
import 'package:wallet/scenes/components/underline.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/import/import.viewmodel.dart';

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
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24.0),
            ),
            color: ProtonColors.backgroundNorm,
          ),
          child: Column(
            children: [
              CustomHeader(
                title: S.of(context).import_your_wallet,
                buttonDirection: AxisDirection.right,
              ),
              Expanded(
                child: Container(
                    width: context.width,
                    margin: const EdgeInsets.symmetric(
                      horizontal: defaultPadding,
                    ),
                    child: SingleChildScrollView(
                        child: Column(children: <Widget>[
                      Underline(
                        onTap: () {
                          ExternalUrl.shared.launchBlogImportWallet();
                        },
                        color: ProtonColors.protonBlue,
                        child: Text(
                          S.of(context).learn_more,
                          style: ProtonStyles.body2Medium(
                            color: ProtonColors.protonBlue,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
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
                            child: Assets.images.icon.wallet1
                                .applyThemeIfNeeded(context)
                                .svg(
                                  fit: BoxFit.scaleDown,
                                  width: 16,
                                  height: 16,
                                ),
                          ),
                        ),
                        alwaysShowHint: true,
                        textController: viewModel.nameTextController,
                        myFocusNode: viewModel.nameFocusNode,
                        validation: (String _) {
                          return "";
                        },
                      ),
                      SizedBoxes.box12,
                      DropdownCurrencyV1(
                          labelText: S.of(context).setting_fiat_currency_label,
                          width: context.width,
                          items: fiatCurrencies,
                          itemsText: fiatCurrencies
                              .map(FiatCurrencyHelper.getFullName)
                              .toList(),
                          itemsLeadingIcons: fiatCurrencies
                              .map(CommonHelper.getCountryIcon)
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
                              style: ProtonStyles.body2Regular(
                                color: ProtonColors.protonBlue,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBoxes.box24,
                      ExpansionTile(
                          shape: const Border(),
                          title: Text(
                            S.of(context).my_wallet_has_passphrase,
                            style: ProtonStyles.body2Medium(
                              color: ProtonColors.textWeak,
                            ),
                          ),
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
                                    style: ProtonStyles.body2Regular(
                                        color: ProtonColors.protonBlue),
                                  ),
                                ),
                              ),
                            ),
                          ]),
                      const SizedBox(height: 40),
                      ButtonV6(
                          onPressed: () async {
                            if (!viewModel.isImporting) {
                              viewModel.isImporting = true;
                              final isSuccess = await viewModel.importWallet();
                              if (context.mounted) {
                                if (isSuccess) {
                                  Navigator.of(context).pop();
                                  context.showSnackbar(
                                    context.local.wallet_imported,
                                  );
                                }
                                if (viewModel.errorMessage.isEmpty) {
                                  if (viewModel.isFirstWallet &&
                                      !viewModel.acceptTermsAndConditions) {
                                    viewModel.move(NavID.importSuccess);
                                  } else if (viewModel.hitWalletAccountLimit) {
                                    viewModel.showUpgrade();
                                  }
                                } else {
                                  CommonHelper.showErrorDialog(
                                    viewModel.errorMessage,
                                  );
                                }
                              }
                              viewModel.isImporting = false;
                            }
                          },
                          enable: viewModel.isValidMnemonic,
                          text: S.of(context).import_button,
                          width: context.width,
                          textStyle: ProtonStyles.body1Medium(
                            color: ProtonColors.textInverted,
                          ),
                          backgroundColor: ProtonColors.protonBlue,
                          height: 55),
                      if (viewModel.isFirstWallet)
                        Column(children: [
                          const SizedBox(height: defaultPadding),
                          Text.rich(
                            TextSpan(children: [
                              TextSpan(
                                text: S.of(context).welcome_to_confirm_content,
                                style: ProtonStyles.captionRegular(
                                  color: ProtonColors.textHint,
                                ),
                              ),
                              TextSpan(
                                text:
                                    S.of(context).welcome_to_term_and_condition,
                                style: ProtonStyles.captionMedium(
                                  color: ProtonColors.protonBlue,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    ExternalUrl.shared.lanuchTerms();
                                  },
                              ),
                            ]),
                          ),
                        ]),
                      const SizedBox(height: 20),
                    ]))),
              ),
            ],
          ),
        ));
  }

  Widget buildPasteMode(BuildContext context) {
    return Column(children: [
      TextFieldTextV2(
        labelText: S.of(context).your_mnemonic,
        hintText: S.of(context).your_mnemonic_hint,
        alwaysShowHint: true,
        textController: viewModel.mnemonicTextController,
        myFocusNode: viewModel.mnemonicFocusNode,
        maxLines: 6,
        validation: (String strMnemonic) {
          final check = viewModel.mnemonicValidation(strMnemonic);
          if (!check.$1) {
            return S.of(context).not_a_valid_mnemonic + check.$2;
          }
          return "";
        },
        onFinish: () {
          viewModel.mnemonicTextController.text =
              viewModel.mnemonicTextController.text.trim();
          final check = viewModel
              .mnemonicValidation(viewModel.mnemonicTextController.text);
          viewModel.updateValidMnemonic(isValidMnemonic: check.$1);
        },
      ),
    ]);
  }

  bool verifyMnemonic(String strMnemonic) {
    final RegExp regex = RegExp(r'^[a-z ]*$');
    final bool matchPattern = regex.hasMatch(strMnemonic);
    if (!matchPattern) {
      logger.i("pattern not match!");
      return false;
    }
    final int mnemonicLength = strMnemonic.split(" ").length;
    if (mnemonicLength != 12 && mnemonicLength != 18 && mnemonicLength != 24) {
      logger.i("length not match! ($mnemonicLength)");
      return false;
    }
    return true;
  }

  Widget buildManualInputMode(BuildContext context) {
    return Column(children: [
      GestureDetector(
        onTap: viewModel.switchToPasteMode,
        child: Text(
          S.of(context).import_paste_input,
          style: ProtonStyles.body2Medium(
            color: ProtonColors.protonBlue,
          ),
        ),
      ),
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
