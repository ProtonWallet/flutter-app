// import 'package:mockito/annotations.dart';

// @GenerateMocks([SecureStorageInterface])
abstract class SecureStorageInterface {
  Future<void> write(String key, String value);
  Future<String> read(String key);
  Future<bool> containsKey(String key);
  Future<void> delete(String key);
  Future<void> deleteAll();
}
