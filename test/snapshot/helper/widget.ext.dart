import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:provider/provider.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/provider/theme.provider.dart';

@isTest
extension WidgetExtension on Widget {
  Widget withTheme(ThemeProvider mockThemeProvider) {
    final testwidget = ChangeNotifierProvider<ThemeProvider>.value(
      value: mockThemeProvider,
      child: this,
    );
    return testwidget;
  }

  Widget get withBgSecondary {
    return ColoredBox(
      color: ProtonColors.backgroundSecondary,
      child: this,
    );
  }

  Widget get withBgNormal {
    return ColoredBox(
      color: ProtonColors.backgroundNorm,
      child: this,
    );
  }
}
