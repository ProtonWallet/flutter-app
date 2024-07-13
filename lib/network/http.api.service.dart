import 'package:http/http.dart' as http;

import 'api.response.dart';
import 'api.service.dart';

// TODO(fix): Use Rust to replace code here
class HttpApiService implements ApiService {
  final String baseUrl;

  HttpApiService(this.baseUrl);

  @override
  Future<ApiResponse> get(
      String endpoint, Map<String, String> customHeaders) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$endpoint'),
          headers: customHeaders);

      return ApiResponse(
        response: response.body,
        statusCode: response.statusCode,
        errorMessage: '',
      );
    } catch (e) {
      return ApiResponse(
        response: "",
        statusCode: 500,
        errorMessage: 'Error making GET request: $e',
      );
    }
  }

  @override
  Future<ApiResponse> post(String endpoint, String payload,
      Map<String, String> customHeaders) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: customHeaders,
        body: payload,
      );

      return ApiResponse(
        response: response.body,
        statusCode: response.statusCode,
        errorMessage: '',
      );
    } catch (e) {
      return ApiResponse(
        response: "",
        statusCode: 500,
        errorMessage: 'Error making POST request: $e',
      );
    }
  }

  @override
  Future<ApiResponse> delete(
      String endpoint, Map<String, String> customHeaders) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$endpoint'),
          headers: customHeaders);

      return ApiResponse(
        response: response.body,
        statusCode: response.statusCode,
        errorMessage: '',
      );
    } catch (e) {
      return ApiResponse(
        response: "",
        statusCode: 500,
        errorMessage: 'Error making GET request: $e',
      );
    }
  }

  @override
  Future<ApiResponse> put(String endpoint, String payload,
      Map<String, String> customHeaders) async {
    try {
      final response = await http.put(Uri.parse('$baseUrl/$endpoint'),
          headers: customHeaders, body: payload);

      return ApiResponse(
        response: response.body,
        statusCode: response.statusCode,
        errorMessage: '',
      );
    } catch (e) {
      return ApiResponse(
        response: "",
        statusCode: 500,
        errorMessage: 'Error making GET request: $e',
      );
    }
  }
}
