import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/button.v5.dart';
import 'package:wallet/scenes/components/close.button.v1.dart';
import 'package:wallet/scenes/components/page.layout.v1.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/home.v3/sub.views/accept.terms.condition/accept.terms.condition.viewmodel.dart';
import 'package:wallet/theme/theme.font.dart';

class AcceptTermsConditionView extends ViewBase<AcceptTermsConditionViewModel> {
  const AcceptTermsConditionView(AcceptTermsConditionViewModel viewModel)
      : super(viewModel, const Key("AcceptTermsConditionView"));

  @override
  Widget build(BuildContext context) {
    return PageLayoutV1(
      showHeader: false,
      backgroundColor: ProtonColors.white,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Align(
            alignment: Alignment.centerRight,
            child: CloseButtonV1(
                backgroundColor: ProtonColors.backgroundProton,
                onPressed: () {
                  Navigator.of(context).pop();
                })),
        Transform.translate(
            offset: const Offset(0, -20),
            child: Column(children: [
              Assets.images.icon.bitcoinBigIcon.image(
                fit: BoxFit.fill,
                width: 240,
                height: 167,
              ),
              Text(
                S.of(context).welcome_to,
                style: FontManager.titleHeadline(ProtonColors.textNorm),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text.rich(
                textAlign: TextAlign.center,
                TextSpan(children: [
                  TextSpan(
                    text: S.of(context).welcome_to_content_1,
                    style: FontManager.body2Regular(
                      ProtonColors.textWeak,
                    ),
                  ),
                  TextSpan(
                    text: viewModel.email,
                    style: FontManager.body2Median(
                      ProtonColors.textNorm,
                    ),
                    recognizer: TapGestureRecognizer()..onTap = () {},
                  ),
                  TextSpan(
                    text: S.of(context).welcome_to_content_2,
                    style: FontManager.body2Regular(
                      ProtonColors.textWeak,
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 30),
              Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: defaultPadding),
                  child: Column(children: [
                    ButtonV5(
                        onPressed: () async {
                          viewModel
                              .userSettingsDataProvider.acceptTermsAndConditions
                              .call();
                          Navigator.of(context).pop();
                        },
                        text: S.of(context).continue_buttion,
                        width: MediaQuery.of(context).size.width,
                        textStyle: FontManager.body1Median(ProtonColors.white),
                        backgroundColor: ProtonColors.protonBlue,
                        borderColor: ProtonColors.protonBlue,
                        height: 48),
                  ])),
            ]))
      ]),
    );
  }
}
