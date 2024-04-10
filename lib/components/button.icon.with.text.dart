import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/theme/theme.font.dart';

class ButtonIconWithText extends StatelessWidget {
  final String text;
  final VoidCallback? callback;
  final Icon? icon;

  const ButtonIconWithText({
    super.key,
    this.text = "",
    this.icon,
    this.callback,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: callback,
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ProtonColors.textHint,
              ),
              child: icon,
            ),
            const SizedBox(height: 2), // 间距
            Text(
              text,
              style: FontManager.body2Regular(ProtonColors.textNorm),
            ),
          ],
        ));
  }
}
