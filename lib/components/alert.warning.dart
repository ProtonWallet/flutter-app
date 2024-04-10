import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/theme/theme.font.dart';

class AlertWarning extends StatelessWidget {
  final String content;
  final double width;

  const AlertWarning({
    super.key,
    required this.content,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        width: width,
        padding:
            const EdgeInsets.only(top: 16, bottom: 16, right: 20, left: 20),
        decoration: BoxDecoration(
            color: ProtonColors.alertWaningBackground,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              color: ProtonColors.alertWaning,
              width: 1.0,
            )),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: ProtonColors.alertWaning),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(content,
                        style:
                            FontManager.body2Regular(ProtonColors.alertWaning)))
              ],
            )
          ],
        ));
  }
}
