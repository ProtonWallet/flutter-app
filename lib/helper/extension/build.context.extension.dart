import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/proton.image.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/local_toast.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/provider/theme.provider.dart';
import 'package:wallet/scenes/components/local.toast.view.dart';

extension BuildContextExtension on BuildContext {
  /// Returns the maximum of the current screen width or a given [value].
  double maxWidth(double value) {
    return max(MediaQuery.of(this).size.width, value);
  }

  /// Returns the current screen height multiplied by a given [value].
  double multHeight(double value) {
    return MediaQuery.of(this).size.height * value;
  }

  /// Gets the current screen width.
  double get width => MediaQuery.of(this).size.width;

  /// Gets the current screen height.
  double get height => MediaQuery.of(this).size.height;

  /// Provides access to the localized strings from the app's localization delegate.
  S get local => S.of(this);

  /// Show snackbar
  void showSnackbar(String message, {bool isError = false}) {
    final snackBar = SnackBar(
      backgroundColor: isError ? ProtonColors.notificationError : null,
      content: Center(
        child: Text(
          message,
          style: ProtonStyles.body2Regular(color: ProtonColors.textInverted),
        ),
      ),
    );
    ScaffoldMessenger.of(this).showSnackBar(snackBar);
  }

  /// quick access to show toast
  void showToast(String message) {
    LocalToast.showToast(this, message);
  }

  void showErrorToast(String message) {
    LocalToast.showToast(
      this,
      message,
      duration: 2,
      toastType: ToastType.error,
    );
  }

  ThemeProvider get themeProvider => Provider.of<ThemeProvider>(this);
  bool get isDarkMode => themeProvider.isDarkMode();

  /// extension for images / icons
  ProtonImages get images {
    return Theme.of(this).extension<ProtonImages>() ??
        // fallover to default
        (isDarkMode ? darkImageExtension : lightImageExtension);
  }
}
