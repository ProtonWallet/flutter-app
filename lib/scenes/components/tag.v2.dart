import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';

class TagV2 extends StatelessWidget {
  final int index;
  final String text;
  final double width;
  final EdgeInsetsGeometry? padding;

  const TagV2({
    super.key,
    this.padding,
    this.text = "",
    this.index = 1,
    this.width = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        width: width,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        padding: padding ??
            const EdgeInsets.only(
                left: 20.0, right: 20.0, top: 2.0, bottom: 2.0),
        decoration: BoxDecoration(
            color: ProtonColors.white,
            borderRadius: BorderRadius.circular(40.0)),
        child: Row(children: [
          SizedBox(
              width: 18,
              child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(index.toString(),
                      style: ProtonStyles.body2Regular(
                          color: ProtonColors.textNorm)))),
          const SizedBox(width: 20),
          Text(
            text,
            style: ProtonStyles.body2Regular(color: ProtonColors.textNorm),
          )
        ]));
  }
}
