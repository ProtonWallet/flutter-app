import 'package:flutter/material.dart';

@Deprecated(
    " 'FontManager' is deprecated and shouldn't be used anymore. try to use '[ProtonStyles]' instead.")
class FontManager {
  static const String primaryFontFamily = 'Inter'; // font name

  static TextStyle sendAmount(Color color) {
    return TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 36,
        height: 1.2,
        // lineHeight = 34
        fontWeight: FontWeight.w500,
        color: color);
  }

  static TextStyle sendAmountSign(Color color) {
    return TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 36,
        height: 1.2,
        // lineHeight = 34
        fontWeight: FontWeight.w400,
        color: color);
  }

  static TextStyle balanceInFiatCurrency(Color color) {
    return TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 36,
        height: 1,
        // lineHeight = 16
        fontWeight: FontWeight.w400,
        color: color);
  }

  static TextStyle balanceInBTC(Color color) {
    return TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 16,
        height: 1,
        // lineHeight = 16
        fontWeight: FontWeight.w400,
        color: color);
  }

  static TextStyle transactionHistoryAmountTitle(Color color) {
    return TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 32,
        // lineHeight = 34
        fontWeight: FontWeight.w400,
        color: color);
  }

  static TextStyle titleHero(Color color) {
    return TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 28,
        height: 1.2,
        // lineHeight = 34
        fontWeight: FontWeight.bold,
        color: color);
  }

  static TextStyle titleSubHero(Color color) {
    return TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 24,
        height: 1.2,
        // lineHeight = 24
        fontWeight: FontWeight.bold,
        color: color);
  }

  static TextStyle titleHeadline(Color color) {
    return TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 20,
        height: 1.2,
        // lineHeight = 24
        fontWeight: FontWeight.bold,
        color: color);
  }

  static TextStyle titleSubHeadline(Color color) {
    return TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 20,
        height: 1.2,
        // lineHeight = 24
        fontWeight: FontWeight.w400,
        color: color);
  }

  static TextStyle discoveryTitle(Color color) {
    return TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 18,
        height: 1.2,
        // lineHeight = 24
        fontWeight: FontWeight.w500,
        color: color);
  }

  static TextStyle body1Bold(Color color) {
    return TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 16,
        height: 1.5,
        // lineHeight = 24
        fontWeight: FontWeight.bold,
        color: color);
  }

  static TextStyle body1Median(Color color) {
    return TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 16,
        height: 1.5,
        // lineHeight = 24
        fontWeight: FontWeight.w500,
        color: color);
  }

  static TextStyle actionButtonText(Color color) {
    return TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 14,
        height: 1.5,
        // lineHeight = 24
        fontWeight: FontWeight.w500,
        color: color);
  }

  static TextStyle body1Regular(Color color) {
    return TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 16,
        height: 1.5,
        // lineHeight = 24
        fontWeight: FontWeight.w400,
        color: color);
  }

  static TextStyle body2Median(Color color) {
    return TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 14,
        height: 1.42,
        // lineHeight = 20
        fontWeight: FontWeight.w500,
        color: color);
  }

  static TextStyle body2MedianLineThrough(Color color) {
    return TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 14,
        height: 1.42,
        // lineHeight = 20
        fontWeight: FontWeight.w500,
        decoration: TextDecoration.lineThrough,
        color: color);
  }

  static TextStyle body2Regular(Color color) {
    return TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 14,
        height: 1.42,
        // lineHeight = 20
        fontWeight: FontWeight.w400,
        color: color);
  }

  static TextStyle captionSemiBold(Color color) {
    return TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 12,
        height: 1.33,
        // lineHeight = 16
        fontWeight: FontWeight.w700,
        color: color);
  }

  static TextStyle captionMedian(Color color) {
    return TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 12,
        height: 1.33,
        // lineHeight = 16
        fontWeight: FontWeight.w500,
        color: color);
  }

  static TextStyle linkUnderline(Color color) {
    return TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 12,
        height: 1.33,
        // lineHeight = 16
        fontWeight: FontWeight.w500,
        decoration: TextDecoration.underline,
        decorationColor: color,
        color: color);
  }

  static TextStyle captionRegular(Color color) {
    return TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 12,
        height: 1.33,
        // lineHeight = 16
        fontWeight: FontWeight.w400,
        color: color);
  }

  static TextStyle textFieldLabelStyle(Color color) {
    return TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 14,
        height: 0.6,
        // lineHeight = 16
        fontWeight: FontWeight.w400,
        color: color);
  }

  static TextStyle overlineSemiBold(Color color) {
    return TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 10,
        height: 1.6,
        // lineHeight = 16
        fontWeight: FontWeight.w700,
        color: color);
  }

  static TextStyle overlineMedian(Color color) {
    return TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 10,
        height: 1.6,
        // lineHeight = 16
        fontWeight: FontWeight.w500,
        color: color);
  }

  static TextStyle overlineRegular(Color color) {
    return TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 10,
        height: 1.6,
        // lineHeight = 16
        fontWeight: FontWeight.w400,
        color: color);
  }

  static TextStyle twoFACode(Color color) {
    return TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 24,
        height: 1.6,
        // lineHeight = 20
        fontWeight: FontWeight.w400,
        color: color);
  }
}
