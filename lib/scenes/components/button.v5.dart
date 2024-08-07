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
  final double? elevation;
  final Size? maximumSize;

  const ButtonV5(
      {required this.text,
      required this.width,
      required this.height,
      super.key,
      this.onPressed,
      this.radius = 24.0,
      this.elevation = 0.0,
      this.backgroundColor = const Color(0xFF6D4AFF),
      this.borderColor = Colors.transparent,
      this.textStyle = const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w400,
      ),
      this.enable = true,
      this.maximumSize = Size.infinite});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Stack(alignment: Alignment.center, children: [
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          maximumSize: maximumSize,
          fixedSize: Size(width, height),
          backgroundColor: backgroundColor,
          // foreground
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
            side: BorderSide(color: borderColor),
          ),
          elevation: elevation,
        ),
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
