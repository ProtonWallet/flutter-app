import 'package:wallet/rust/common/errors.dart';

ResponseError? parseResponseError(BridgeError exception) {
  return exception.maybeMap(
    apiResponse: (e) => e.field0,
    orElse: () => null,
  );
}

/// extensions
extension ResponseErrorCheck on ResponseError {
  bool isMissingLockedScope() {
    return code == 9101;
  }
}

String parseSampleDisplayError(BridgeError exception) {
  return exception.map(
    apiLock: (e) => e.field0,
    generic: (e) => e.field0,
    muonAuthSession: (e) => e.field0,
    muonAuthRefresh: (e) => e.field0,
    muonClient: (e) => e.field0,
    muonSession: (e) => e.field0,
    andromedaBitcoin: (e) => e.field0,
    apiResponse: (e) => e.field0.error,
    apiSrp: (e) => e.field0,
    aesGcm: (e) => e.field0,
    walletCrypto: (e) => e.field0,
    login: (e) => e.field0,
    fork: (e) => e.field0,
  );
}

bool ifMuonClientError(BridgeError exception) {
  return exception.maybeMap(
    muonClient: (e) => true,
    orElse: () => false,
  );
}

String? parseSessionExpireError(BridgeError exception) {
  return exception.maybeMap(
    muonAuthSession: (e) => e.field0,
    muonAuthRefresh: (e) => e.field0,
    orElse: () => null,
  );
}

String? parseUserLimitationError(BridgeError exception) {
  final error = exception.maybeMap(
    apiResponse: (e) => e.field0,
    orElse: () => null,
  );
  if (error != null) {
    if (error.error.toLowerCase() ==
        "You have reached the creation limit for this type of wallet account"
            .toLowerCase()) {
      return error.error;
    }
  }
  return null;
}
