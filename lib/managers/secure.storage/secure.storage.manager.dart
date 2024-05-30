import 'dart:io';

import 'package:wallet/helper/logger.dart';
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
    if (Platform.isWindows) {
      logger.w(
          "Windows not support to deleteAll secure storage, try to delete with cached keys");
      for (String key in keys) {
        await storage.delete(key);
      }
    } else {
      await storage.deleteAll();
    }
  }

  ///
  Future<void> set(String key, String value) async {
    if (Platform.isWindows) {
      // TODO:: figure out why windows can not write to storage, this is current workaround
      for (int i = 0; i < 1000; i++) {
        await storage.write(key, value);
        bool saved = await storage.containsKey(key);
        if (saved == true) {
          break;
        }
      }
      if (keys.contains(key) == false) {
        keys.add(key);
      }
    } else {
      await storage.write(key, value);
    }
  }

  Future<String> get(String key) async {
    return await storage.read(key);
  }

  @override
  Future<void> dispose() async {}

  @override
  Future<void> init() async {}
}
