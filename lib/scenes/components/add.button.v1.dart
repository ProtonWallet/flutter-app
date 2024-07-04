import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';

class AddButtonV1 extends StatelessWidget {
  final VoidCallback? onPressed;

  const AddButtonV1({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(width: 1, color: ProtonColors.protonBlue)),
        child: GestureDetector(
          onTap: onPressed,
          child: Icon(Icons.add_rounded,
              color: ProtonColors.protonBlue, size: 16),
        ));
  }
}
