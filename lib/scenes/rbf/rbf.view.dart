import 'package:flutter/material.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/button.v6.dart';
import 'package:wallet/scenes/components/custom.header.dart';
import 'package:wallet/scenes/components/custom.slider.v1.dart';
import 'package:wallet/scenes/components/page.layout.v1.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/rbf/rbf.viewmodel.dart';
import 'package:wallet/theme/theme.font.dart';

class RbfView extends ViewBase<RbfViewModel> {
  const RbfView(RbfViewModel viewModel)
      : super(viewModel, const Key("RbfView"));

  @override
  Widget build(BuildContext context) {
    return PageLayoutV1(
      headerWidget: const CustomHeader(buttonDirection: AxisDirection.right),
      backgroundColor: ProtonColors.white,
      child: Transform.translate(
        offset: const Offset(0, -30),
        child: Column(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
            ),
            Assets.images.icon.earlyAccess.image(
              fit: BoxFit.fill,
              width: 240,
              height: 167,
            ),
            Text(
              S.of(context).rbf_title,
              style: FontManager.titleHeadline(ProtonColors.textNorm),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              S.of(context).rbf_desc,
              style: FontManager.body2Median(ProtonColors.textWeak),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  S.of(context).rbf_current_fee,
                  style: FontManager.body1Median(ProtonColors.textNorm),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "\$ 0.24",
                  style: FontManager.body1Median(ProtonColors.textNorm),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "0.000066 BTC",
                style: FontManager.body1Median(ProtonColors.textHint),
                textAlign: TextAlign.right,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: const Divider(thickness: 0.2, height: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  S.of(context).rbf_new_fee,
                  style: FontManager.body1Median(ProtonColors.textNorm),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "\$ 0.24",
                  style: FontManager.body1Median(ProtonColors.textNorm),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "0.000066 BTC",
                style: FontManager.body1Median(ProtonColors.textHint),
                textAlign: TextAlign.right,
              ),
            ),
            const SizedBox(
              height: 6,
            ),
            StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return const CustomSliderV1(
                value: 20.0,
              );
            }),
            const SizedBox(
              height: 6,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(
                S.of(context).rbf_confirm_speed_desc,
                style: FontManager.body2Median(ProtonColors.textWeak),
                textAlign: TextAlign.center,
              ),
              Text(
                "~ 10 minutes",
                style: FontManager.body2Median(ProtonColors.textNorm),
                textAlign: TextAlign.center,
              ),
            ]),
            const SizedBox(
              height: 26,
            ),
            ButtonV6(
                onPressed: () async {},
                text: S.of(context).rbf_confirm_speed_desc,
                width: MediaQuery.of(context).size.width,
                backgroundColor: ProtonColors.protonBlue,
                textStyle:
                    FontManager.body1Median(ProtonColors.backgroundSecondary),
                borderColor: ProtonColors.protonBlue,
                height: 48),
          ],
        ),
      ),
    );
  }
}
