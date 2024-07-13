import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'secure.storage.interface.dart';

class SecureStorage implements SecureStorageInterface {
  late FlutterSecureStorage storage;

  bool isPlatformSupported() {
    return true;
  }

  SecureStorage() {
    if (!isPlatformSupported()) {
      return;
    }
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

  AndroidOptions getAndroidOptions() => const AndroidOptions(
        encryptedSharedPreferences: true,
      );

  IOSOptions getIOSOptions() => const IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
        groupId: 'group.me.proton.wallet',
      );

  MacOsOptions getMacOsOptions() => const MacOsOptions();

  WindowsOptions getWindowsOptions() => const WindowsOptions();

  @override
  Future<void> write(String key, String value) async {
    await storage.write(key: key, value: value);
  }

  @override
  Future<String> read(String key) async {
    return await storage.read(key: key) ?? "";
  }

  @override
  Future<bool> containsKey(String key) async {
    return storage.containsKey(key: key);
  }

  @override
  Future<void> delete(String key) async {
    await storage.delete(key: key);
  }

  @override
  Future<void> deleteAll() async {
    await storage.deleteAll();
  }
}
