import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/close.button.v1.dart';
import 'package:wallet/theme/theme.font.dart';

class CustomHeader extends StatelessWidget {
  final String title;
  final AxisDirection closeButtonDirection;

  const CustomHeader({
    super.key,
    required this.title,
    required this.closeButtonDirection,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: defaultPadding,
          vertical: defaultPadding,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            closeButtonDirection == AxisDirection.left
                ? Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: CloseButtonV1(onPressed: () {
                        Navigator.of(context).pop();
                      }),
                    ),
                  )
                : const Spacer(),
            Expanded(
              flex: 3,
              child: Text(
                title,
                style: FontManager.body1Median(ProtonColors.textNorm),
                textAlign: TextAlign.center,
              ),
            ),
            closeButtonDirection == AxisDirection.right
                ? Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: CloseButtonV1(onPressed: () {
                        Navigator.of(context).pop();
                      }),
                    ),
                  )
                : const Spacer(),
          ],
        ),
      ),
    );
  }
}
