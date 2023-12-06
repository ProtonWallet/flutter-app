import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';

class ButtonV5 extends StatelessWidget {
  final String text;
  final double width;
  final double height;
  final double radius;
  final Color backgroundColor;
  final Color borderColor;
  final TextStyle textStyle;
  final VoidCallback? onPressed;

  const ButtonV5({
    super.key,
    required this.text,
    required this.width,
    required this.height,
    this.onPressed,
    this.radius = 8.0,
    this.backgroundColor = ProtonColors.interactionNorm,
    this.borderColor = ProtonColors.clear,
    this.textStyle = const TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w400,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          fixedSize: Size(width, height),
          backgroundColor: backgroundColor, // foreground
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
            side: BorderSide(width: 1, color: borderColor),
          ),
          elevation: 2),
      onPressed: onPressed,
      child: Text(
        text,
        style: textStyle,
      ),
    );
  }
}
