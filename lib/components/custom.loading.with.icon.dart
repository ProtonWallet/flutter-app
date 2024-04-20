import 'package:flutter/material.dart';

class CustomLoadingWithIcon extends StatefulWidget {
  final int durationInMilliSeconds;
  final Icon icon;

  const CustomLoadingWithIcon({
    super.key,
    this.durationInMilliSeconds = 1600,
    this.icon = const Icon(Icons.refresh_rounded, size: 22),
  });

  @override
  CustomLoadingWithIconState createState() => CustomLoadingWithIconState();
}

class CustomLoadingWithIconState extends State<CustomLoadingWithIcon>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void dispose() {
    if (_controller != null) {
      _controller!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _controller ??= AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.durationInMilliSeconds),
    )..repeat();

    return AnimatedBuilder(
      animation: _controller!,
      builder: (context, child) {
        return RotationTransition(
          turns: _controller!,
          child: widget.icon,
        );
      },
    );
  }
}
