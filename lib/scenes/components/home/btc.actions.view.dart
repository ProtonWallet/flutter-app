import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/button.v5.dart';
import 'package:wallet/scenes/components/home/custom.homepage.box.dart';
import 'package:wallet/theme/theme.font.dart';

class BtcTitleActionsView extends StatelessWidget {
  final GestureTapCallback? onSend;
  final GestureTapCallback? onBuy;
  final GestureTapCallback? onReceive;

  const BtcTitleActionsView({
    super.key,
    this.onSend,
    this.onBuy,
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
    return [
      ButtonV5(
        onPressed: onBuy,
        text: S.of(context).buy,
        width: min(160, (MediaQuery.of(context).size.width - 42) / 3),
        textStyle: FontManager.actionButtonText(ProtonColors.textNorm),
        backgroundColor: ProtonColors.homeActionButtonBackground,
        borderColor: ProtonColors.homeActionButtonBackground,
        height: 48,
        elevation: 0,
      ),
      ButtonV5(
        onPressed: onReceive,
        text: S.of(context).receive,
        width: min(160, (MediaQuery.of(context).size.width - 42) / 3),
        textStyle: FontManager.actionButtonText(ProtonColors.textNorm),
        backgroundColor: ProtonColors.homeActionButtonBackground,
        borderColor: ProtonColors.homeActionButtonBackground,
        height: 48,
        elevation: 0,
      ),
      ButtonV5(
        onPressed: onSend,
        text: S.of(context).send_button,
        width: min(160, (MediaQuery.of(context).size.width - 42) / 3),
        textStyle: FontManager.actionButtonText(ProtonColors.textNorm),
        backgroundColor: ProtonColors.homeActionButtonBackground,
        borderColor: ProtonColors.homeActionButtonBackground,
        height: 48,
        elevation: 0,
      ),
    ];
  }
}
