import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/helper/avatar.color.helper.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/external.url.dart';
import 'package:wallet/helper/fiat.currency.helper.dart';
import 'package:wallet/helper/local_toast.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/managers/features/wallet.list/wallet.list.bloc.dart';
import 'package:wallet/managers/features/wallet.list/wallet.list.bloc.state.dart';
import 'package:wallet/scenes/components/bottom.sheets/passphrase.tutorial.dart';
import 'package:wallet/scenes/components/button.v5.dart';
import 'package:wallet/scenes/components/button.v6.dart';
import 'package:wallet/scenes/components/custom.header.dart';
import 'package:wallet/scenes/components/dropdown.currency.v1.dart';
import 'package:wallet/scenes/components/page.layout.v1.dart';
import 'package:wallet/scenes/components/textfield.text.v2.dart';
import 'package:wallet/scenes/components/underline.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/home.v3/sub.views/onboarding.guide/onboarding.guide.viewmodel.dart';
import 'package:wallet/theme/theme.font.dart';

class OnboardingGuideView extends ViewBase<OnboardingGuideViewModel> {
  const OnboardingGuideView(OnboardingGuideViewModel viewModel)
      : super(viewModel, const Key("OnboardingGuideView"));

  @override
  Widget build(BuildContext context) {
    return PageLayoutV1(
        headerWidget: CustomHeader(
          title: S.of(context).wallet_setup,
          buttonDirection: AxisDirection.right,
          padding: const EdgeInsets.all(0.0),
        ),
        initialized: viewModel.initialized,
        expanded: viewModel.firstWallet
            ? MediaQuery.of(context).size.height < 400
            : MediaQuery.of(context).size.height < 1000, // need expansion
        child: BlocBuilder<WalletListBloc, WalletListState>(
            bloc: viewModel.walletListBloc,
            builder: (context, state) {
              return StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return Column(mainAxisSize: MainAxisSize.min, children: [
                  Transform.translate(
                      offset: const Offset(0, -10),
                      child: Column(children: [
                        Text(
                          S.of(context).wallet_setup_desc,
                          style:
                              FontManager.body2Regular(ProtonColors.textWeak),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),
                        if (!viewModel.firstWallet)
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
                                    child: Assets.images.icon.wallet1.svg(
                                      fit: BoxFit.scaleDown,
                                      width: 16,
                                      height: 16,
                                    ))),
                            alwaysShowHint: true,
                            textController: viewModel.nameTextController,
                            myFocusNode: viewModel.walletNameFocusNode,
                            validation: (String _) {
                              return "";
                            },
                          ),
                        SizedBoxes.box12,
                        DropdownCurrencyV1(
                            labelText:
                                S.of(context).setting_fiat_currency_label,
                            width: MediaQuery.of(context).size.width,
                            items: fiatCurrencies,
                            itemsText: fiatCurrencies
                                .map(FiatCurrencyHelper.getFullName)
                                .toList(),
                            itemsLeadingIcons: fiatCurrencies
                                .map(CommonHelper.getCountryIcon)
                                .toList(),
                            valueNotifier: viewModel.fiatCurrencyNotifier),
                        const SizedBox(height: 10),
                        if (state.walletsModel.isNotEmpty &&
                            !viewModel.firstWallet)
                          ExpansionTile(
                              shape: const Border(),
                              title: Transform.translate(
                                  offset: const Offset(-12, 0),
                                  child: Text(
                                      S.of(context).add_a_passphrase_optional,
                                      style: FontManager.body2Median(
                                          ProtonColors.textWeak))),
                              iconColor: ProtonColors.textHint,
                              collapsedIconColor: ProtonColors.textHint,
                              children: [
                                const SizedBox(height: 10),
                                Text(
                                  S.of(context).add_a_passphrase_title,
                                  style: FontManager.titleHeadline(
                                      ProtonColors.textNorm),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  S.of(context).add_a_passphrase_desc,
                                  style: FontManager.body2Regular(
                                      ProtonColors.textWeak),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20),
                                TextFieldTextV2(
                                  labelText:
                                      S.of(context).add_a_passphrase_optional,
                                  textController:
                                      viewModel.passphraseTextController,
                                  myFocusNode: viewModel.passphraseFocusNode,
                                  validation: (String _) {
                                    if (viewModel.passphraseTextController
                                                .text !=
                                            viewModel
                                                .passphraseConfirmTextController
                                                .text &&
                                        viewModel
                                            .passphraseConfirmTextController
                                            .text
                                            .isNotEmpty) {
                                      return S
                                          .of(context)
                                          .passphrase_are_not_match;
                                    }
                                    return "";
                                  },
                                  onFinish: () {
                                    viewModel.checkPassphraseMatched();
                                  },
                                  isPassword: true,
                                ),
                                SizedBoxes.box8,
                                TextFieldTextV2(
                                  labelText:
                                      S.of(context).confirm_passphrase_label,
                                  textController:
                                      viewModel.passphraseConfirmTextController,
                                  myFocusNode:
                                      viewModel.passphraseConfirmFocusNode,
                                  validation: (String _) {
                                    if (viewModel
                                            .passphraseTextController.text !=
                                        viewModel
                                            .passphraseConfirmTextController
                                            .text) {
                                      return S
                                          .of(context)
                                          .passphrase_are_not_match;
                                    }
                                    return "";
                                  },
                                  onFinish: () {
                                    viewModel.checkPassphraseMatched();
                                  },
                                  isPassword: true,
                                ),
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: GestureDetector(
                                    onTap: () {
                                      PassphraseTutorialSheet.show(context);
                                    },
                                    child: Underline(
                                      child: Text(
                                        S.of(context).learn_more,
                                        style: FontManager.body2Regular(
                                            ProtonColors.purple1Text),
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                        const SizedBox(height: 30),
                        Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: defaultPadding),
                            child: Column(children: [
                              ButtonV6(
                                  onPressed: () async {
                                    if (!viewModel.isCreatingWallet) {
                                      viewModel
                                          .updateCreatingWalletStatus(true);
                                      bool success = false;
                                      if (viewModel
                                              .passphraseTextController.text ==
                                          viewModel
                                              .passphraseConfirmTextController
                                              .text) {
                                        success =
                                            await viewModel.createWallet();
                                        if (context.mounted && success) {
                                          Navigator.of(context).pop();
                                          if (viewModel.errorMessage.isEmpty) {
                                            CommonHelper.showSnackbar(context,
                                                S.of(context).wallet_created);
                                          } else {
                                            CommonHelper.showErrorDialog(
                                              viewModel.errorMessage,
                                            );
                                          }
                                        }
                                      } else {
                                        LocalToast.showErrorToast(
                                            context,
                                            S
                                                .of(context)
                                                .passphrase_are_not_match);
                                      }
                                      viewModel
                                          .updateCreatingWalletStatus(false);
                                      if (context.mounted &&
                                          viewModel.firstWallet &&
                                          success) {
                                        viewModel.move(
                                            NavID.acceptTermsConditionDialog);
                                      }
                                    }
                                  },
                                  text: S.of(context).create_new_wallet,
                                  width: MediaQuery.of(context).size.width,
                                  textStyle: FontManager.body1Median(
                                      ProtonColors.white),
                                  backgroundColor: ProtonColors.protonBlue,
                                  enable: viewModel.passphraseMatched,
                                  height: 48),
                              SizedBoxes.box8,
                              ButtonV5(
                                onPressed: () {
                                  viewModel.coordinator.showImportWallet(viewModel.nameTextController.text);
                                  Navigator.of(context).pop();
                                },
                                enable: !viewModel.isCreatingWallet,
                                text: S.of(context).import_your_wallet,
                                width: MediaQuery.of(context).size.width,
                                textStyle: FontManager.body1Median(
                                    ProtonColors.textNorm),
                                backgroundColor: ProtonColors.textWeakPressed,
                                borderColor: ProtonColors.textWeakPressed,
                                height: 48,
                              ),
                            ])),
                        if (viewModel.firstWallet)
                          Column(children: [
                            SizedBoxes.box24,
                            Text.rich(
                              TextSpan(children: [
                                TextSpan(
                                  text:
                                      S.of(context).welcome_to_confirm_content,
                                  style: FontManager.captionRegular(
                                    ProtonColors.textHint,
                                  ),
                                ),
                                TextSpan(
                                  text: S
                                      .of(context)
                                      .welcome_to_term_and_condition,
                                  style: FontManager.captionMedian(
                                    ProtonColors.protonBlue,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      ExternalUrl.shared.lanuchTerms();
                                    },
                                ),
                              ]),
                            ),
                          ]),
                      ]))
                ]);
              });
            }));
  }
}
