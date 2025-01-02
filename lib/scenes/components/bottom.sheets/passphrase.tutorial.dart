import 'package:flutter/material.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/external.url.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/bottom.sheets/base.dart';
import 'package:wallet/scenes/components/close.button.v1.dart';
import 'package:wallet/scenes/components/underline.dart';

class PassphraseTutorialSheet {
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
                  Assets.images.icon.lock.image(
                    fit: BoxFit.fill,
                    width: 240,
                    height: 167,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    S.of(context).what_is_wallet_passphrase,
                    style: ProtonStyles.subheadline(
                        color: ProtonColors.textNorm),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: defaultPadding),
                      child: Text(
                          S.of(context).what_is_wallet_passphrase_content,
                          textAlign: TextAlign.center,
                          style: ProtonStyles.body2Regular(
                              color: ProtonColors.textWeak))),
                  const SizedBox(height: 10),
                  Underline(
                    onTap: () {
                      ExternalUrl.shared.launchBlogPassphrase();
                    },
                    child: Text(
                      S.of(context).learn_more,
                      style: ProtonStyles.body2Regular(
                          color: ProtonColors.purple1Text),
                    ),
                  ),
                  const SizedBox(height: 10),
                ])),
          ],
        ));
  }
}
