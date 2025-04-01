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

  /// text colors
  static Color textNorm = const Color(0xFF191C32);
  static Color iconNorm = const Color(0xFF191C32);
  static Color textDisable = const Color(0xffCED0DE);
  static Color textHint = const Color(0xFF9395A4);
  static Color textWeak = const Color(0xFF535964);
  static Color textInverted = const Color(0xFFFFFFFF);
  static Color interActionWeakDisable = const Color(0xFFE6E8EC);
  static Color interActionWeakPressed = const Color(0xFFE2E2E2);

  /// slider colors, used for RBF
  static Color sliderActiveColor = const Color(0xFF8B8DF9);
  static Color sliderInactiveColor = const Color(0xFFCED0DE);

  /// notification colors, used for btc price chart, status code, warning
  static Color notificationWaning = const Color(0xFFFE9964);
  static Color notificationWaningBackground = const Color(0xFFFFEDE4);
  static Color notificationSuccess = const Color(0xFF5DA662);
  static Color notificationError = const Color(0xFFED4349);
  static Color notificationErrorBackground = const Color(0xFFFFE0E0);
  static Color notificationNorm = const Color(0xFF767DFF);
  static Color notificationNormBackground = const Color(0xFFD7D7FF);

  /// other one-time custom colors styles for widgets
  static Color launchBackground = const Color(0xff191927);
  static Color black = const Color(0xFF000000);
  static Color expansionShadow = const Color(0xFFE0E2FF);
  static Color loadingShadow = const Color(0x22767DFF);
  static Color inputDoneOverlay = const Color(0xFFD9DDE1);
  static Color circularProgressIndicatorBackGround =
      const Color.fromARGB(51, 255, 255, 255);

  /// interAction-Norm, used for link, button background
  static Color protonBlue = const Color(0xFF767DFF);

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

  /// appbar divider color
  static Color appBarDividerColor = const Color(0xFFE6E8EC);

  /// update colors for light theme
  static void updateLightTheme() {
    initialized = true;

    /// background colors
    backgroundNorm = const Color(0xFFF3F5F6);
    backgroundSecondary = const Color(0xFFFFFFFF);
    backgroundWelcomePage = const Color(0xFFFEF0E5);

    /// text colors
    textNorm = const Color(0xFF191C32);
    iconNorm = const Color(0xFF191C32);
    textDisable = const Color(0xffCED0DE);
    textHint = const Color(0xFF9395A4);
    textWeak = const Color(0xFF535964);
    textInverted = const Color(0xFFFFFFFF);
    interActionWeakDisable = const Color(0xFFE6E8EC);
    interActionWeakPressed = const Color(0xFFE2E2E2);

    /// slider colors, used for RBF
    sliderActiveColor = const Color(0xFF8B8DF9);
    sliderInactiveColor = const Color(0xFFCED0DE);

    /// notification colors, used for btc price chart, status code, warning
    notificationWaning = const Color(0xFFFE9964);
    notificationWaningBackground = const Color(0xFFFFEDE4);
    notificationSuccess = const Color(0xFF5DA662);
    notificationError = const Color(0xFFED4349);
    notificationErrorBackground = const Color(0xFFFFE0E0);
    notificationNorm = const Color(0xFF767DFF);
    notificationNormBackground = const Color(0xFFD7D7FF);

    /// other one-time custom colors styles for widgets
    launchBackground = const Color(0xff191927);
    black = const Color(0xFF000000);
    expansionShadow = const Color(0xFFE0E2FF);
    loadingShadow = const Color(0x22767DFF);
    inputDoneOverlay = const Color(0xFFD9DDE1);
    circularProgressIndicatorBackGround =
        const Color.fromARGB(51, 255, 255, 255);

    /// interAction-Norm, used for link, button background
    protonBlue = const Color(0xFF767DFF);

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

    /// appbar divider color
    appBarDividerColor = const Color(0xFFE6E8EC);
  }

  /// update colors for dark theme
  static void updateDarkTheme() {
    initialized = true;

    /// background colors
    backgroundNorm = const Color(0xFF222247);
    backgroundSecondary = const Color(0xFF191C32);
    backgroundWelcomePage = const Color(0xFF272852);

    /// text colors
    textNorm = const Color(0xFFFFFFFF);
    iconNorm = const Color(0xFFFFFFFF);
    textDisable = const Color(0xff646481);
    textHint = const Color(0xFFA6A6B5);
    textWeak = const Color(0xFFBFBFD0);
    textInverted = const Color(0xFF191C32);
    interActionWeakDisable = const Color(0xFF454554);
    interActionWeakPressed = const Color(0xFFE2E2E2);

    /// slider colors, used for RBF
    sliderActiveColor = const Color(0xFF8B8DF9);
    sliderInactiveColor = const Color(0xFF1A1814);

    /// notification colors, used for btc price chart, status code, warning
    notificationWaning = const Color(0xFFFF9761);
    notificationWaningBackground = const Color(0xFF29180F);
    notificationSuccess = const Color(0xFF88F189);
    notificationError = const Color(0xFFFB7878);
    notificationErrorBackground = const Color(0xFF3D2A3D);
    notificationNorm = const Color(0xFF9494FF);
    notificationNormBackground = const Color(0xFF131429);

    /// other one-time custom colors styles for widgets
    launchBackground = const Color(0xFFE6E6D8);
    black = const Color(0xFFFFFFFF);
    expansionShadow = const Color(0xFF5B5BA3);
    loadingShadow = const Color(0x229494FF);
    inputDoneOverlay = const Color(0xFFD9DDE1);
    circularProgressIndicatorBackGround =
        const Color.fromARGB(51, 255, 255, 255);

    /// interAction-Norm, used for link, button background
    protonBlue = const Color(0xFF9494FF);

    /// recipient avatar text and background colors
    avatarOrange1Text = const Color(0xFFFF8D52);
    avatarOrange1Background = const Color(0xFF5D4335);
    avatarPink1Text = const Color(0xFFFF68DE);
    avatarPink1Background = const Color(0xFF5E4157);
    avatarPurple1Text = const Color(0xFF9584FE);
    avatarPurple1Background = const Color(0xFF413969);
    avatarBlue1Text = const Color(0xFF536CFF);
    avatarBlue1Background = const Color(0xFF333A62);
    avatarGreen1Text = const Color(0xFF52CC9C);
    avatarGreen1Background = const Color(0xFF1A3C2E);

    /// appbar divider color
    appBarDividerColor = const Color(0xFF31334A);
  }
}

/// Example
// TODO(experimental): this is supported by the flutter theme system. This could simplify the code and make it more readable.
@immutable
class ProtonColorScheme extends ThemeExtension<ProtonColorScheme> {
  final Color test;

  const ProtonColorScheme({
    required this.test,
  });

  @override
  ProtonColorScheme copyWith({
    Color? test,
  }) {
    return ProtonColorScheme(
      test: test ?? this.test,
    );
  }

  @override
  ProtonColorScheme lerp(ThemeExtension<ProtonColorScheme>? other, double t) {
    if (other is! ProtonColorScheme) {
      return this;
    }
    return ProtonColorScheme(
      test: Color.lerp(test, other.test, t)!,
    );
  }
}

final lightSchemeExtension = ProtonColorScheme(
  // link to auto gen color providered by designer
  test: const Color(0xFFF3F5F6),
);

final darkSchemeExtension = ProtonColorScheme(
  test: const Color(0xFF222247),
);
