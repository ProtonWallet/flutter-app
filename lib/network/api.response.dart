class ApiResponse {
  final String response;
  final int statusCode;
  final String errorMessage;

  ApiResponse({
    required this.response,
    required this.statusCode,
    required this.errorMessage,
  });
}
