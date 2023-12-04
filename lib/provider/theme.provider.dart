import 'package:flutter/material.dart';
import 'package:wallet/helper/logger.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:deep_sky_app/generated/l10n.dart';

// ：https://omadijaya.id/flutter-dynamic-dark-mode-with-provider-and-shared-preferences/

class ThemeProvider extends ChangeNotifier {
  final String key = 'theme'; // preference key
  // maping 3 theme types
  Map themeModeList = <String, ThemeMode>{
    'dark': ThemeMode.dark, // dark
    'light': ThemeMode.light, // light
    'system': ThemeMode.system // follow system
  };

  // SharedPreferences _preferences;
  String _themeMode = "system";

  // return current mode
  String get themeMode => _themeMode;

  // constructure
  ThemeProvider() {
    _loadFromPreferences(); // read
  }

  static String getThemeModeName(String mode, context) {
    switch (mode) {
      case 'dark':
        return "dark"; //S.of(context).darkMode;
      case 'light':
        return "light"; // S.of(context).lightMode;
      default:
        return "system"; // S.of(context).autoBySystem;
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
  _initialPreferences() async {
    // if (_preferences == null)
    // _preferences = await SharedPreferences.getInstance();
  }

  //  save
  _savePreferences() async {
    await _initialPreferences();
    // _preferences.setString(key, _themeMode);
  }

  // read
  _loadFromPreferences() async {
    await _initialPreferences();
    // _themeMode = _preferences.getString(key) ?? 'system';
    notifyListeners(); // notify
  }

  toggleChangeTheme(val) {
    _themeMode = val;
    logger.d('current theme mode: $_themeMode');
    _savePreferences();
    notifyListeners(); // notify
  }
}
