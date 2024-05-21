import 'package:wallet/constants/env.dart';
import 'package:wallet/managers/channels/platform.channel.state.dart';
import 'package:wallet/models/native.session.model.dart';

abstract class NativeViewChannel {
  Future<void> switchToNativeSignup(ApiEnv env);
  Future<void> switchToNativeLogin(ApiEnv env);
  Future<void> restartNative();
  Future<void> initalNativeApiEnv(ApiEnv env);

  /// Add more methods here
  Future<void> switchToUpgrade(FlutterSession session);

  Stream<NativeLoginState> get stream;
}
