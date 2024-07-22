import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/bottom.sheets/base.dart';
import 'package:wallet/scenes/components/button.v5.dart';
import 'package:wallet/scenes/components/button.v6.dart';
import 'package:wallet/theme/theme.font.dart';

class EarlyAccessSheet {
  static void show(
    BuildContext context,
    String email,
    VoidCallback logoutCallback,
  ) {
    HomeModalBottomSheet.show(context,
        isDismissible: false,
        enableDrag: false,
        backgroundColor: ProtonColors.white, child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
      return Column(mainAxisSize: MainAxisSize.min, children: [
        Transform.translate(
            offset: const Offset(0, -20),
            child: Column(children: [
              SvgPicture.asset("assets/images/icon/send_success.svg",
                  fit: BoxFit.fill, width: 240, height: 240),
              const SizedBox(height: 20),
              Text(
                S.of(context).early_access_title,
                style: FontManager.titleHeadline(ProtonColors.textNorm),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                S.of(context).early_access_content(email),
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
                          if (Platform.isAndroid) {
                            launchUrl(Uri.parse(
                                "https://play.google.com/store/apps/dev?id=7672479706558526647"));
                          } else if (Platform.isIOS) {
                            launchUrl(Uri.parse(
                                "https://apps.apple.com/developer/proton-ag/id979659484"));
                          } else {
                            launchUrl(Uri.parse("https://proton.me/"));
                          }
                        },
                        text: S.of(context).explore_other_proton_products,
                        width: MediaQuery.of(context).size.width,
                        textStyle: FontManager.body1Median(ProtonColors.white),
                        backgroundColor: ProtonColors.protonBlue,
                        borderColor: ProtonColors.protonBlue,
                        height: 48),
                    const SizedBox(
                      height: 12,
                    ),
                    ButtonV6(
                        onPressed: () async {
                          logoutCallback.call();
                        },
                        text: S.of(context).logout,
                        width: MediaQuery.of(context).size.width,
                        textStyle:
                            FontManager.body1Median(ProtonColors.textNorm),
                        backgroundColor: ProtonColors.protonShades20,
                        borderColor: ProtonColors.protonShades20,
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
                              // TODO(improve): to use $[ExternalUrl];
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
