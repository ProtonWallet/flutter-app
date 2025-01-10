import 'package:wallet/rust/api/errors.dart';

class ResponseCode {
  /// create wallet or wallet account reached limitation
  static int reachedCreationLimitation = 2504;

  /// missing locked scope
  static int missingLockedScope = 9101;
}

/// extensions
extension ResponseErrorExtension on ResponseError {
  bool isCreationLimition() {
    return code == ResponseCode.reachedCreationLimitation;
  }

  bool isMissingLockedScope() {
    return code == ResponseCode.missingLockedScope;
  }
}
