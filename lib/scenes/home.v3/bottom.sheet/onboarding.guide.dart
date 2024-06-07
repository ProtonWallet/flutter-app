import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:wallet/components/alert.custom.dart';
import 'package:wallet/components/bottom.sheets/passphrase.tutorial.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/components/close.button.v1.dart';
import 'package:wallet/components/dropdown.button.v2.dart';
import 'package:wallet/components/textfield.text.v2.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/fiat.currency.helper.dart';
import 'package:wallet/helper/local_toast.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/components/bottom.sheets/base.dart';
import 'package:wallet/managers/wallet/proton.wallet.manager.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/home.v3/home.viewmodel.dart';
import 'package:wallet/theme/theme.font.dart';

class OnboardingGuideSheet {
  static void show(BuildContext context, HomeViewModel viewModel) {
    bool passphraseConfirmed = true;
    HomeModalBottomSheet.show(context, child:
        StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
                alignment: Alignment.centerRight,
                child: CloseButtonV1(onPressed: () {
                  Navigator.of(context).pop();
                })),
            Transform.translate(
                offset: const Offset(0, -20),
                child: Column(children: [
                  Text(S.of(context).wallet_setup,
                      style: FontManager.titleHeadline(ProtonColors.textNorm)),
                  Text(
                    S.of(context).wallet_setup_desc,
                    style: FontManager.body2Regular(ProtonColors.textWeak),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
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
                  DropdownButtonV2(
                      labelText: S.of(context).setting_fiat_currency_label,
                      width: MediaQuery.of(context).size.width,
                      items: fiatCurrencies,
                      canSearch: true,
                      itemsText: fiatCurrencies
                          .map((v) => FiatCurrencyHelper.getFullName(v))
                          .toList(),
                      valueNotifier: viewModel.fiatCurrencyNotifier),
                  const SizedBox(height: 10),
                  if (Provider.of<ProtonWalletProvider>(context)
                      .protonWallet
                      .wallets
                      .isNotEmpty)
                    ExpansionTile(
                        shape: const Border(),
                        initiallyExpanded: false,
                        title: Transform.translate(
                            offset: const Offset(-12, 0),
                            child: Text(S.of(context).add_a_passphrase_optional,
                                style: FontManager.body2Median(
                                    ProtonColors.textWeak))),
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
                            labelText: S.of(context).add_a_passphrase_optional,
                            textController: viewModel.passphraseTextController,
                            myFocusNode: viewModel.passphraseFocusNode,
                            validation: (String _) {
                              if (viewModel.passphraseTextController.text !=
                                      viewModel.passphraseConfirmTextController
                                          .text &&
                                  viewModel.passphraseConfirmTextController.text
                                      .isNotEmpty) {
                                return S.of(context).passphrase_are_not_match;
                              }
                              return "";
                            },
                            onFinish: () {
                              setState(() {
                                passphraseConfirmed =
                                    viewModel.passphraseTextController.text ==
                                        viewModel
                                            .passphraseConfirmTextController
                                            .text;
                              });
                            },
                            isPassword: true,
                          ),
                          SizedBoxes.box8,
                          TextFieldTextV2(
                            labelText: S.of(context).confirm_passphrase_label,
                            textController:
                                viewModel.passphraseConfirmTextController,
                            myFocusNode: viewModel.passphraseConfirmFocusNode,
                            validation: (String _) {
                              if (viewModel.passphraseTextController.text !=
                                  viewModel
                                      .passphraseConfirmTextController.text) {
                                return S.of(context).passphrase_are_not_match;
                              }
                              return "";
                            },
                            onFinish: () {
                              setState(() {
                                passphraseConfirmed =
                                    viewModel.passphraseTextController.text ==
                                        viewModel
                                            .passphraseConfirmTextController
                                            .text;
                              });
                            },
                            isPassword: true,
                          ),
                        ]),
                  const SizedBox(height: 30),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: defaultPadding),
                      child: Column(children: [
                        ButtonV5(
                            onPressed: () async {
                              if (viewModel.passphraseTextController.text ==
                                  viewModel
                                      .passphraseConfirmTextController.text) {
                                Navigator.of(context).pop();
                                EasyLoading.show(
                                    status: "creating wallet..",
                                    maskType: EasyLoadingMaskType.black);
                                await viewModel.createWallet();
                                EasyLoading.dismiss();
                                if (context.mounted) {
                                  if (viewModel.errorMessage.isEmpty) {
                                    CommonHelper.showSnackbar(
                                        context, S.of(context).wallet_created);
                                  } else {
                                    CommonHelper.showSnackbar(
                                        context, viewModel.errorMessage,
                                        isError: true);
                                  }
                                }
                              } else {
                                LocalToast.showErrorToast(context,
                                    S.of(context).passphrase_are_not_match);
                              }
                            },
                            text: S.of(context).create_new_wallet,
                            width: MediaQuery.of(context).size.width,
                            textStyle:
                                FontManager.body1Median(ProtonColors.white),
                            backgroundColor: ProtonColors.protonBlue,
                            enable: passphraseConfirmed,
                            height: 48),
                        SizedBoxes.box8,
                        ButtonV5(
                            onPressed: () {
                              viewModel.move(NavID.importWallet);
                              Navigator.of(context).pop();
                            },
                            text: S.of(context).import_your_wallet,
                            width: MediaQuery.of(context).size.width,
                            textStyle:
                                FontManager.body1Median(ProtonColors.textNorm),
                            backgroundColor: ProtonColors.textWeakPressed,
                            borderColor: ProtonColors.textWeakPressed,
                            height: 48),
                      ])),
                ]))
          ]);
    }));
  }
}
