import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/provider/theme.provider.dart';

/// this extension will help to override some assets' path in dark mode
extension ThemedAssetGenImage on AssetGenImage {
  AssetGenImage applyThemeIfNeeded(BuildContext context) {
    final isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode();
    if (isDarkMode) {
      switch (keyName) {
        case 'assets/images/icon/bitcoin_big_icon.png':
          return AssetGenImage('assets/images/icon/bitcoin_big_icon_dark.png');
        case 'assets/images/icon/key.png':
          return AssetGenImage('assets/images/icon/key_dark.png');
        case 'assets/images/icon/lock.png':
          return AssetGenImage('assets/images/icon/lock_dark.png');
        case 'assets/images/icon/paper_plane.png':
          return AssetGenImage('assets/images/icon/paper_plane_dark.png');
        case 'assets/images/icon/user.png':
          return AssetGenImage('assets/images/icon/user_dark.png');
        case 'assets/images/icon/early_access.png':
          return AssetGenImage('assets/images/icon/early_access_dark.png');
        case 'assets/images/welcome/wallet_welcome_head.png':
          return AssetGenImage(
              'assets/images/welcome/wallet_welcome_head_dark.png');
      }
    }
    return this;
  }
}
