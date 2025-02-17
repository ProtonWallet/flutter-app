import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/constants/text.style.dart';

class AlertWarning extends StatelessWidget {
  final String content;
  final double width;

  const AlertWarning({
    required this.content,
    required this.width,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        width: width,
        padding: const EdgeInsets.only(
          top: 16,
          bottom: 16,
          right: 20,
          left: 20,
        ),
        decoration: BoxDecoration(
            color: ProtonColors.notificationWaningBackground,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              color: ProtonColors.notificationWaning,
            )),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: ProtonColors.notificationWaning),
                SizedBoxes.box8,
                Expanded(
                    child: Text(content,
                        style:
                            ProtonStyles.body2Regular(color:ProtonColors.notificationWaning)))
              ],
            )
          ],
        ));
  }
}
