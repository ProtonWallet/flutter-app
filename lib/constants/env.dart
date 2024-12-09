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
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ApiEnv && other.type == type && other.custom == custom;
  }

  @override
  int get hashCode => Object.hash(type, custom);

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

final payments = ApiEnv.atlas("payments");
