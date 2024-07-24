import 'package:flutter/material.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/bottom.sheets/base.dart';
import 'package:wallet/scenes/components/close.button.v1.dart';
import 'package:wallet/theme/theme.font.dart';

class SeedPhraseTutorialSheet {
  static void show(BuildContext context) {
    HomeModalBottomSheet.show(context,
        backgroundColor: ProtonColors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                  Assets.images.icon.key.image(
                    fit: BoxFit.fill,
                    width: 240,
                    height: 167,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    S.of(context).what_is_seed_phrase,
                    style: FontManager.titleHeadline(ProtonColors.textNorm),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: defaultPadding),
                      child: Text(S.of(context).what_is_seed_phrase_content,
                          textAlign: TextAlign.center,
                          style:
                              FontManager.body2Regular(ProtonColors.textWeak))),
                ])),
          ],
        ));
  }
}
