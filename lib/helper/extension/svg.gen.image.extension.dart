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
        case 'assets/images/icon/wallet_0.svg':
          return SvgGenImage('assets/images/icon/wallet_0_dark.svg');
        case 'assets/images/icon/wallet_1.svg':
          return SvgGenImage('assets/images/icon/wallet_1_dark.svg');
        case 'assets/images/icon/wallet_2.svg':
          return SvgGenImage('assets/images/icon/wallet_2_dark.svg');
        case 'assets/images/icon/wallet_3.svg':
          return SvgGenImage('assets/images/icon/wallet_3_dark.svg');
        case 'assets/images/icon/wallet_4.svg':
          return SvgGenImage('assets/images/icon/wallet_4_dark.svg');
        case 'assets/images/icon/wallet_account_0.svg':
          return SvgGenImage('assets/images/icon/wallet_account_0_dark.svg');
        case 'assets/images/icon/wallet_account_1.svg':
          return SvgGenImage('assets/images/icon/wallet_account_1_dark.svg');
        case 'assets/images/icon/wallet_account_2.svg':
          return SvgGenImage('assets/images/icon/wallet_account_2_dark.svg');
        case 'assets/images/icon/wallet_account_3.svg':
          return SvgGenImage('assets/images/icon/wallet_account_3_dark.svg');
        case 'assets/images/icon/wallet_account_4.svg':
          return SvgGenImage('assets/images/icon/wallet_account_4_dark.svg');
      }
    }
    return this;
  }
}
