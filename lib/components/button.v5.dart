import 'package:flutter/material.dart';

class ButtonV5 extends StatelessWidget {
  final String text;
  final double width;
  final double height;
  final double radius;
  final Color backgroundColor;
  final Color borderColor;
  final TextStyle textStyle;
  final VoidCallback? onPressed;
  final bool enable;

  const ButtonV5(
      {super.key,
      required this.text,
      required this.width,
      required this.height,
      this.onPressed,
      this.radius = 30.0,
      this.backgroundColor = const Color(0xFF6D4AFF),
      this.borderColor = Colors.transparent,
      this.textStyle = const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w400,
      ),
      this.enable = true});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Stack(alignment: Alignment.center, children: [
      ElevatedButton(
        style: ElevatedButton.styleFrom(
            fixedSize: Size(width, height),
            backgroundColor: backgroundColor,
            // foreground
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
              side: BorderSide(width: 1, color: borderColor),
            ),
            elevation: 0.4),
        onPressed: enable ? onPressed : () {},
        child: Text(
          text,
          style: textStyle,
        ),
      ),
      if (!enable)
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
    ]));
  }
}
