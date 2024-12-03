import 'api.response.dart';

abstract class ApiService {
  Future<ApiResponse> put(
      String endpoint, String payload, Map<String, String> customHeaders);
  Future<ApiResponse> delete(
      String endpoint, Map<String, String> customHeaders);
  Future<ApiResponse> get(String endpoint, Map<String, String> customHeaders);
  Future<ApiResponse> post(
      String endpoint, String payload, Map<String, String> customHeaders);
}
