import 'package:envied/envied.dart';

part 'env.var.g.dart';

@Envied()
abstract class Env {
  @EnviedField(
    varName: 'RAMP_API_KEY',
    optional: true,
  )
  static const String rampApiKey = _Env.rampApiKey;

  @EnviedField(
    varName: 'MOONPAY_API_KEY',
    optional: true,
  )
  static const String moonPayApiKey = _Env.moonPayApiKey;

  @EnviedField(
    varName: 'SENTRY_API_KEY',
    optional: true,
  )
  static const String sentryApiKey = _Env.sentryApiKey;
}

// class _Env {
//   static String get rampApiKey => Platform.environment['RAMP_API_KEY'] ?? "";
// }
