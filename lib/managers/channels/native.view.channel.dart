import 'package:wallet/constants/env.dart';
import 'package:wallet/managers/channels/platform.channel.state.dart';
import 'package:wallet/models/native.session.model.dart';

abstract class NativeViewChannel {
  Future<void> switchToNativeSignup();
  Future<void> switchToNativeLogin();
  Future<void> restartNative();
  Future<void> initalNativeApiEnv(ApiEnv env);

  /// Add more methods here
  Future<void> switchToUpgrade(FlutterSession session);

  /// logout
  Future<void> nativeLogout();

  /// reports
  Future<void> nativeReportBugs();

  // event stream for native response
  Stream<NativeLoginState> get stream;
}
