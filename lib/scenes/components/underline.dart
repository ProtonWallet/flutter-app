import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';

class Underline extends StatelessWidget {
  final Widget child;
  final Color? color;
  final VoidCallback? onTap;

  const Underline({
    required this.child,
    super.key,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: color ?? ProtonColors.textNorm,
                  width: 0.3,
                ),
              ),
            ),
            child: child));
  }
}
