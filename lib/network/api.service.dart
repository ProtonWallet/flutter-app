import 'api.response.dart';

abstract class ApiService {
  Future<ApiResponse> get(String endpoint, Map<String, String> customHeaders);
  Future<ApiResponse> post(String endpoint, String payload, Map<String, String> customHeaders);
}