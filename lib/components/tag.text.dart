import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/theme/theme.font.dart';

class TagText extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final Color background;
  final Color textColor;
  final double radius;

  const TagText({
    super.key,
    this.text = "",
    this.onTap,
    this.background = ProtonColors.surfaceTagText,
    this.textColor = ProtonColors.textNorm,
    this.radius = 6.0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        GestureDetector(
            onTap: onTap,
            child: Container(
                padding: const EdgeInsets.only(
                    left: 10.0, right: 10.0, top: 6.0, bottom: 6.0),
                decoration: BoxDecoration(
                    color: background,
                    borderRadius: BorderRadius.circular(radius)),
                child: Text(
                  text,
                  style: FontManager.captionMedian(textColor),
                ))),
      ],
    );
  }
}
