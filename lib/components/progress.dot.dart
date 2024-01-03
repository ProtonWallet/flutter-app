import 'package:flutter/cupertino.dart';
import 'package:wallet/constants/proton.color.dart';

class CircleProgressDot extends StatelessWidget {
  final bool enable;

  CircleProgressDot({this.enable = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      width: 10.0,
      height: 10.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: enable ? ProtonColors.interactionNorm : ProtonColors.textHint,
      ),
    );
  }
}
