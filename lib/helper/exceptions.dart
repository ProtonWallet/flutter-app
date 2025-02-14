import 'package:wallet/helper/extension/response.error.extension.dart';
import 'package:wallet/rust/api/errors.dart';

ResponseError? parseResponseError(BridgeError exception) {
  return exception.maybeMap(
    apiResponse: (e) => e.field0,
    orElse: () => null,
  );
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
    walletFeature: (e) => e.field0,
    login: (e) => e.field0,
    fork: (e) => e.field0,
    database: (e) => e.field0,
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

String? parseMuonError(BridgeError exception) {
  return exception.maybeMap(
    muonClient: (e) => "Connection error. Please try again.",
    orElse: () => null,
  );
}

String? parseUserLimitationError(BridgeError exception) {
  final responseError = parseResponseError(exception);
  if (responseError != null && responseError.isCreationLimition()) {
    return responseError.error;
  }
  return null;
}
