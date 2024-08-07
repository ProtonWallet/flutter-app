import 'package:flutter/widgets.dart';

class FlyingAnimation extends StatefulWidget {
  final AnimationController? controller;
  final Widget child;

  const FlyingAnimation({
    required this.child,
    super.key,
    this.controller,
  });

  @override
  RotateChildState createState() => RotateChildState();
}

class RotateChildState extends State<FlyingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  bool isDisposed = false;

  @override
  void initState() {
    super.initState();
    controller = widget.controller ??
        AnimationController(
          duration: const Duration(milliseconds: 600),
          vsync: this,
        )
      ..repeat(reverse: true);

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!isDisposed) {
            controller.reverse();
          }
        });
      } else if (status == AnimationStatus.dismissed) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!isDisposed) {
            controller.forward();
          }
        });
      }
    });
    controller.forward();
  }

  @override
  void dispose() {
    isDisposed = true;
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      child: widget.child,
      builder: (context, child) {
        return Transform.rotate(
          angle: (controller.value + 0.8) * 0.12 * 3.1415926535897932,
          child: child,
        );
      },
    );
  }
}
