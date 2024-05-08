import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';

class BackButtonV1 extends StatelessWidget {
  final VoidCallback? onPressed;

  const BackButtonV1(
      {super.key,
        this.onPressed});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
        radius: 18,
        backgroundColor: ProtonColors.white,
        child: IconButton(
          icon: Icon(Icons.arrow_back_rounded,
              color: ProtonColors.textNorm, size: 16),
          onPressed: onPressed,
        ));
  }
}