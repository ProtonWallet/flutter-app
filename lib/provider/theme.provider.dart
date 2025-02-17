import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/logger.dart';

class ThemeProvider extends ChangeNotifier {
  final String key = 'theme'; // preference key
  // maping 3 theme types
  Map themeModeList = <String, ThemeMode>{
    'dark': ThemeMode.dark, // dark
    'light': ThemeMode.light, // light
    'system': ThemeMode.system // follow system
  };

  SharedPreferences? _preferences;
  String _themeMode = "system";

  // return current mode
  String get themeMode => _themeMode;

  // constructure
  ThemeProvider();

  ThemeMode getThemeMode(String mode) {
    return themeModeList[mode];
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
  Future<void> loadFromPreferences() async {
    await _initialPreferences();
    _themeMode = _preferences?.getString(key) ?? 'system';
    if (isDarkMode()) {
      ProtonColors.updateDarkTheme();
    } else {
      ProtonColors.updateLightTheme();
    }
    notifyListeners(); // notify
  }

  void toggleChangeTheme(val) {
    _themeMode = val;
    logger.d('current theme mode: $_themeMode');
    if (isDarkMode()) {
      ProtonColors.updateDarkTheme();
    } else {
      ProtonColors.updateLightTheme();
    }
    _savePreferences();
    notifyListeners(); // notify
  }

  bool isDarkMode() {
    final ThemeMode theme = getThemeMode(_themeMode);
    if (theme == ThemeMode.system) {
      final brightness =
          SchedulerBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
    }
    return theme == ThemeMode.dark;
  }
}
