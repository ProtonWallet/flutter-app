import 'package:envied/envied.dart';

part 'env.var.g.dart';

@Envied()
abstract class Env {
  @EnviedField(
    varName: 'SENTRY_API_KEY',
    optional: true,
  )
  static const String sentryApiKey = _Env.sentryApiKey;
}
