import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';

class CloseButtonV1 extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? backgroundColor;

  const CloseButtonV1({
    super.key,
    this.onPressed,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: backgroundColor ?? ProtonColors.textInverted,
      child: IconButton(
        icon: Icon(
          Icons.close_rounded,
          color: ProtonColors.textNorm,
          size: 16,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
