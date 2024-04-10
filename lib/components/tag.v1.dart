import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/theme/theme.font.dart';

class TagV1 extends StatelessWidget {
  final bool enable;
  final int index;
  final String text;
  final VoidCallback? onTap;

  const TagV1(
      {super.key,
      this.enable = true,
      this.text = "",
      this.index = 1,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        GestureDetector(
            onTap: onTap,
            child: Container(
                margin: const EdgeInsets.only(left: 0, right: 10, top: 8),
                padding: const EdgeInsets.only(
                    left: 20.0, right: 20.0, top: 8.0, bottom: 8.0),
                decoration: BoxDecoration(
                    color: enable
                        ? ProtonColors.interactionNorm
                        : ProtonColors.white,
                    borderRadius: BorderRadius.circular(6.0)),
                child: Text(
                  text,
                  style: enable
                      ? FontManager.body2Regular(ProtonColors.white)
                      : FontManager.body2Regular(ProtonColors.textNorm),
                ))),
        if (enable)
          Positioned(
            top: 0.0,
            right: 2.0,
            child: Container(
              width: 24.0,
              height: 24.0,
              decoration: BoxDecoration(
                  color: ProtonColors.textNorm, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(
                index.toString(),
                style: FontManager.captionMedian(ProtonColors.white),
              ),
            ),
          )
      ],
    );
  }
}
