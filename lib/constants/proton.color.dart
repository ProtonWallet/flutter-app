import 'package:flutter/material.dart';

class ProtonColors {
  static bool initialized = false;
  static Color white = Colors.white;
  static Color clear = Colors.transparent;

  /// background colors
  static Color backgroundNorm = const Color(0xFFF3F5F6);
  static Color backgroundSecondary = const Color(0xFFFFFFFF);
  static Color backgroundWelcomePage = const Color(0xFFFEF0E5);

  /// app on load default background colors, used before color loaded
  static Color defaultLoadBackgroundLight = const Color(0xFFFFFFFF);
  static Color defaultLoadBackgroundDark = const Color(0xFF191C32);

  /// error dialog background color, used when deleting wallet/account has balance
  static Color errorBackground = const Color(0xFFFFE0E0);

  /// text colors
  static Color textNorm = const Color(0xFF191C32);
  static Color textDisable = const Color(0xffCED0DE);
  static Color textHint = const Color(0xFF9395A4);
  static Color textWeak = const Color(0xFF535964);
  static Color textInverted = const Color(0xFFFFFFFF);
  static Color interActionWeak = const Color(0XFFE6E8EC);

  /// slider colors, used for RBF
  static Color sliderActiveColor = const Color(0xFF8B8DF9);
  static Color sliderInactiveColor = const Color(0xFFCED0DE);

  /// notification colors, used for btc price chart, status code, warning
  static Color notificationWaning = const Color(0xFFFE9964);
  static Color notificationWaningBackground = const Color(0xFFFFEDE4);
  static Color notificationSuccess = const Color(0xFF5DA662);
  static Color notificationError = const Color(0xFFED4349);

  /// other one-time custom colors styles for widgets
  static Color launchBackground = const Color(0xff191927);
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

  /// drawer wallet/account text color
  static Color drawerWalletOrange1Text = const Color(0xFFFF8D52);
  static Color drawerWalletPink1Text = const Color(0xFFFF68DE);
  static Color drawerWalletPurple1Text = const Color(0xff9553F9);
  static Color drawerWalletBlue1Text = const Color(0xFF536CFF);
  static Color drawerWalletGreen1Text = const Color(0xFF52CC9C);

  /// recipient avatar text and background colors
  static Color avatarOrange1Text = const Color(0xffFF6464);
  static Color avatarOrange1Background = const Color(0xffffede4);
  static Color avatarPink1Text = const Color(0xffEC4DC8);
  static Color avatarPink1Background = const Color(0xfffce6f8);
  static Color avatarPurple1Text = const Color(0xff9553F9);
  static Color avatarPurple1Background = const Color(0xffebe7ff);
  static Color avatarBlue1Text = const Color(0xff0047AB);
  static Color avatarBlue1Background = const Color(0xffe0f0ff);
  static Color avatarGreen1Text = const Color(0xff059A6F);
  static Color avatarGreen1Background = const Color(0xffDEF5E9);

  /// update colors for light theme
  static void updateLightTheme() {
    initialized = true;

    /// background colors
    backgroundNorm = const Color(0xFFF3F5F6);
    backgroundSecondary = const Color(0xFFFFFFFF);
    backgroundWelcomePage = const Color(0xFFFEF0E5);

    /// error dialog background color, used when deleting wallet/account has balance
    errorBackground = const Color(0xFFFFE0E0);

    /// text colors
    textNorm = const Color(0xFF191C32);
    textDisable = const Color(0xffCED0DE);
    textHint = const Color(0xFF9395A4);
    textWeak = const Color(0xFF535964);
    textInverted = const Color(0xFFFFFFFF);
    interActionWeak = const Color(0XFFE6E8EC);

    /// slider colors, used for RBF
    sliderActiveColor = const Color(0xFF8B8DF9);
    sliderInactiveColor = const Color(0xFFCED0DE);

    /// notification colors, used for btc price chart, status code, warning
    notificationWaning = const Color(0xFFFE9964);
    notificationWaningBackground = const Color(0xFFFFEDE4);
    notificationSuccess = const Color(0xFF5DA662);
    notificationError = const Color(0xFFED4349);

    /// other one-time custom colors styles for widgets
    launchBackground = const Color(0xff191927);
    black = const Color(0xFF000000);
    expansionShadow = const Color(0XFFE0E2FF);
    loadingShadow = const Color(0X22767DFF);
    inputDoneOverlay = const Color(0XFFD9DDE1);
    circularProgressIndicatorBackGround =
        const Color.fromARGB(51, 255, 255, 255);

    /// interAction-Norm, used for link, button background
    protonBlue = const Color(0XFF767DFF);

    /// drawer colors
    drawerBackground = const Color(0xFF222247);
    drawerBackgroundHighlight = const Color(0x2AFFFFFF);

    /// recipient avatar text and background colors
    avatarOrange1Text = const Color(0xffFF6464);
    avatarOrange1Background = const Color(0xffffede4);
    avatarPink1Text = const Color(0xffEC4DC8);
    avatarPink1Background = const Color(0xfffce6f8);
    avatarPurple1Text = const Color(0xff9553F9);
    avatarPurple1Background = const Color(0xffebe7ff);
    avatarBlue1Text = const Color(0xff0047AB);
    avatarBlue1Background = const Color(0xffe0f0ff);
    avatarGreen1Text = const Color(0xff059A6F);
    avatarGreen1Background = const Color(0xffDEF5E9);
  }

  /// update colors for dark theme
  static void updateDarkTheme() {
    initialized = true;

    /// background colors
    backgroundNorm = const Color(0xFF222247);
    backgroundSecondary = const Color(0xFF191C32);
    backgroundWelcomePage = const Color(0XFF272852);

    /// text colors
    textNorm = const Color(0xFFFFFFFF);
    textDisable = const Color(0xff646481);
    textHint = const Color(0xFFA6A6B5);
    textWeak = const Color(0xFFBFBFD0);
    textInverted = const Color(0xFF191C32);
    interActionWeak = const Color(0XFF3D3D5E);

    /// slider colors, used for RBF
    sliderActiveColor = const Color(0xFF8B8DF9);
    sliderInactiveColor = const Color(0XFF1A1814);

    /// other one-time custom colors styles for widgets
    launchBackground = const Color(0xFFE6E6D8);
    black = const Color(0xFFFFFFFF);
    expansionShadow = const Color(0XFF5B5BA3);
    loadingShadow = const Color(0X229494FF);
    inputDoneOverlay = const Color(0XFFD9DDE1);
    circularProgressIndicatorBackGround =
        const Color.fromARGB(51, 255, 255, 255);

    /// interAction-Norm, used for link, button background
    protonBlue = const Color(0XFF9494FF);

    /// recipient avatar text and background colors
    avatarOrange1Text = const Color(0XFFFF8D52);
    avatarOrange1Background = const Color(0XFF5D4335);
    avatarPink1Text = const Color(0XFFFF68DE);
    avatarPink1Background = const Color(0XFF5E4157);
    avatarPurple1Text = const Color(0XFF9584FE);
    avatarPurple1Background = const Color(0XFF413969);
    avatarBlue1Text = const Color(0XFF536CFF);
    avatarBlue1Background = const Color(0XFF333A62);
    avatarGreen1Text = const Color(0XFF52CC9C);
    avatarGreen1Background = const Color(0XFF1A3C2E);
  }
}
