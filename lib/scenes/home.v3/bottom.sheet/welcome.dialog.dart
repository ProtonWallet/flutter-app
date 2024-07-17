import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/bottom.sheets/base.dart';
import 'package:wallet/scenes/components/button.v5.dart';
import 'package:wallet/scenes/components/close.button.v1.dart';
import 'package:wallet/scenes/components/underline.dart';
import 'package:wallet/theme/theme.font.dart';

class WelcomeDialogSheet {
  static void show(
    BuildContext context,
    String email,
    VoidCallback acceptTermsCallback,
  ) {
    HomeModalBottomSheet.show(context, child:
        StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      return Column(mainAxisSize: MainAxisSize.min, children: [
        Align(
            alignment: Alignment.centerRight,
            child: CloseButtonV1(onPressed: () {
              Navigator.of(context).pop();
            })),
        Transform.translate(
            offset: const Offset(0, -20),
            child: Column(children: [
              SvgPicture.asset("assets/images/icon/send_success.svg",
                  fit: BoxFit.fill, width: 240, height: 240),
              const SizedBox(height: 20),
              Text(
                S.of(context).welcome_to,
                style: FontManager.titleHeadline(ProtonColors.textNorm),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                S.of(context).welcome_to_content(email),
                style: FontManager.body2Regular(ProtonColors.textWeak),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: defaultPadding),
                  child: Column(children: [
                    ButtonV5(
                        onPressed: () async {
                          acceptTermsCallback.call();
                          Navigator.of(context).pop();
                        },
                        text: S.of(context).continue_buttion,
                        width: MediaQuery.of(context).size.width,
                        textStyle: FontManager.body1Median(ProtonColors.white),
                        backgroundColor: ProtonColors.protonBlue,
                        borderColor: ProtonColors.protonBlue,
                        height: 48),
                    const SizedBox(
                      height: 12,
                    ),
                    Text.rich(
                      TextSpan(children: [
                        TextSpan(
                          text: S.of(context).welcome_to_confirm_content,
                          style: FontManager.captionRegular(
                            ProtonColors.textHint,
                          ),
                        ),
                        TextSpan(
                          text: S.of(context).welcome_to_term_and_condition,
                          style: FontManager.captionMedian(
                            ProtonColors.protonBlue,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              launchUrl(Uri.parse(
                                  "https://proton.me/wallet/legal/terms"));
                            },
                        ),
                      ]),
                    ),
                  ])),
            ]))
      ]);
    }));
  }
}
