import 'package:flutter/material.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/external.url.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/close.button.v1.dart';
import 'package:wallet/scenes/components/custom.header.dart';
import 'package:wallet/scenes/components/page.layout.v1.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/home.v3/sub.views/proton.products/proton.products.viewmodel.dart';
import 'package:wallet/theme/theme.font.dart';

class ProtonProductsView extends ViewBase<ProtonProductsViewModel> {
  const ProtonProductsView(ProtonProductsViewModel viewModel)
      : super(viewModel, const Key("ProtonProductsView"));

  @override
  Widget build(BuildContext context) {
    return PageLayoutV1(
        headerWidget: CustomHeader(
          buttonDirection: AxisDirection.left,
          padding: const EdgeInsets.all(0.0),
          button: CloseButtonV1(
              backgroundColor: ProtonColors.backgroundProton,
              onPressed: () {
                Navigator.of(context).pop();
              }),
        ),
        backgroundColor: ProtonColors.white,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Transform.translate(
            offset: const Offset(0, -2),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                GestureDetector(
                  onTap: () {
                    ExternalUrl.shared.launchProtonMail();
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: defaultPadding),
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
                                  style: FontManager.body2Regular(
                                      ProtonColors.textWeak),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: defaultPadding),
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
                                  style: FontManager.body2Regular(
                                      ProtonColors.textWeak),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: defaultPadding),
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
                                  style: FontManager.body2Regular(
                                      ProtonColors.textWeak),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: defaultPadding),
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
                                  style: FontManager.body2Regular(
                                      ProtonColors.textWeak),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: defaultPadding),
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
                                  S
                                      .of(context)
                                      .product_intro_proton_for_business,
                                  style: FontManager.body2Regular(
                                      ProtonColors.textWeak),
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
            ]),
          )
        ]));
  }
}
