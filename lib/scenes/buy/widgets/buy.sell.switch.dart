import 'package:flutter/material.dart';
import 'package:wallet/l10n/generated/locale.dart';

class BuySellSwitch extends StatelessWidget {
  const BuySellSwitch({
    required this.showSell,
    super.key,
  });
  final bool showSell;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                S.of(context).buy,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF191C32),
                  fontSize: 16,
                  fontFamily: 'SF Pro Text',
                  fontWeight: FontWeight.w600,
                  height: 0.08,
                ),
              ),
            ],
          ),
        ),
        if (showSell)
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  S.of(context).sell,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF9294A3),
                    fontSize: 16,
                    fontFamily: 'SF Pro Text',
                    fontWeight: FontWeight.w600,
                    height: 0.08,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
