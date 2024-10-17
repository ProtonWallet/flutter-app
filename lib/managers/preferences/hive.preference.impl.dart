import 'package:hive/hive.dart';

import 'preferences.interface.dart';

class HivePreferenceImpl implements PreferencesInterface {
  late Box storage;

  HivePreferenceImpl();

  Future<void> init() async {
    storage = await Hive.openBox("protono_wallet_shared_preference");
  }

  @override
  Map<dynamic, dynamic> toMap() {
    return storage.toMap();
  }

  @override
  Future<void> delete(String key) async {
    await storage.delete(key);
  }

  @override
  Future<void> deleteAll() async {
    await storage.clear();
  }

  @override
  Future read(String key) async {
    return await storage.get(key);
  }

  @override
  Future<void> write(String key, value) async {
    await storage.put(key, value);
  }
}
