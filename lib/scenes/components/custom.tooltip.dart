import 'package:flutter/material.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';

class CustomTooltip extends StatelessWidget {
  final String message;
  final Widget child;
  final AxisDirection? preferredDirection;

  const CustomTooltip({
    required this.message,
    required this.child,
    this.preferredDirection = AxisDirection.up,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return JustTheTooltip(
        tailLength: 12,
        tailBaseWidth: 16,
        margin: const EdgeInsets.symmetric(
          horizontal: defaultPadding * 2,
        ),
        preferredDirection: preferredDirection!,
        backgroundColor: ProtonColors.black,
        triggerMode: TooltipTriggerMode.tap,
        content: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            child: Text(
              message,
              style: ProtonStyles.body2Regular(color: ProtonColors.textInverted),
              textAlign: TextAlign.center,
            )),
        child: child);
  }
}
