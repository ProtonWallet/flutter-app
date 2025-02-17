import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:wallet/helper/local_toast.dart';
import 'package:wallet/managers/features/wallet.list/wallet.list.bloc.dart';
import 'package:wallet/managers/features/wallet.list/wallet.list.bloc.state.dart';
import 'package:wallet/scenes/components/bottom.sheets/passphrase.tutorial.dart';
import 'package:wallet/scenes/components/button.v5.dart';
import 'package:wallet/scenes/components/button.v6.dart';
import 'package:wallet/scenes/components/close.button.v1.dart';
import 'package:wallet/scenes/components/custom.header.dart';
import 'package:wallet/scenes/components/dropdown.currency.v1.dart';
import 'package:wallet/scenes/components/page.layout.v1.dart';
import 'package:wallet/scenes/components/textfield.text.v2.dart';
import 'package:wallet/scenes/components/underline.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/home.v3/sub.views/onboarding.guide/onboarding.guide.viewmodel.dart';

class OnboardingGuideView extends ViewBase<OnboardingGuideViewModel> {
  const OnboardingGuideView(OnboardingGuideViewModel viewModel)
      : super(viewModel, const Key("OnboardingGuideView"));

  @override
  Widget build(BuildContext context) {
    return PageLayoutV1(
        headerWidget: CustomHeader(
          title: context.local.wallet_setup,
          button: viewModel.firstWallet
              ? const SizedBox()
              : CloseButtonV1(onPressed: () {
                  Navigator.of(context).pop();
                }),
          buttonDirection: AxisDirection.right,
          padding: const EdgeInsets.all(0.0),
        ),
        initialized: viewModel.initialized,
        child: BlocBuilder<WalletListBloc, WalletListState>(
            bloc: viewModel.walletListBloc,
            builder: (context, state) {
              return StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(
                    context.local.wallet_setup_desc,
                    style:
                        ProtonStyles.body2Medium(color: ProtonColors.textWeak),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  if (!viewModel.firstWallet)
                    TextFieldTextV2(
                      labelText: context.local.name,
                      maxLength: maxAccountNameSize,
                      hintText: context.local.wallet_name_hint,
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
                      labelText: context.local.setting_fiat_currency_label,
                      width: MediaQuery.of(context).size.width,
                      items: fiatCurrencies,
                      itemsText: fiatCurrencies
                          .map(FiatCurrencyHelper.getFullName)
                          .toList(),
                      itemsLeadingIcons: fiatCurrencies
                          .map(CommonHelper.getCountryIcon)
                          .toList(),
                      valueNotifier: viewModel.fiatCurrencyNotifier),
                  if (state.walletsModel.isNotEmpty && !viewModel.firstWallet)
                    ExpansionTile(
                        shape: const Border(),
                        title: Transform.translate(
                            offset: const Offset(-12, 0),
                            child: Text(context.local.add_a_passphrase_optional,
                                style: ProtonStyles.body2Medium(
                                    color: ProtonColors.textWeak))),
                        iconColor: ProtonColors.textHint,
                        collapsedIconColor: ProtonColors.textHint,
                        children: [
                          const SizedBox(height: 10),
                          Text(
                            context.local.add_a_passphrase_title,
                            style: ProtonStyles.subheadline(
                                color: ProtonColors.textNorm),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            context.local.add_a_passphrase_desc,
                            style: ProtonStyles.body2Regular(
                                color: ProtonColors.textWeak),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          TextFieldTextV2(
                            labelText: context.local.add_a_passphrase_optional,
                            textController: viewModel.passphraseTextController,
                            myFocusNode: viewModel.passphraseFocusNode,
                            validation: (String _) {
                              if (viewModel.passphraseTextController.text !=
                                      viewModel.passphraseConfirmTextController
                                          .text &&
                                  viewModel.passphraseConfirmTextController.text
                                      .isNotEmpty) {
                                return context.local.passphrase_are_not_match;
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
                            labelText: context.local.confirm_passphrase_label,
                            textController:
                                viewModel.passphraseConfirmTextController,
                            myFocusNode: viewModel.passphraseConfirmFocusNode,
                            validation: (String _) {
                              if (viewModel.passphraseTextController.text !=
                                  viewModel
                                      .passphraseConfirmTextController.text) {
                                return context.local.passphrase_are_not_match;
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
                                  context.local.learn_more,
                                  style: ProtonStyles.body2Regular(
                                      color: ProtonColors.protonBlue),
                                ),
                              ),
                            ),
                          ),
                        ]),
                  const SizedBox(height: defaultPadding),
                  Column(children: [
                    ButtonV6(
                        onPressed: () async {
                          if (!viewModel.isCreatingWallet) {
                            viewModel.updateCreatingWalletStatus(true);
                            bool success = false;
                            if (viewModel.passphraseTextController.text ==
                                viewModel
                                    .passphraseConfirmTextController.text) {
                              success = await viewModel.createWallet();
                              if (context.mounted && success) {
                                Navigator.of(context).pop();
                                if (viewModel.errorMessage.isNotEmpty) {
                                  CommonHelper.showErrorDialog(
                                    viewModel.errorMessage,
                                  );
                                }
                              }
                            } else {
                              LocalToast.showErrorToast(context,
                                  context.local.passphrase_are_not_match);
                            }
                            viewModel.updateCreatingWalletStatus(false);
                            if (context.mounted &&
                                viewModel.firstWallet &&
                                success) {
                              viewModel.move(NavID.acceptTermsConditionDialog);
                            }
                          }
                        },
                        text: context.local.create_new_wallet,
                        width: context.width,
                        textStyle: ProtonStyles.body1Medium(
                          color: ProtonColors.textInverted,
                        ),
                        backgroundColor: ProtonColors.protonBlue,
                        enable: viewModel.passphraseMatched,
                        height: 55),
                    const SizedBox(
                      height: 10,
                    ),
                    ButtonV5(
                      onPressed: () {
                        viewModel.showImportWallet(
                          viewModel.nameTextController.text,
                        );
                        Navigator.of(context).pop();
                      },
                      enable: !viewModel.isCreatingWallet,
                      text: context.local.import_your_wallet,
                      width: context.width,
                      textStyle: ProtonStyles.body1Medium(
                        color: ProtonColors.textNorm,
                      ),
                      backgroundColor: ProtonColors.interActionWeak,
                      borderColor: ProtonColors.interActionWeak,
                      height: 55,
                    ),
                  ]),
                  if (viewModel.firstWallet)
                    Column(children: [
                      const SizedBox(
                        height: defaultPadding,
                      ),
                      Text.rich(
                        TextSpan(children: [
                          TextSpan(
                            text: context.local.welcome_to_confirm_content,
                            style: ProtonStyles.captionRegular(
                              color: ProtonColors.textHint,
                            ),
                          ),
                          TextSpan(
                            text: context.local.welcome_to_term_and_condition,
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
                ]);
              });
            }));
  }
}
