import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wallet/components/bottom.sheets/base.dart';
import 'package:wallet/components/close.button.v1.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/theme/theme.font.dart';

class SeedPhraseTutorialSheet {
  static void show(BuildContext context) {
    HomeModalBottomSheet.show(context,
        child: Column(
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
                  SvgPicture.asset("assets/images/icon/access-key.svg",
                      fit: BoxFit.fill, width: 60, height: 60),
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
                          style:
                              FontManager.body2Regular(ProtonColors.textWeak))),
                ])),
          ],
        ));
  }
}
