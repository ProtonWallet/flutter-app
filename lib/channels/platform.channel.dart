import 'package:flutter/services.dart';
import 'package:wallet/constants/env.dart';
import 'package:wallet/helper/logger.dart';

class NativeViewSwitcher {
  static const platform = MethodChannel('com.example.wallet/native.views');
  static const _envKey = "env-key";

  static Future<void> switchToNativeSignup(ApiEnv env) async {
    try {
      await platform
          .invokeMethod('native.navigation.signup', {_envKey: env.toString()});
    } on PlatformException catch (e) {
      logger.e("Failed to switch to native view: '${e.message}'.");
    }
  }

  static Future<void> switchToNativeLogin(ApiEnv env) async {
    try {
      await platform
          .invokeMethod('native.navigation.login', {_envKey: env.toString()});
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
