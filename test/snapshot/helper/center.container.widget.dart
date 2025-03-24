import 'package:flutter/widgets.dart';
import 'package:wallet/constants/proton.color.dart';

class CenterContainer extends StatelessWidget {
  const CenterContainer({
    required this.height,
    required this.child,
    super.key,
  });

  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: ProtonColors.backgroundNorm,
      child: Center(child: child),
    );
  }
}
