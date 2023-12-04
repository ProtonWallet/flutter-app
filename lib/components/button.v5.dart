import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';

//TODO:: need to use a better button base class
class ButtonV5 extends StatelessWidget {
  final String text;
  final double width;
  final double height;
  final double radius;
  final Color backgroundColor;
  final TextStyle textStyle;

  const ButtonV5({
    super.key,
    required this.text,
    required this.width,
    required this.height,
    this.radius = 0.1,
    this.backgroundColor = ProtonColors.interactionNorm,
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
      onPressed: () {},
      style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: radius),
          fixedSize: Size(width, height),
          backgroundColor: backgroundColor,
// shape: EdgeInsets.,
          elevation: 0),
      child: Text(
        text,
        style: textStyle,
      ),
    );
  }
}
