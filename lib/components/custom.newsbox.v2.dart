import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/theme/theme.font.dart';

class CustomNewsBoxV2 extends StatelessWidget {
  final String title;
  final String content;
  final String iconPath;
  final double width;
  final Color headerBackground;

  const CustomNewsBoxV2({
    super.key,
    required this.title,
    required this.content,
    required this.iconPath,
    this.headerBackground = Colors.redAccent,
    this.width = 440,
  });

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      Container(
          width: width,
          decoration: BoxDecoration(
            color: ProtonColors.surfaceLight,
            borderRadius: BorderRadius.circular(24.0),
          ),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: headerBackground,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24.0),
                      topRight: Radius.circular(24.0)),
                ),
                width: width,
                height: 100,
                padding: const EdgeInsets.all(24),
                child: SvgPicture.asset(iconPath,
                    fit: BoxFit.fitHeight, width: 32, height: 32),
              ),
              Container(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Text(title,
                      style: FontManager.body1Median(ProtonColors.textNorm)))
            ],
          ))
    ]);
  }
}
