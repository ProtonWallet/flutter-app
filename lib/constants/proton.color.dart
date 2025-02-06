import 'package:flutter/material.dart';

class ProtonColors {
  /// background colors
  static Color white = Colors.white;
  static Color clear = Colors.transparent;
  static Color backgroundNorm = const Color(0xFFF3F5F6);

  /// error dialog background color, used when deleting wallet/account has balance
  static Color errorBackground = const Color(0xFFFFE0E0);

  /// text colors
  static Color textNorm = const Color(0xFF0C0C14);
  static Color textDisable = const Color(0xffCED0DE);
  static Color textHint = const Color(0xFF9395A4);
  static Color textWeak = const Color(0xFF535964);
  static Color textInverted = const Color(0xFFFFFFFF);
  static Color interActionWeak = const Color(0XFFE6E8EC);

  /// slider colors, used for RBF
  static Color sliderActiveColor = const Color(0xFF8B8DF9);
  static Color sliderInactiveColor = const Color(0xFFCED0DE);

  /// alert colors
  static Color alertWaning = const Color(0xFFF78400);
  static Color alertWaningBackground = const Color(0x19FF9900);

  /// signal colors, used for btc price chart, status code
  static Color signalSuccess = const Color(0xFF1EA885);
  static Color signalError = const Color(0xFFFF6464);

  /// other one-time custom colors styles for widgets
  static Color launchBackground = const Color(0xff191927);
  static Color homeActionButtonBackground = const Color(0xFFE3E6ED);
  static Color black = const Color(0xFF000000);
  static Color expansionShadow = const Color(0XFFE0E2FF);
  static Color loadingShadow = const Color(0X22767DFF);
  static Color inputDoneOverlay = const Color(0XFFD9DDE1);
  static Color circularProgressIndicatorBackGround =
      const Color.fromARGB(51, 255, 255, 255);

  /// interAction-Norm, used for link, button background
  static Color protonBlue = const Color(0XFF767DFF);

  /// drawer colors
  static Color drawerBackground = const Color(0xFF222247);
  static Color drawerBackgroundHighlight = const Color(0x2AFFFFFF);

  /// bitcoin wallet avatar text and background colors
  static Color pink1Text = const Color(0xffeb8dd6);
  static Color pink1Background = const Color(0x48eb8dd6);
  static Color blue1Text = const Color(0xff66b6ff);
  static Color blue1Background = const Color(0x4866b6ff);
  static Color yellow1Text = const Color(0xffFFC483);
  static Color yellow1Background = const Color(0x88FFC483);
  static Color green1Text = const Color(0xff5fc88f);
  static Color green1Background = const Color(0x485fc88f);

  /// recipient avatar text and background colors
  static Color avatarOrange1Text = const Color(0xfffd8445);
  static Color avatarOrange1Background = const Color(0xffffede4);
  static Color avatarPink1Text = const Color(0xffd050b4);
  static Color avatarPink1Background = const Color(0xfffce6f8);
  static Color avatarPurple1Text = const Color(0xff685dad);
  static Color avatarPurple1Background = const Color(0xffebe7ff);
  static Color avatarBlue1Text = const Color(0xff214a77);
  static Color avatarBlue1Background = const Color(0xffe0f0ff);
  static Color avatarGreen1Text = const Color(0xff286a50);
  static Color avatarGreen1Background = const Color(0xffdff4e9);

  static void updateLightTheme() {
    /// update colors for light theme
  }

  static void updateDarkTheme() {
    /// update colors for dark theme
  }
}
