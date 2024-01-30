import 'package:wallet/rust/proton_api/errors.dart' as bridge;

abstract class ApiFfiException implements Exception {
  String? message;
  ApiFfiException({this.message});
  @override
  String toString() =>
      (message != null) ? '$runtimeType( $message )' : runtimeType.toString();
}

class GenericException extends ApiFfiException {
  /// Constructs the [GenericException]
  GenericException({super.message});
}

class SessionErrorException extends ApiFfiException {
  SessionErrorException({super.message});
}

Exception handleApiException(bridge.ApiError error) {
  return error.when(
    generic: (e) => GenericException(message: e),
    sessionError: (e) => SessionErrorException(message: e),
  );
}
