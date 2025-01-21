import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/constants/env.dart';
import 'package:wallet/helper/extension/platform.extension.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/channels/native.view.channel.dart';
import 'package:wallet/managers/channels/platform.channel.event.dart';
import 'package:wallet/managers/manager.dart';
import 'package:wallet/models/native.session.model.dart';

import 'platform.channel.state.dart';

class PlatformChannelManager extends Bloc<ChannelEvent, NativeLoginState>
    implements NativeViewChannel, Manager {
  final toNativeChannel = const MethodChannel('me.proton.wallet/native.views');
  final fromNativeChannel = const MethodChannel('me.proton.wallet/app.view');

// The api environment
  final ApiEnv env;

  PlatformChannelManager(this.env) : super(NativeLoginInitial()) {
    on<DirectEmitEvent>((event, emit) => emit(event.newState));
  }

  @override
  Future<void> init() async {
    fromNativeChannel.setMethodCallHandler(_handleMethodCall);
  }

  @override
  Future<void> dispose() async {}

  /// Commands
  @override
  Future<void> switchToNativeSignup() async {
    if (desktop) {
      return logger.i("switchToNativeSignup is mobile only feature");
    }
    try {
      await toNativeChannel.invokeMethod('native.navigation.signup');
    } on Exception catch (e) {
      logger.e("Failed to switch to native signup view: '$e'.");
    }
  }

  @override
  Future<void> switchToNativeLogin() async {
    if (desktop) {
      return logger.i("switchToNativeLogin is mobile only feature");
    }
    try {
      await toNativeChannel.invokeMethod('native.navigation.login');
    } on Exception catch (e) {
      logger.e("Failed to switch to native login view: '$e'.");
    }
  }

  @override
  Future<void> restartNative() async {
    if (desktop) {
      return logger.i("restartNative is mobile only feature");
    }
    try {
      await toNativeChannel.invokeMethod('native.navigation.restartApp');
    } on Exception catch (e) {
      logger.e("Failed to restart native: '$e'.");
    }
  }

  @override
  Future<void> switchToUpgrade(FlutterSession session) async {
    if (desktop) {
      return logger.i("switchToUpgrade is mobile only feature");
    }
    const key = "session-key";
    const String upgrade = "native.navigation.plan.upgrade";
    try {
      await toNativeChannel.invokeMethod(upgrade, [key, session.toJson()]);
    } on Exception catch (e) {
      logger.e("Failed to switch to upgrade view: '$e'.");
    }
  }

  @override
  Future<void> initalNativeApiEnv(
    ApiEnv env,
    String appVersion,
    String userAgent,
  ) async {
    if (desktop) {
      return logger.i("initalNativeApiEnv is mobile only feature");
    }
    const envKey = "env-key";
    const appVersionKey = "app-version";
    const userAgentKey = "user-agent";
    try {
      final strEnv = env.toString();
      await toNativeChannel.invokeMethod('native.initialize.core.environment', {
        envKey: strEnv,
        appVersionKey: appVersion,
        userAgentKey: userAgent,
      });
    } on Exception catch (e) {
      logger.e("Failed to initialize native environment: '$e'.");
    }
  }

  @override
  Future<void> nativeLogout() async {
    if (desktop) {
      return logger.i("initalNativeApiEnv is mobile only feature");
    }
    try {
      await toNativeChannel.invokeMethod('native.account.logout');
    } on Exception catch (e) {
      logger.e("Failed to native logout: '$e'.");
    }
  }

  @override
  Future<void> nativeReportBugs(String userName, String email) async {
    if (desktop) {
      return logger.i("initalNativeApiEnv is mobile only feature");
    }
    try {
      await toNativeChannel.invokeMethod('native.navigation.report', {
        "username": userName,
        "email": email,
      });
    } on Exception catch (e) {
      logger.e("Failed to native report bugs: '$e'.");
    }
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'flutter.navigation.to.home':
        final String data = call.arguments;
        final Map<String, dynamic> map = json.decode(data);
        final UserInfo userInfo = UserInfo.fromJson(map);
        logger.d("Data received from Native: ${userInfo.userId}");

        directEmitExample(NativeLoginSuccess(userInfo));
    }
  }

  void directEmitExample(NativeLoginSuccess newState) {
    add(DirectEmitEvent(newState));
  }

  @override
  Future<void> logout() async {}

  @override
  Future<void> login(String userID) async {}

  @override
  Future<void> reload() async {}

  @override
  Priority getPriority() {
    return Priority.level1;
  }
}
