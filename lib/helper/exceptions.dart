import 'package:flutter/widgets.dart';
import 'package:wallet/helper/extension/response.error.extension.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/rust/api/errors.dart';

extension BridgeErrorExt on BridgeError {
  /// this will be used after refactor how handle context
  String getLocalizedMessage(BuildContext context) {
    /// A shorthand for localization access if needed
    final s = S.of(context);

    /// `map` will call the function for the specific subtype of `BridgeError`
    ///    map will show error if new type added but didnt handle
    return map(
      apiLock: (e) => s.bridge_error_api_lock,
      generic: (e) => s.bridge_error_generic,
      muonAuthSession: (e) => s.session_expired_content,
      muonAuthRefresh: (e) => s.session_expired_content,
      muonClient: (e) => s.bridge_error_muon_client,
      muonSession: (e) => s.bridge_error_muon_client,
      andromedaBitcoin: (e) => s.bridge_error_bitcoin,
      apiResponse: (e) => e.field0.error,
      apiSrp: (e) => s.bridge_error_api_srp,
      aesGcm: (e) => s.bridge_error_aes_gcm,
      walletCrypto: (e) => s.bridge_error_wallet_crypto,
      walletDecryption: (e) => s.bridge_error_wallet_decryption,
      walletFeature: (e) => s.bridge_error_wallet_feature,
      login: (e) => s.bridge_error_login,
      fork: (e) => s.bridge_error_fork,
      database: (e) => s.bridge_error_database,
      sessionStore: (e) => s.bridge_error_session_store,
      apiDeserialize: (e) => s.bridge_error_api_deserialize,
      bitcoinDeserialize: (e) => s.bridge_error_bitcoin_deserialize,
      encoding: (e) => s.bridge_error_encoding,
      insufficientFundsInPaperWallet: (e) => s.bridge_error_insufficient_funds_in_paper_wallet,
      invalidPaperWallet: (e) => s.bridge_error_invalid_paper_wallet,
    );
  }

  String get localizedString {
    /// `map` will call the function for the specific subtype of `BridgeError`
    ///    map will show error if new type added but didnt handle
    return map(
      apiLock: (e) {
        return "Failed to initialize the Proton API. Please relaunch the app.";
      },
      generic: (e) {
        return "An unexpected error occurred. Please try again.";
      },
      muonAuthSession: (e) {
        return "Your session has expired. Please log in to continue.";
      },
      muonAuthRefresh: (e) {
        return "Your session has expired. Please log in to continue.";
      },
      muonClient: (e) {
        // Possibly a more specific message, or just a fallback for network issues
        return "A network error occurred in Muon. Please try again.";
      },
      muonSession: (e) {
        return "A Muon session error occurred. Please try again.";
      },
      andromedaBitcoin: (e) {
        return "A Bitcoin wallet error occurred. Please try again.";
      },
      apiResponse: (e) {
        return e.field0.error;
      },
      apiSrp: (e) {
        return "An SRP hashing error occurred. Please try again.";
      },
      aesGcm: (e) {
        return "A cryptographic (AES-GCM) error occurred. Please try again.";
      },
      walletCrypto: (e) {
        return "A wallet cryptography error occurred. Please try again.";
      },
      walletDecryption: (e) {
        return "Failed to decrypt wallet. Please try again.";
      },
      walletFeature: (e) {
        return "A wallet feature operation failed. Please try again.";
      },
      login: (e) {
        return "Login failed. Please check your credentials and try again.";
      },
      fork: (e) {
        return "Failed to fork the session. Please try again.";
      },
      database: (e) {
        return "Failed to access the local cache. Please try again.";
      },
      sessionStore: (e) {
        return "Failed to access the session store. Please try again.";
      },
      apiDeserialize: (e) {
        return "Failed to parse the server response. Please try again.";
      },
      bitcoinDeserialize: (e) {
        return "Failed to parse the Bitcoin server response. Please try again.";
      },
      encoding: (e) {
        return "String encoding error. Please try again.";
      },
      insufficientFundsInPaperWallet: (e) {
        return "This paper has insufficient funds. Please try another one.";
      },
      invalidPaperWallet: (e) {
        return "Invalid private key. Please try again.";
      },
    );
  }
}

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
    walletDecryption: (e) => e.field0,
    walletFeature: (e) => e.field0,
    login: (e) => e.field0,
    fork: (e) => e.field0,
    database: (e) => e.field0,
    apiDeserialize: (e) => e.field0,
    bitcoinDeserialize: (e) => e.field0,
    sessionStore: (e) => e.field0,
    encoding: (e) => e.field0,
    insufficientFundsInPaperWallet: (e) => e.field0,
    invalidPaperWallet: (e) => e.field0,
  );
}

bool ifMuonClientError(BridgeError exception) {
  return exception.maybeMap(
    muonClient: (e) => true,
    orElse: () => false,
  );
}

String? parseAppCryptoError(BridgeError exception) {
  return exception.maybeMap(
    walletDecryption: (e) => e.field0,
    orElse: () => null,
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
  final responseError = parseResponseError(exception);
  if (responseError != null && responseError.isCreationLimition()) {
    return responseError.error;
  }
  return null;
}
