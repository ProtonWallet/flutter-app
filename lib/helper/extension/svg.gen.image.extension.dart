import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/provider/theme.provider.dart';

/// this extension will help to override some assets' path in dark mode
extension ThemedAssetGenImage on SvgGenImage {
  SvgGenImage applyThemeIfNeeded(BuildContext context) {
    final isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode();
    if (isDarkMode) {
      switch (keyName) {
        case 'assets/images/icon/delete_warning.svg':
          return SvgGenImage('assets/images/icon/delete_warning-dark.svg');
        case 'assets/images/icon/receive.svg':
          return SvgGenImage('assets/images/icon/receive-dark.svg');
        case 'assets/images/icon/send.svg':
          return SvgGenImage('assets/images/icon/send-dark.svg');
        case 'assets/images/icon/wallet-0.svg':
          return SvgGenImage('assets/images/icon/wallet-0-dark.svg');
        case 'assets/images/icon/wallet-1.svg':
          return SvgGenImage('assets/images/icon/wallet-1-dark.svg');
        case 'assets/images/icon/wallet-2.svg':
          return SvgGenImage('assets/images/icon/wallet-2-dark.svg');
        case 'assets/images/icon/wallet-3.svg':
          return SvgGenImage('assets/images/icon/wallet-3-dark.svg');
        case 'assets/images/icon/wallet-4.svg':
          return SvgGenImage('assets/images/icon/wallet-4-dark.svg');
        case 'assets/images/icon/wallet-account-0.svg':
          return SvgGenImage('assets/images/icon/wallet-account-0-dark.svg');
        case 'assets/images/icon/wallet-account-1.svg':
          return SvgGenImage('assets/images/icon/wallet-account-1-dark.svg');
        case 'assets/images/icon/wallet-account-2.svg':
          return SvgGenImage('assets/images/icon/wallet-account-2-dark.svg');
        case 'assets/images/icon/wallet-account-3.svg':
          return SvgGenImage('assets/images/icon/wallet-account-3-dark.svg');
        case 'assets/images/icon/search.svg':
          return SvgGenImage('assets/images/icon/search-dark.svg');
        case 'assets/images/icon/setup-preference.svg':
          return SvgGenImage('assets/images/icon/setup-preference-dark.svg');
        case 'assets/images/icon/wallet_edit.svg':
          return SvgGenImage('assets/images/icon/wallet_edit_dark.svg');
        case 'assets/images/icon/drawer_menu.svg':
          return SvgGenImage('assets/images/icon/drawer_menu_dark.svg');
        case 'assets/images/wallet_creation/proton_wallet_logo_light.svg':
          return SvgGenImage(
              'assets/images/wallet_creation/proton_wallet_logo_dark.svg');
      }
    }
    return this;
  }
}
