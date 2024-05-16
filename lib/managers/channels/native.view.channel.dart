import 'package:flutter/services.dart';
import 'package:wallet/constants/env.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/models/native.session.model.dart';

abstract class NativeViewChannel {
  Future<void> switchToNativeSignup(ApiEnv env);
  Future<void> switchToNativeLogin(ApiEnv env);
  Future<void> restartNative();

  /// Add more methods here
  Future<void> switchToUpgrade(NativeSession session);
}

class NativeViewChannelImpl implements NativeViewChannel {
  final toNativeChannel = const MethodChannel('me.proton.wallet/native.views');
  final fromNativeChannel = const MethodChannel('me.proton.wallet/app.view');

  /// commands
  final String upgrade = "native.navigation.plan.upgrade";

  final envKey = "env-key";

  @override
  Future<void> switchToNativeSignup(ApiEnv env) async {
    try {
      await toNativeChannel
          .invokeMethod('native.navigation.signup', {envKey: env.toString()});
    } on PlatformException catch (e) {
      logger.e("Failed to switch to native view: '${e.message}'.");
    }
  }

  @override
  Future<void> switchToNativeLogin(ApiEnv env) async {
    try {
      await toNativeChannel
          .invokeMethod('native.navigation.login', {envKey: env.toString()});
    } on PlatformException catch (e) {
      logger.e("Failed to switch to native view: '${e.message}'.");
    }
  }

  @override
  Future<void> restartNative() async {
    try {
      await toNativeChannel.invokeMethod('native.navigation.restartApp');
    } on PlatformException catch (e) {
      logger.e("Failed to switch to native view: '${e.message}'.");
    }
  }

  @override
  Future<void> switchToUpgrade(NativeSession session) async {
    const key = "session-key";
    try {
      await toNativeChannel.invokeMethod(upgrade, [key, session.toJson()]);
    } on PlatformException catch (e) {
      logger.e("Failed to switch to native view: '${e.message}'.");
    }
  }
}
