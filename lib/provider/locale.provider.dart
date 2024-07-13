import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/l10n/generated/locale.dart';

class LocaleProvider extends ChangeNotifier {
  final String key = 'locale'; // preference key

  SharedPreferences? _preferences;

  String _language = ""; // current language

  String get language => _language;

  Locale? get locale {
    if (_language != '') {
      return Locale(_language);
    }
    return null;
  }

  // return the language native words
  static String localeName(String lang, context) {
    switch (lang) {
      case 'en':
        return 'English';
      case 'zh':
      case 'zh_CN':
        return '简体中文';
      case '':
      default:
        return S.of(context).auto_by_system;
    }
  }

  LocaleProvider() {
    _loadFromPreferences();
  }

  // init SharedPreferences
  Future<void> _initialPreferences() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  // save
  Future<void> _savePreferences() async {
    await _initialPreferences();
    _preferences?.setString(key, _language);
  }

  // read
  Future<void> _loadFromPreferences() async {
    await _initialPreferences();
    _language = _preferences?.getString(key) ?? '';
    notifyListeners(); //
  }

  void toggleChangeLocale(String language) {
    _language = language;
    logger.d('current locale: $language');
    _savePreferences();
    notifyListeners();
  }
}
