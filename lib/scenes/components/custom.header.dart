import 'package:flutter/material.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/scenes/components/close.button.v1.dart';
import 'package:wallet/theme/theme.font.dart';

class CustomHeader extends StatelessWidget {
  final String? title;
  final AxisDirection buttonDirection;
  final Widget? button;
  final EdgeInsets? padding;

  const CustomHeader({
    required this.buttonDirection,
    this.title,
    this.button,
    this.padding,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: padding ??
            const EdgeInsets.symmetric(
              horizontal: defaultPadding,
              vertical: defaultPadding,
            ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buttonDirection == AxisDirection.left
                ? Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: button ??
                          CloseButtonV1(onPressed: () {
                            Navigator.of(context).pop();
                          }),
                    ),
                  )
                : const Spacer(),
            Expanded(
              flex: 3,
              child: Text(
                title ?? "",
                style: FontManager.body1Median(ProtonColors.textNorm),
                textAlign: TextAlign.center,
              ),
            ),
            buttonDirection == AxisDirection.right
                ? Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: button ??
                          CloseButtonV1(onPressed: () {
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
