import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';

class CustomLoading extends StatefulWidget {
  final int durationInMilliSeconds;
  final double size;
  final double strokeWidth;
  final Color? color;
  final Color? backgroundColor;

  const CustomLoading(
      {super.key,
      this.durationInMilliSeconds = 1200,
      this.size = 12,
      this.strokeWidth = 2.0,
      this.color,
      this.backgroundColor});

  @override
  CustomLoadingState createState() => CustomLoadingState();
}

class CustomLoadingState extends State<CustomLoading>
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

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller!,
        builder: (context, child) {
          return CircularProgressIndicator(
            value: _controller!.value,
            valueColor: AlwaysStoppedAnimation<Color>(
                widget.color ?? ProtonColors.protonBlue),
            backgroundColor:
                widget.backgroundColor ?? ProtonColors.loadingShadow,
            strokeWidth: widget.strokeWidth,
          );
        },
      ),
    );
  }
}
