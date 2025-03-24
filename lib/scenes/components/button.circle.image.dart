import 'package:flutter/material.dart';

class CircleImageButton extends StatelessWidget {
  final VoidCallback? onTap;
  final double size;
  final Color? backgroundColor;
  final Widget icon;

  const CircleImageButton({
    required this.icon,
    this.onTap,
    super.key,
    this.size = 40.0,
    this.backgroundColor = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor,
        ),
        child: ClipOval(
          child: Center(child: icon),
        ),
      ),
    );
  }
}
