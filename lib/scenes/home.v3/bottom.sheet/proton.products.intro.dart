import 'package:flutter/material.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/external.url.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/bottom.sheets/base.dart';
import 'package:wallet/scenes/components/close.button.v1.dart';
import 'package:wallet/theme/theme.font.dart';

class ProtonProductsIntroSheet {
  static void show(BuildContext context) {
    HomeModalBottomSheet.show(context, backgroundColor: ProtonColors.white,
        child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
      return Column(mainAxisSize: MainAxisSize.min, children: [
        Align(
            alignment: Alignment.centerLeft,
            child: CloseButtonV1(
                backgroundColor: ProtonColors.backgroundProton,
                onPressed: () {
                  Navigator.of(context).pop();
                })),
        const SizedBox(height: 40),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GestureDetector(
            onTap: () {
              ExternalUrl.shared.launchProtonMail();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Assets.images.icon.protonMail.svg(
                            fit: BoxFit.fitHeight,
                            width: 240,
                            height: 36,
                          ),
                          Text(
                            S.of(context).product_intro_proton_mail,
                            style:
                                FontManager.body2Regular(ProtonColors.textWeak),
                            textAlign: TextAlign.left,
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded,
                        color: ProtonColors.textWeak, size: 14),
                  ]),
            ),
          ),
          const SizedBox(height: 20),
          const Divider(thickness: 0.2, height: 1),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              ExternalUrl.shared.launchProtonCalendar();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Assets.images.icon.protonCalendar.svg(
                            fit: BoxFit.fitHeight,
                            width: 240,
                            height: 36,
                          ),
                          Text(
                            S.of(context).product_intro_proton_calendar,
                            style:
                                FontManager.body2Regular(ProtonColors.textWeak),
                            textAlign: TextAlign.left,
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded,
                        color: ProtonColors.textWeak, size: 14),
                  ]),
            ),
          ),
          const SizedBox(height: 20),
          const Divider(thickness: 0.2, height: 1),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              ExternalUrl.shared.launchProtonDrive();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Assets.images.icon.protonDrive.svg(
                            fit: BoxFit.fitHeight,
                            width: 240,
                            height: 36,
                          ),
                          Text(
                            S.of(context).product_intro_proton_drive,
                            style:
                                FontManager.body2Regular(ProtonColors.textWeak),
                            textAlign: TextAlign.left,
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded,
                        color: ProtonColors.textWeak, size: 14),
                  ]),
            ),
          ),
          const SizedBox(height: 20),
          const Divider(thickness: 0.2, height: 1),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              ExternalUrl.shared.launchProtonPass();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Transform.translate(
                            offset: const Offset(-4, 0),
                            child: Assets.images.icon.protonPass.svg(
                              fit: BoxFit.fitHeight,
                              width: 240,
                              height: 36,
                            ),
                          ),
                          Text(
                            S.of(context).product_intro_proton_pass,
                            style:
                                FontManager.body2Regular(ProtonColors.textWeak),
                            textAlign: TextAlign.left,
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded,
                        color: ProtonColors.textWeak, size: 14),
                  ]),
            ),
          ),
          const SizedBox(height: 20),
          const Divider(thickness: 0.2, height: 1),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              ExternalUrl.shared.launchProtonForBusiness();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Assets.images.icon.protonForBusiness.svg(
                            fit: BoxFit.fitHeight,
                            width: 240,
                            height: 15,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            S.of(context).product_intro_proton_for_business,
                            style:
                                FontManager.body2Regular(ProtonColors.textWeak),
                            textAlign: TextAlign.left,
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded,
                        color: ProtonColors.textWeak, size: 14),
                  ]),
            ),
          ),
          const SizedBox(height: 40),
        ]),
      ]);
    }));
  }
}
