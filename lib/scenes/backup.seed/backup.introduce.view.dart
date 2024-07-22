import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/proton.links.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/button.v5.dart';
import 'package:wallet/scenes/components/underline.dart';
import 'package:wallet/theme/theme.font.dart';

class BackupIntroduceView extends StatelessWidget {
  final VoidCallback? onPressed;

  const BackupIntroduceView({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(defaultPadding * 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Assets.images.icon.accessKey.svg(
                    fit: BoxFit.fill,
                    width: 60,
                    height: 60,
                  ),
                  const SizedBox(height: 30),
                  Text(
                    S.of(context).backup_introduce_title,
                    style: FontManager.titleSubHero(ProtonColors.textNorm),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    S.of(context).backup_introduce_content,
                    style: FontManager.body2Regular(ProtonColors.textWeak),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Underline(
                    onTap: () {
                      launchUrl(Uri.parse(seedPhraseLink));
                    },
                    color: ProtonColors.brandLighten20,
                    child: Text(
                      S.of(context).learn_more,
                      style: FontManager.body2Median(
                        ProtonColors.brandLighten20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          child: ButtonV5(
            onPressed: onPressed,
            backgroundColor: ProtonColors.protonBlue,
            text: S.of(context).view_wallet_mnemonic,
            width: MediaQuery.of(context).size.width,
            textStyle: FontManager.body1Median(ProtonColors.white),
            radius: 40,
            height: 52,
          ),
        ),
      ]),
    );
  }
}
