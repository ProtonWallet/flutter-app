import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/secure.storage/secure.storage.interface.dart';
import 'package:wallet/managers/secure.storage/secure.storage.dart';

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

  static Future<void> init(SecureStorageInterface? storage) async {
    if (storage != null) {
      _instance ??= SecureStorageHelper._(storage: storage);
    } else {
      _instance ??= SecureStorageHelper._(storage: SecureStorage());
      // clear all data if first run
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool('firstTimeEntry') ?? true) {
        await _instance?.deleteAll();
        prefs.setBool('firstTimeEntry', false);
      }
    }
  }

  static SecureStorageHelper get instance {
    if (_instance == null) {
      throw Exception("SecureStorageHelper not initialized");
    }
    return _instance!;
  }

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
