import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wallet/helper/logger.dart';

class SecureStorageHelper {
  static const String walletKey = "WALLET_KEY";
  static FlutterSecureStorage? storage;
  static bool _initialized = false;
  static List<String> keys = [];

  static AndroidOptions getAndroidOptions() => const AndroidOptions(
        encryptedSharedPreferences: true,
      );

  static IOSOptions getIOSOptions() => const IOSOptions();

  static MacOsOptions getMacOsOptions() => const MacOsOptions();

  static WindowsOptions getWindowsOptions() => const WindowsOptions();

  static bool isPlatformSupported() {
    return true;
  }

  static void init() {
    if (!isPlatformSupported()) {
      return;
    }
    if (!_initialized) {
      _initialized = true;
      if (Platform.isAndroid) {
        storage = FlutterSecureStorage(aOptions: getAndroidOptions());
      } else if (Platform.isIOS) {
        storage = FlutterSecureStorage(iOptions: getIOSOptions());
      } else if (Platform.isMacOS) {
        storage = FlutterSecureStorage(mOptions: getMacOsOptions());
      } else if (Platform.isWindows) {
        storage = FlutterSecureStorage(wOptions: getWindowsOptions());
      } else {
        storage = const FlutterSecureStorage();
      }
    }
  }

  static Future<void> set(String key_, String value_) async {
    // TODO:: figure out why windows can not write to storage, this is current workaround
    for (int i = 0; i< 1000; i++) {
      await storage!.write(key: key_, value: value_);
      bool saved = await storage!.containsKey(key: key_);
      if (saved == true){
        break;
      }
    }
    if (keys.contains(key_) == false) {
      keys.add(key_);
    }
  }

  static Future<String> get(String key_) async {
    return await storage!.read(key: key_) ?? "";
  }

  static Future<void> deleteAll() async {
    if (Platform.isWindows) {
      logger.w("Windows not support to deleteAll secure storage, try to delete with cached keys");
      for (String key in keys){
        await storage!.delete(key: key);
      }
      return;
    }
    await storage!.deleteAll();
  }
}
