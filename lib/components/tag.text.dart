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
  final double? width;
  final String? hint;
  final CrossAxisAlignment crossAxisAlignment;

  const TagText({
    super.key,
    this.text = "",
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.onTap,
    this.hint,
    this.width,
    this.background = const Color(0xFFFEFEFE),
    this.textColor = const Color(0xFF0C0C14),
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
                width: width,
                alignment: Alignment.center,
                padding: const EdgeInsets.only(
                    left: 10.0, right: 10.0, top: 6.0, bottom: 6.0),
                decoration: BoxDecoration(
                    color: background,
                    borderRadius: BorderRadius.circular(radius)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                  Text(
                    text,
                    style: FontManager.captionMedian(textColor),
                  ),
                  if (hint != null)
                    Text(hint!,
                        style:
                            FontManager.overlineRegular(ProtonColors.textHint))
                ]))),
      ],
    );
  }
}
