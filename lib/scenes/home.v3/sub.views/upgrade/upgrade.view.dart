import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/extension/build.context.extension.dart';
import 'package:wallet/helper/external.url.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/button.v5.dart';
import 'package:wallet/scenes/components/close.button.v1.dart';
import 'package:wallet/scenes/components/custom.header.dart';
import 'package:wallet/scenes/components/page.layout.v1.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/home.v3/sub.views/upgrade/upgrade.viewmodel.dart';
import 'package:wallet/theme/theme.font.dart';

class UpgradeView extends ViewBase<UpgradeViewModel> {
  const UpgradeView(UpgradeViewModel viewModel)
      : super(viewModel, const Key("UpgradeView"));

  @override
  Widget build(BuildContext context) {
    return PageLayoutV1(
        headerWidget: CustomHeader(
          buttonDirection: AxisDirection.right,
          padding: const EdgeInsets.all(0.0),
          button: CloseButtonV1(
              backgroundColor: ProtonColors.backgroundProton,
              onPressed: () {
                Navigator.of(context).pop();
              }),
        ),
        height: context.height / 3 * 2,
        backgroundColor: ProtonColors.white,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Transform.translate(
              offset: const Offset(0, -20),
              child: Column(children: [
                Assets.images.icon.bitcoinBigIcon.image(
                  fit: BoxFit.fill,
                  width: 240,
                  height: 167,
                ),
                const SizedBox(height: 20),
                Text(
                  S.of(context).upgrade_intro_title,
                  style: FontManager.titleHeadline(ProtonColors.textNorm),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text.rich(
                  textAlign: TextAlign.center,
                  TextSpan(children: [
                    TextSpan(
                      text: S.of(context).upgrade_intro_content(
                            viewModel.isWalletAccountExceedLimit
                                ? S.of(context).upgrade_intro_type_accounts
                                : S.of(context).upgrade_intro_type_wallets,
                          ),
                      style: FontManager.body2Regular(
                        ProtonColors.textWeak,
                      ),
                    ),
                    TextSpan(
                      text: S.of(context).to_upgrade_content,
                      style: FontManager.body2Regular(
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
                            Navigator.of(context).pop();
                            ExternalUrl.shared.launchWalletHomepage();
                          },
                          text: S.of(context).upgrade_now,
                          width: MediaQuery.of(context).size.width,
                          textStyle:
                              FontManager.body1Median(ProtonColors.white),
                          backgroundColor: ProtonColors.protonBlue,
                          borderColor: ProtonColors.protonBlue,
                          height: 48),
                    ])),
              ]))
        ]));
  }
}
