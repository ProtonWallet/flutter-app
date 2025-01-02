import 'package:flutter/material.dart';
import 'package:wallet/constants/fonts.gen.dart';

/// define general styles in proton ecosystem
class ProtonStyles {
  static TextStyle hero({Color? color}) {
    return TextStyle(
      fontFamily: FontFamily.inter,
      fontSize: 28,
      fontVariations: const <FontVariation>[FontVariation('wght', 600.0)],
      height: 34 / 28,
      letterSpacing: 0,
      color: color,
    );
  }

  static TextStyle headline({
    Color? color,
    double fontSize = 20.0,
  }) {
    return TextStyle(
      fontFamily: FontFamily.inter,
      fontSize: fontSize,
      fontVariations: const <FontVariation>[FontVariation('wght', 700.0)],
      height: 24 / 20,
      letterSpacing: 0,
      color: color,
    );
  }

  static TextStyle subheadline({
    Color? color,
    double fontVariation = 600.0,
  }) {
    return TextStyle(
      fontFamily: FontFamily.inter,
      fontSize: 20,
      fontVariations: <FontVariation>[FontVariation('wght', fontVariation)],
      height: 24 / 20,
      letterSpacing: 0,
      color: color,
    );
  }

  /// body 1
  static TextStyle body1Semibold({Color? color}) {
    return TextStyle(
      fontFamily: FontFamily.inter,
      fontSize: 16,
      fontVariations: const <FontVariation>[FontVariation('wght', 600.0)],
      height: 24 / 16,
      letterSpacing: 0,
      color: color,
    );
  }

  static TextStyle body1Medium({Color? color}) {
    return TextStyle(
      fontFamily: FontFamily.inter,
      fontSize: 16,
      fontVariations: const <FontVariation>[FontVariation('wght', 500.0)],
      height: 24 / 16,
      letterSpacing: 0,
      color: color,
    );
  }

  static TextStyle body1Regular({Color? color}) {
    return TextStyle(
      fontFamily: FontFamily.inter,
      fontSize: 16,
      fontVariations: const <FontVariation>[FontVariation('wght', 400.0)],
      height: 24 / 16,
      letterSpacing: 0,
      color: color,
    );
  }

  /// body 2
  static TextStyle body2Semibold({Color? color}) {
    return TextStyle(
      fontFamily: FontFamily.inter,
      fontSize: 14,
      fontVariations: const <FontVariation>[FontVariation('wght', 600.0)],
      height: 20 / 14,
      letterSpacing: 0,
      color: color,
    );
  }

  static TextStyle body2Medium({
    Color? color,
    double fontSize = 14.0,
  }) {
    return TextStyle(
      fontFamily: FontFamily.inter,
      fontSize: fontSize,
      fontVariations: const <FontVariation>[FontVariation('wght', 500.0)],
      height: 20 / 14,
      letterSpacing: 0,
      color: color,
    );
  }

  static TextStyle body2Regular({
    Color? color,
    double fontSize = 14.0,
  }) {
    return TextStyle(
      fontFamily: FontFamily.inter,
      fontSize: fontSize,
      fontVariations: const <FontVariation>[FontVariation('wght', 400.0)],
      height: 20 / 14,
      letterSpacing: 0,
      color: color,
    );
  }

  /// caption
  static TextStyle captionSemibold({Color? color}) {
    return TextStyle(
      fontFamily: FontFamily.inter,
      fontSize: 12,
      fontVariations: const <FontVariation>[FontVariation('wght', 600.0)],
      height: 16 / 12,
      letterSpacing: 0,
      color: color,
    );
  }

  static TextStyle captionMedium({Color? color}) {
    return TextStyle(
      fontFamily: FontFamily.inter,
      fontSize: 12,
      fontVariations: const <FontVariation>[FontVariation('wght', 500.0)],
      height: 16 / 12,
      letterSpacing: 0,
      color: color,
    );
  }

  static TextStyle captionRegular({Color? color}) {
    return TextStyle(
      fontFamily: FontFamily.inter,
      fontSize: 12,
      fontVariations: const <FontVariation>[FontVariation('wght', 400.0)],
      height: 16 / 12,
      letterSpacing: 0,
      color: color,
    );
  }

  /// overline
  static TextStyle overlineMedium({Color? color}) {
    return TextStyle(
      fontFamily: FontFamily.inter,
      fontSize: 10,
      fontVariations: const <FontVariation>[FontVariation('wght', 500.0)],
      height: 14 / 10,
      letterSpacing: 0,
      color: color,
    );
  }

  static TextStyle overlineRegular({Color? color}) {
    return TextStyle(
      fontFamily: FontFamily.inter,
      fontSize: 10,
      fontVariations: const <FontVariation>[FontVariation('wght', 400.0)],
      height: 16 / 10,
      letterSpacing: 0,
      color: color,
    );
  }
}

/// define special styles in proton wallet
class ProtonWalletStyles {
  static TextStyle twoFACode({Color? color}) {
    return ProtonStyles.overlineRegular(color: color).copyWith(
      fontSize: 24,
    );
  }

  /// this is special text style in proton wallet, we only use it when display major amount
  static TextStyle textAmount({
    Color? color,
    double? fontSize,
    double fontVariation = 500.0,
    double height = 1.2,
  }) {
    return TextStyle(
      fontFamily: FontFamily.inter,
      fontSize: fontSize ?? 36,
      fontVariations: <FontVariation>[FontVariation('wght', fontVariation)],
      height: height,
      color: color,
    );
  }
}

/// maybe for theme later
// extension TextStyles on BuildContext {
//   TextStyle headline1({Color? color}) {
//     return Theme.of(this).textTheme.headline1!.copyWith(
//           color: color ?? Theme.of(this).primaryColor,
//         );
//   }

//   TextStyle bodyText1({Color? color}) {
//     return Theme.of(this).textTheme.bodyText1!.copyWith(
//           color: color ?? Theme.of(this).textTheme.bodyText1!.color,
//         );
//   }
// }
