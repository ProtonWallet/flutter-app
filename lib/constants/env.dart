enum ApiEnvType {
  prod,
  atlas,
}

class ApiEnv {
  final ApiEnvType type;
  final String? custom; // Only used for the atlas type

  const ApiEnv.prod()
      : type = ApiEnvType.prod,
        custom = null;
  ApiEnv.atlas(this.custom) : type = ApiEnvType.atlas;

  @override
  String toString() {
    switch (type) {
      case ApiEnvType.prod:
        return "prod";
      case ApiEnvType.atlas:
        return "atlas${custom != null ? ':$custom' : ''}";
    }
  }

  String get apiPath {
    switch (type) {
      case ApiEnvType.prod:
        return "https://wallet.proton.me/api";
      case ApiEnvType.atlas:
        return "https://${custom != null ? '$custom' : ''}.proton.black/api";
    }
  }
}

final jenner = ApiEnv.atlas("jenner");
final eccles = ApiEnv.atlas("eccles");
final pascal = ApiEnv.atlas("pascal");
final payments = ApiEnv.atlas("payments");
