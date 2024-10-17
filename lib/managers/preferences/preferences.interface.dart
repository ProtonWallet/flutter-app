abstract class PreferencesInterface {
  Future<void> write(String key, dynamic value);
  Future<dynamic> read(String key);
  Future<void> delete(String key);
  Future<void> deleteAll();
  Map<dynamic, dynamic> toMap();
}