import 'dart:io';

import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/secure.storage/secure.storage.dart';
import 'package:wallet/managers/secure.storage/secure.storage.interface.dart';

class SecureStorageHelper {
  // storage interface
  final SecureStorageInterface storage;
  // wallet key
  static const String walletKey = "WALLET_KEY";
  // workaround?
  List<String> keys = [];

  // singleton
  static SecureStorageHelper? _instance;

  SecureStorageHelper._({required this.storage});

  static void init(SecureStorageInterface? storage) {
    _instance ??= SecureStorageHelper._(storage: storage ?? SecureStorage());
  }

  static SecureStorageHelper get instance {
    if (_instance == null) {
      throw Exception("SecureStorageHelper not initialized");
    }
    return _instance!;
  }

  Future<void> set(String key, String value) async {
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
  }

  Future<String> get(String key) async {
    return await storage.read(key);
  }

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
}
