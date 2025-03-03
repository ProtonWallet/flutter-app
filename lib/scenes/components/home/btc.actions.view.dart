import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/extension/build.context.extension.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/button.v5.dart';
import 'package:wallet/scenes/components/home/custom.homepage.box.dart';

class BtcTitleActionsView extends StatelessWidget {
  final GestureTapCallback? onSend;
  final GestureTapCallback? onBuy;
  final GestureTapCallback? onDisabledBuy;
  final GestureTapCallback? onReceive;
  final bool initialized;
  final bool disableBuy;

  const BtcTitleActionsView({
    required this.initialized,
    this.disableBuy = false,
    super.key,
    this.onSend,
    this.onBuy,
    this.onDisabledBuy,
    this.onReceive,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: CustomHomePageBox(
          children: buildActions(context),
        ),
      ),
    ]);
  }

  List<Widget> buildActions(BuildContext context) {
    final minWidth = disableBuy ? 174.0 : 160.0;
    final splitOffset = 42.0;
    final number = disableBuy ? 2 : 3;
    return [
      if (!disableBuy)
        ButtonV5(
          onPressed: onBuy,
          text: S.of(context).buy,
          width: min(minWidth, (context.width - splitOffset) / number),
          textStyle: ProtonStyles.body2Medium(color: ProtonColors.textNorm),
          backgroundColor: ProtonColors.interActionWeakDisable,
          borderColor: ProtonColors.interActionWeakDisable,
          height: 48,
          enable: initialized,
          disableWithAction: disableBuy,
          textDisableStyle: ProtonStyles.body1Medium(
            color: ProtonColors.textDisable,
          ),
          onDisablePressed: onDisabledBuy,
        ),
      ButtonV5(
        onPressed: onReceive,
        text: S.of(context).receive,
        width: min(minWidth, (context.width - splitOffset) / number),
        textStyle: ProtonStyles.body2Medium(color: ProtonColors.textNorm),
        backgroundColor: ProtonColors.interActionWeakDisable,
        borderColor: ProtonColors.interActionWeakDisable,
        height: 48,
        enable: initialized,
      ),
      ButtonV5(
        onPressed: onSend,
        text: S.of(context).send_button,
        width: min(minWidth, (context.width - splitOffset) / number),
        textStyle: ProtonStyles.body2Medium(color: ProtonColors.textNorm),
        backgroundColor: ProtonColors.interActionWeakDisable,
        borderColor: ProtonColors.interActionWeakDisable,
        height: 48,
        enable: initialized,
      ),
    ];
  }
}
