import 'package:flutter/material.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/external.url.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/button.v6.dart';
import 'package:wallet/scenes/components/underline.dart';
import 'package:wallet/theme/theme.font.dart';

class BackupIntroduceView extends StatelessWidget {
  final FutureCallback onPressed;

  const BackupIntroduceView({
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(children: [
        Expanded(
          child: SingleChildScrollView(
            child: Transform.translate(
              offset: const Offset(0, -30),
              child: Padding(
                padding: const EdgeInsets.all(defaultPadding * 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Assets.images.icon.key.image(
                      fit: BoxFit.fill,
                      width: 240,
                      height: 167,
                    ),
                    Text(
                      S.of(context).backup_introduce_title,
                      style: FontManager.titleHeadline(ProtonColors.textNorm),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Text.rich(
                      textAlign: TextAlign.center,
                      TextSpan(children: [
                        TextSpan(
                          text: S.of(context).backup_introduce_content,
                          style:
                              FontManager.body2Regular(ProtonColors.textWeak),
                        ),
                        TextSpan(
                          text: S.of(context).backup_introduce_content_1,
                          style:
                              FontManager.body2Median(ProtonColors.textNorm),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 20),
                    Underline(
                      onTap: () {
                        ExternalUrl.shared.launchBlogSeedPhrase();
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
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          child: ButtonV6(
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
