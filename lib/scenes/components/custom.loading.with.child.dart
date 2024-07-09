import 'package:flutter/material.dart';

class CustomLoadingWithChild extends StatefulWidget {
  final int durationInMilliSeconds;
  final Widget child;

  const CustomLoadingWithChild({
    super.key,
    this.durationInMilliSeconds = 1600,
    this.child = const Icon(Icons.refresh_rounded, size: 22),
  });

  @override
  CustomLoadingWithChildState createState() => CustomLoadingWithChildState();
}

class CustomLoadingWithChildState extends State<CustomLoadingWithChild>
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
          child: widget.child,
        );
      },
    );
  }
}
