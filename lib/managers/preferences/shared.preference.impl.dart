import 'package:shared_preferences/shared_preferences.dart';

import 'preferences.interface.dart';

class SharedPreferenceImpl implements PreferencesInterface {
  final SharedPreferences storage;

  SharedPreferenceImpl(this.storage);

  @override
  Future<void> delete(String key) async {
    await storage.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    await storage.clear();
  }

  @override
  Future read(String key) async {
    storage.get(key);
  }

  @override
  Future<void> write(String key, value) async {
    if (value is String) {
      storage.setString(key, value);
    }
    if (value is int) {
      storage.setInt(key, value);
    }
    if (value is double) {
      storage.setDouble(key, value);
    }
    if (value is bool) {
      storage.setBool(key, value);
    }
    if (value is List<String>) {
      storage.setStringList(key, value);
    }
  }

  @override
  Map toMap() {
    return {};
  }
}
