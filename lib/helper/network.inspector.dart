import 'package:http/http.dart' as http;
import 'package:wallet/helper/logger.dart';

/// Flutter can't dirrectly capture rust network triffic. This function is a workaround to simulate network traffic
/// var logs = "Request: https://test.url, Response: { Code: 200, Message: 'Success'}";
/// simulateNetworkTraffic(logs);
void simulateNetworkTraffic(String log) async {
  final requestPattern = RegExp(r'Request: (.*), Response: (.*)');
  final match = requestPattern.firstMatch(log);
  if (match != null) {
    final url = match.group(1);
    final responseBody = match.group(2);
    if (url != null && responseBody != null) {
      // Log the simulated network request
      final client = SimulateClient((request) async {
        return http.Response(responseBody, 200);
      });
      // Simulate a request to trigger Dart DevTools logging
      client.get(Uri.parse(url)).then((response) {
        logger.i('Simulated response: ${response.body}');
        client.close();
      }).catchError((e) {
        logger.i('Error logging simulated network traffic: $e');
      });
    }
  }
}

class SimulateClient extends http.BaseClient {
  final Future<http.Response> Function(http.BaseRequest) _handler;
  SimulateClient(this._handler);
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await _handler(request);
    return http.StreamedResponse(
      Stream.fromIterable([response.bodyBytes]),
      response.statusCode,
      request: request,
      headers: response.headers,
      reasonPhrase: response.reasonPhrase,
      persistentConnection: response.persistentConnection,
      isRedirect: response.isRedirect,
    );
  }
}
