import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/l10n/generated/locale.dart';

class ThemeProvider extends ChangeNotifier {
  final String key = 'theme'; // preference key
  // maping 3 theme types
  Map themeModeList = <String, ThemeMode>{
    'dark': ThemeMode.dark, // dark
    'light': ThemeMode.light, // light
    'system': ThemeMode.system // follow system
  };

  SharedPreferences? _preferences;
  String _themeMode = "light";

  // return current mode
  String get themeMode => _themeMode;

  // constructure
  ThemeProvider() {
    _loadFromPreferences(); // read
  }

  static String getThemeModeName(String mode, context) {
    switch (mode) {
      case 'dark':
        return S.of(context).dark_mode;
      case 'light':
        return S.of(context).light_mode;
      default:
        return S.of(context).light_mode;
    }
  }

  ThemeMode getThemeMode(String mode) {
    return themeModeList[mode];
  }

  //
  ThemeData getThemeData({bool isDark = false}) {
    return ThemeData(brightness: isDark ? Brightness.dark : Brightness.light);
  }

  // init SharedPreferences
  Future<void> _initialPreferences() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  //  save
  Future<void> _savePreferences() async {
    await _initialPreferences();
    _preferences?.setString(key, _themeMode);
  }

  // read
  Future<void> _loadFromPreferences() async {
    await _initialPreferences();
    _themeMode = _preferences?.getString(key) ?? 'light';
    if (_themeMode == "light") {
      ProtonColors.updateLightTheme();
    } else {
      ProtonColors.updateDarkTheme();
    }
    notifyListeners(); // notify
  }

  void toggleChangeTheme(val) {
    _themeMode = val;
    logger.d('current theme mode: $_themeMode');
    if (_themeMode == "light") {
      ProtonColors.updateLightTheme();
    } else {
      ProtonColors.updateDarkTheme();
    }
    _savePreferences();
    notifyListeners(); // notify
  }
}
