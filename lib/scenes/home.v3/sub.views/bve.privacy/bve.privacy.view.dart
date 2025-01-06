import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/extension/build.context.extension.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/close.button.v1.dart';
import 'package:wallet/scenes/components/custom.header.dart';
import 'package:wallet/scenes/components/page.layout.v1.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/home.v3/sub.views/bve.privacy/bve.privacy.viewmodel.dart';

class BvEPrivacyView extends ViewBase<BvEPrivacyViewModel> {
  const BvEPrivacyView(BvEPrivacyViewModel viewModel)
      : super(viewModel, const Key("BvEPrivacyView"));

  @override
  Widget build(BuildContext context) {
    return PageLayoutV1(
        headerWidget: CustomHeader(
          buttonDirection: AxisDirection.right,
          padding: const EdgeInsets.all(0.0),
          button: CloseButtonV1(
              backgroundColor: ProtonColors.backgroundNorm,
              onPressed: () {
                Navigator.of(context).pop();
              }),
        ),
        height: context.height / 3 * 2,
        backgroundColor: ProtonColors.white,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Column(children: [
            Text(
              viewModel.isPrimaryAccount
                  ? S.of(context).bve_privacy_primary_account_learn_more
                  : S.of(context).bve_privacy_learn_more,
              style: ProtonStyles.body2Medium(color: ProtonColors.textWeak),
              textAlign: TextAlign.center,
            ),
          ]),
        ]));
  }
}
