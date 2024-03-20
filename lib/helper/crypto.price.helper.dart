import 'dart:convert';
import 'dart:io';

import 'package:wallet/helper/crypto.price.info.dart';

class CryptoPriceHelper {
  static Future<CryptoPriceInfo> getPriceInfo(String symbol) async {
    HttpClient httpClient = HttpClient();
    var uri = Uri.https('api.binance.com', '/api/v3/ticker/24hr', {'symbol': symbol});
    var request = await httpClient.getUrl(uri);
    var response = await request.close();

    if (response.statusCode == 200) {
      var responseBody = await response.transform(utf8.decoder).join();
      var jsonData = jsonDecode(responseBody);
      return CryptoPriceInfo(
        symbol: jsonData['symbol'],
        price: double.parse(jsonData['lastPrice']),
        priceChange24h: double.parse(jsonData['priceChangePercent']),
      );
    } else {
      return CryptoPriceInfo(
        symbol: symbol,
          price: 0.0,
          priceChange24h: 0.0,
      );
    }
  }

  static Future<double> getBTCFee() async {
    try {
      HttpClient httpClient = HttpClient();
      var uri = Uri.https('blockstream.info', '/api/fee-estimates');
      var request = await httpClient.getUrl(uri);
      var response = await request.close();
      if (response.statusCode == 200) {
        var responseBody = await response.transform(utf8.decoder).join();
        var jsonData = jsonDecode(responseBody);
        final double feePerByte = jsonData['1'] / 1000; // fee of 1sat/byte
        return feePerByte;
      } else {
        throw Exception('Failed to load BTC transaction fee');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}