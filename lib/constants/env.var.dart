import 'package:envied/envied.dart';

part 'env.var.g.dart';

@Envied()
abstract class Env {
  @EnviedField(
    varName: 'RAMP_API_KEY',
    optional: true,
  )
  // ignore: unnecessary_nullable_for_final_variable_declarations
  static const String? rampApiKey = _Env.rampApiKey;
}

// class _Env {
//   static String get rampApiKey => Platform.environment['RAMP_API_KEY'] ?? "";
// }
