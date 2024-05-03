import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';

class CloseButtonV1 extends StatelessWidget {
  final VoidCallback? onPressed;

  const CloseButtonV1(
      {super.key,
        this.onPressed});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
        radius: 18,
        backgroundColor: ProtonColors.white,
        child: IconButton(
          icon: Icon(Icons.close_rounded,
              color: ProtonColors.textNorm, size: 16),
          onPressed: onPressed,
        ));
  }
}
