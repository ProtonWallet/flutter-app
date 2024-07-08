import 'package:flutter/widgets.dart';

class FlyingBackgroundAnimation extends StatefulWidget {
  final Widget child;
  final int animationMilliSeconds;
  final int delayMilliSeconds;

  const FlyingBackgroundAnimation({
    super.key,
    required this.child,
    required this.animationMilliSeconds,
    required this.delayMilliSeconds,
  });

  @override
  FlyingBackgroundAnimationState createState() =>
      FlyingBackgroundAnimationState();
}

class FlyingBackgroundAnimationState extends State<FlyingBackgroundAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: Duration(milliseconds: widget.animationMilliSeconds),
      vsync: this,
    )..repeat(reverse: false);
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 200), () {
          controller.reset();
          controller.forward();
        });
      }
    });
    Future.delayed( Duration(milliseconds: widget.delayMilliSeconds), (){
      controller.forward();
    });
    animation = Tween<double>(
      begin: 1.0,
      end: -1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: widget.child,
      builder: (context, child) {
        return Transform.translate(
          offset:
              Offset(MediaQuery.of(context).size.width * animation.value, 0),
          child: child,
        );
      },
    );
  }
}
