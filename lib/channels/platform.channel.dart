import 'package:flutter/services.dart';
import 'package:wallet/helper/logger.dart';

class NativeViewSwitcher {
  static const platform = MethodChannel('com.example.wallet/native.views');

  static Future<void> switchToNativeSignup() async {
    try {
      await platform.invokeMethod('native.navigation.signup');
    } on PlatformException catch (e) {
      logger.e("Failed to switch to native view: '${e.message}'.");
    }
  }

  static Future<void> switchToNativeLogin() async {
    try {
      await platform.invokeMethod('native.navigation.login');
    } on PlatformException catch (e) {
      logger.e("Failed to switch to native view: '${e.message}'.");
    }
  }

  static Future<void> restartNative() async {
    try {
      await platform.invokeMethod('native.navigation.restartApp');
    } on PlatformException catch (e) {
      logger.e("Failed to switch to native view: '${e.message}'.");
    }
  }
}
