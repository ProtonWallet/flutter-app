import "package:wallet/network/api.response.dart";

import "http.api.service.dart";
import "dart:convert";

class APIHelper {
  static HttpApiService _httpApiService = HttpApiService("");
  static Map<String, String> _customHeaders = {};
  static String accessToken = "";
  static String sessionUid = "";
  static String userKeyID = "";

  static void init(String accessToken, String sessionUid, String userKeyID) {
    APIHelper.accessToken = accessToken;
    APIHelper.sessionUid = sessionUid;
    APIHelper.userKeyID = userKeyID;
    _httpApiService = HttpApiService("https://proton.black/api/wallet/v1/");
    _customHeaders = {
      "Accept": "application/vnd.protonmail.api+json",
      "Authorization": "Bearer $accessToken",
      "x-pm-uid": sessionUid,
      "Accept-Language": "en-us",
      "Accept-Encoding": "gzip, deflate, br",
      "x-pm-appversion": "web-wallet@0.0.1-dev",
      "Content-Type": "application/json;charset=utf-8",
    };
  }

  static Future<bool> createWallet(Map<String, dynamic> jsonPayload) async {
    ApiResponse apiResponse = await _httpApiService.post(
        "wallets", json.encode(jsonPayload), _customHeaders);
    return apiResponse.statusCode == 200;
  }


  static Future<String> getUserSettings() async {
    ApiResponse apiResponse =
    await _httpApiService.get("settings", _customHeaders);
    return apiResponse.response;
  }

  static Future<String> getWallets() async {
    ApiResponse apiResponse =
        await _httpApiService.get("wallets", _customHeaders);
    return apiResponse.response;
  }

  static Future<String> getBalanceFromAddress(String address) async {
    ApiResponse apiResponse =
        await _httpApiService.get("addresses/$address/balance", _customHeaders);
    return apiResponse.response;
  }
}
