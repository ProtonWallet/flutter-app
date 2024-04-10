import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/theme/theme.font.dart';

class TransactionFeeBox extends StatelessWidget {
  final String priorityText;
  final String timeEstimate;
  final double fee;

  const TransactionFeeBox({
    super.key,
    required this.priorityText,
    required this.timeEstimate,
    required this.fee,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
          color: ProtonColors.surfaceLight,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: const Color.fromARGB(255, 226, 226, 226),
            width: 1.0,
          )),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(priorityText,
              style: FontManager.body1Median(ProtonColors.textNorm)),
          Text(timeEstimate,
              style: FontManager.captionRegular(ProtonColors.textHint)),
          const SizedBox(
            height: 8,
          ),
          Text("~${fee.toStringAsFixed(2)} sat/vB",
              style: FontManager.body2Regular(ProtonColors.signalSuccess)),
        ],
      ),
    );
  }
}
