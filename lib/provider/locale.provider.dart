import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/l10n/generated/locale.dart';

class LocaleProvider extends ChangeNotifier {
  static const String systemDefault = 'system_default'; // system default name
  final String key = 'locale'; // preference key

  SharedPreferences? _preferences;

  String _language = systemDefault; // current language

  String get language => _language;

  Locale? get locale {
    if (_language != '') {
      if (_language == 'zh-TW') {
        return Locale("zh", "TW");
      }
      if (_language == 'zh-CN') {
        return Locale("zh", "CN");
      }
      if (_language == 'es-419') {
        return Locale("es", "419");
      }
      return Locale(_language);
    }
    return null;
  }

  /// return the language native words by given bcp47 code
  static String localeName(String bcp47, context) {
    switch (bcp47) {
      case 'de':
        return 'Deutsch';
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'es-419':
        return 'Español (Latinoamérica)';
      case 'fr':
        return 'Français';
      case 'it':
        return 'Italiano';
      case 'nl':
        return 'Nederlands';
      case 'pl':
        return 'Polski';
      case 'pt':
        return 'Português';
      case 'ru':
        return 'Русский';
      case 'tr':
        return 'Türkçe';
      case 'zh-CN':
        return '简体中文';
      case 'zh-TW':
        return '繁體中文';
      default:
        return S.of(context).system_default_mode;
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
    _language = _preferences?.getString(key) ?? systemDefault;
    notifyListeners(); //
  }

  void toggleChangeLocale(String language) {
    _language = language;
    logger.d('current locale: $language');
    _savePreferences();
    notifyListeners();
  }
}
