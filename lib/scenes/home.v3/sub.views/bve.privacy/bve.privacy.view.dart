import 'package:flutter/material.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/button.v6.dart';
import 'package:wallet/scenes/components/close.button.v1.dart';
import 'package:wallet/scenes/components/page.layout.v1.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/home.v3/sub.views/bve.privacy/bve.privacy.viewmodel.dart';
import 'package:wallet/theme/theme.font.dart';

class BvEPrivacyView extends ViewBase<BvEPrivacyViewModel> {
  const BvEPrivacyView(BvEPrivacyViewModel viewModel)
      : super(viewModel, const Key("BvEPrivacyView"));

  @override
  Widget build(BuildContext context) {
    return PageLayoutV1(
      showHeader: false,
      backgroundColor: ProtonColors.white,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Align(
            alignment: Alignment.centerRight,
            child: CloseButtonV1(
                backgroundColor: ProtonColors.backgroundProton,
                onPressed: () {
                  Navigator.of(context).pop();
                })),
        const SizedBox(height: 20),
        Column(children: [
          Text(
            viewModel.isPrimaryAccount
                ? S.of(context).bve_privacy_primary_account_learn_more
                : S.of(context).bve_privacy_learn_more,
            style: FontManager.body2Regular(ProtonColors.textWeak),
            textAlign: TextAlign.center,
          ),
        ]),
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          child: ButtonV6(
              onPressed: () async {
                Navigator.of(context).pop();
              },
              text: S.of(context).got_it,
              width: MediaQuery.of(context).size.width,
              textStyle: FontManager.body1Median(ProtonColors.textNorm),
              backgroundColor: ProtonColors.protonShades20,
              borderColor: ProtonColors.protonShades20,
              height: 48),
        ),
      ])
    );
  }
}
