import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:wallet/theme/theme.font.dart';

class CustomTooltip extends StatelessWidget {
  final String message;
  final Widget child;

  const CustomTooltip({
    super.key,
    required this.message,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return JustTheTooltip(
        tailLength: 12,
        tailBaseWidth: 16,
        preferredDirection: AxisDirection.up,
        backgroundColor: ProtonColors.backgroundBlack,
        triggerMode: TooltipTriggerMode.tap,
        content: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(message,
                style: FontManager.body2Regular(ProtonColors.white), textAlign: TextAlign.center,)),
        child: child);
  }
}
