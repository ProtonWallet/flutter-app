import 'package:card_loading/card_loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/provider/theme.provider.dart';

const CardLoadingTheme defaultLightTheme = CardLoadingTheme(
  colorOne: Color(0xFFE5E5E5),
  colorTwo: Color(0xFFF0F0F0),
);

CardLoadingTheme defaultDarkTheme = CardLoadingTheme(
  colorOne: Color(0xFF454554),
  colorTwo: ProtonColors.backgroundSecondary,
);

class CustomCardLoadingBuilder {
  final double height;
  final double? width;
  final EdgeInsets? margin;
  final BorderRadius? borderRadius;
  final Duration animationDuration;
  final Duration animationDurationTwo;
  final Curve curve;
  final bool withChangeDuration;

  const CustomCardLoadingBuilder({
    required this.height,
    this.width,
    this.margin,
    this.borderRadius,
    this.animationDuration = const Duration(milliseconds: 750),
    this.animationDurationTwo = const Duration(milliseconds: 450),
    this.curve = Curves.easeInOutSine,
    this.withChangeDuration = true,
  });

  Widget build(BuildContext context) {
    final isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode();

    return CardLoading(
      height: height,
      width: width,
      margin: margin,
      borderRadius: borderRadius,
      animationDuration: animationDuration,
      animationDurationTwo: animationDurationTwo,
      cardLoadingTheme: isDarkMode ? defaultDarkTheme : defaultLightTheme,
      curve: curve,
      withChangeDuration: withChangeDuration,
    );
  }
}
