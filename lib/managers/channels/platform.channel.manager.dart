import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/constants/env.dart';
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

  PlatformChannelManager() : super(NativeLoginInitial()) {
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
  Future<void> switchToNativeSignup(ApiEnv env) async {
    const envKey = "env-key";
    try {
      await toNativeChannel
          .invokeMethod('native.navigation.signup', {envKey: env.toString()});
    } on PlatformException catch (e) {
      logger.e("Failed to switch to native view: '${e.message}'.");
    }
  }

  @override
  Future<void> switchToNativeLogin(ApiEnv env) async {
    const envKey = "env-key";
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
  Future<void> switchToUpgrade(FlutterSession session) async {
    const key = "session-key";
    const String upgrade = "native.navigation.plan.upgrade";
    try {
      await toNativeChannel.invokeMethod(upgrade, [key, session.toJson()]);
    } on PlatformException catch (e) {
      logger.e("Failed to switch to native view: '${e.message}'.");
    }
  }

  @override
  Future<void> initalNativeApiEnv(ApiEnv env) async {
    const envKey = "env-key";
    try {
      await toNativeChannel.invokeMethod(
          'native.initialize.core.environment', {envKey: env.toString()});
    } on PlatformException catch (e) {
      logger.e("Failed to initialize native environment: '${e.message}'.");
    } on MissingPluginException catch (e){
      logger.e("Failed to initialize native environment: '${e.message}'.");
    }
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'flutter.navigation.to.home':
        String data = call.arguments;
        logger.d("Data received from Swift: $data");
        Map<String, dynamic> map = json.decode(data);
        UserInfo userInfo = UserInfo.fromJson(map);

        directEmitExample(NativeLoginSucess(userInfo));
    }
  }

  void directEmitExample(NativeLoginSucess newState) {
    add(DirectEmitEvent(newState));
  }
}
