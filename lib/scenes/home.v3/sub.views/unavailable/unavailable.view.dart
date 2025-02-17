import 'package:flutter/material.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/extension/asset.gen.image.extension.dart';
import 'package:wallet/helper/extension/build.context.extension.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/button.v6.dart';
import 'package:wallet/scenes/components/close.button.v1.dart';
import 'package:wallet/scenes/components/custom.header.dart';
import 'package:wallet/scenes/components/page.layout.v1.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/home.v3/sub.views/unavailable/unavailable.viewmodel.dart';

class UnavailableView extends ViewBase<UnavailableViewModel> {
  const UnavailableView(UnavailableViewModel viewModel)
      : super(viewModel, const Key("UnavailableView"));

  @override
  Widget build(BuildContext context) {
    return PageLayoutV1(
      backgroundColor: ProtonColors.backgroundSecondary,
      headerWidget: CustomHeader(
        buttonDirection: AxisDirection.right,
        padding: const EdgeInsets.all(0.0),
        button: CloseButtonV1(
          onPressed: () {
            Navigator.of(context).pop();
          },
          backgroundColor: ProtonColors.backgroundNorm,
        ),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Transform.translate(
          offset: const Offset(0, -2),
          child: Column(children: [
            Assets.images.icon.earlyAccess.applyThemeIfNeeded(context).image(
                  fit: BoxFit.fill,
                  width: 240,
                  height: 167,
                ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                S.of(context).buying_unavailable,
                style: ProtonStyles.headingSmallSemiBold(
                  color: ProtonColors.textNorm,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            Text.rich(
              textAlign: TextAlign.center,
              TextSpan(
                text: S.of(context).buying_unavailable_description,
                style: ProtonStyles.bodySmallSemibold(
                  color: ProtonColors.textWeak,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Column(children: [
                const SizedBox(
                  height: 12,
                ),
                ButtonV6(
                  onPressed: () async {
                    Navigator.of(context).pop();
                  },
                  text: S.of(context).close,
                  width: context.width,
                  textStyle: ProtonStyles.body1Semibold(
                    color: ProtonColors.textNorm,
                  ),
                  backgroundColor: ProtonColors.interActionWeak,
                  borderColor: ProtonColors.interActionWeak,
                  height: 55,
                ),
              ]),
            ),
          ]),
        )
      ]),
    );
  }
}
