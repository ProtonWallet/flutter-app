import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/external.url.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/button.v5.dart';
import 'package:wallet/scenes/components/button.v6.dart';
import 'package:wallet/scenes/components/page.layout.v1.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/home.v3/sub.views/early.access/early.access.viewmodel.dart';
import 'package:wallet/theme/theme.font.dart';

class EarlyAccessView extends ViewBase<EarlyAccessViewModel> {
  const EarlyAccessView(EarlyAccessViewModel viewModel)
      : super(viewModel, const Key("EarlyAccessView"));

  @override
  Widget build(BuildContext context) {
    return PageLayoutV1(
      showHeader: false,
      backgroundColor: ProtonColors.white,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Transform.translate(
            offset: const Offset(0, -2),
            child: Column(children: [
              Assets.images.icon.earlyAccess.image(
                fit: BoxFit.fill,
                width: 240,
                height: 167,
              ),
              Text(
                S.of(context).early_access_title,
                style: FontManager.titleHeadline(ProtonColors.textNorm),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text.rich(
                textAlign: TextAlign.center,
                TextSpan(children: [
                  TextSpan(
                    text: S.of(context).early_access_content_1_fix,
                    style: FontManager.body2Median(
                      ProtonColors.textWeak,
                    ),
                  ),
                  TextSpan(
                    text: viewModel.email,
                    style: FontManager.body2Median(
                      ProtonColors.textNorm,
                    ),
                  ),
                  TextSpan(
                    text: S.of(context).early_access_content_2,
                    style: FontManager.body2Median(
                      ProtonColors.textWeak,
                    ),
                  ),
                  TextSpan(
                    text: "wallet.proton.me",
                    style: FontManager.body2Median(
                      ProtonColors.protonBlue,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        ExternalUrl.shared.launchWalletHomepage();
                      },
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
                          viewModel.showProtonProducts.call();
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
                          viewModel.logoutFunction.call();
                        },
                        text: S.of(context).logout,
                        width: MediaQuery.of(context).size.width,
                        textStyle:
                            FontManager.body1Median(ProtonColors.textNorm),
                        backgroundColor: ProtonColors.protonShades20,
                        borderColor: ProtonColors.protonShades20,
                        height: 48),
                  ])),
            ]))
      ]),
    );
  }
}
