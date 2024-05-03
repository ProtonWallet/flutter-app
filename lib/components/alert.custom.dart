import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/theme/theme.font.dart';

class AlertCustom extends StatelessWidget {
  final String content;
  final double? width;
  final Widget? learnMore;
  final Widget? leadingWidget;
  final Border? border;
  final Color? backgroundColor;
  final Color? color;

  const AlertCustom({
    super.key,
    required this.content,
    this.width,
    this.learnMore,
    this.leadingWidget,
    this.border,
    this.backgroundColor,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        width: width ?? MediaQuery.of(context).size.width,
        padding:
            const EdgeInsets.only(top: 16, bottom: 16, right: 20, left: 20),
        decoration: BoxDecoration(
            color: backgroundColor ?? ProtonColors.alertWaningBackground,
            borderRadius: BorderRadius.circular(10.0),
            border: border ??
                Border.all(
                  color: ProtonColors.alertWaning,
                  width: 1.0,
                )),
        child: Column(
          children: [
            Row(
              children: [
                leadingWidget ??
                    Icon(Icons.warning,
                        color: color ?? ProtonColors.alertWaning),
                const SizedBox(width: 8),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(content,
                          style: FontManager.body2Regular(
                              color ?? ProtonColors.alertWaning)),
                      if (learnMore != null)
                        Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: learnMore!),
                    ]))
              ],
            )
          ],
        ));
  }
}
