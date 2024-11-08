import 'dart:io';

import 'package:wallet/managers/manager.dart';
import 'package:wallet/managers/secure.storage/secure.storage.interface.dart';

class SecureStorageManager implements Manager {
  // storage interface
  final SecureStorageInterface storage;

  // workaround?
  List<String> keys = [];

  SecureStorageManager({required this.storage});

  /// function
  Future<void> deleteAll() async {
    await storage.deleteAll();
  }

  ///
  Future<void> set(String key, String value) async {
    if (Platform.isWindows) {
      // TODO(fix): figure out why windows can not write to storage, this is current workaround
      for (int i = 0; i < 1000; i++) {
        await storage.write(key, value);
        final bool saved = await storage.containsKey(key);
        if (saved) {
          break;
        }
      }
      if (!keys.contains(key)) {
        keys.add(key);
      }
    } else {
      await storage.write(key, value);
    }
  }

  Future<String> get(String key) async {
    return storage.read(key);
  }

  @override
  Future<void> dispose() async {}

  @override
  Future<void> init() async {}

  @override
  Future<void> logout() async {
    await deleteAll();
  }

  @override
  Future<void> login(String userID) async {}
  @override
  Future<void> reload() async {}
}
