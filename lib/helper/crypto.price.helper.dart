import 'dart:convert';
import 'dart:io';

import 'package:wallet/helper/crypto.price.info.dart';

class CryptoPriceHelper {
  /*
  Get crypto price via binance API
  TODO:: change to rust backend if needed
  */
  static Future<CryptoPriceInfo> getPriceInfo(String symbol) async {
    HttpClient httpClient = HttpClient();
    var uri =
        Uri.https('api.binance.com', '/api/v3/ticker/24hr', {'symbol': symbol});
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

  static Future<BitcoinTransactionFee> getBitcoinTransactionFee() async {
    return BitcoinTransactionFee(
      block1Fee: await getBitcoinTransactionFeeByBlock(1),
      block2Fee: await getBitcoinTransactionFeeByBlock(2),
      block3Fee: await getBitcoinTransactionFeeByBlock(3),
      block5Fee: await getBitcoinTransactionFeeByBlock(5),
      block10Fee: await getBitcoinTransactionFeeByBlock(10),
      block20Fee: await getBitcoinTransactionFeeByBlock(20),
    );
  }

  /*
  Get bitcoin transaction fee
  TODO:: change to rust backend if needed
  */
  static Future<double> getBitcoinTransactionFeeByBlock(int block) async {
    try {
      HttpClient httpClient = HttpClient();
      var uri = Uri.https('blockstream.info', '/api/fee-estimates');
      var request = await httpClient.getUrl(uri);
      var response = await request.close();
      if (response.statusCode == 200) {
        var responseBody = await response.transform(utf8.decoder).join();
        var jsonData = jsonDecode(responseBody);
        final double feePerByte = jsonData[block.toString()]; // ? sat/vB
        return feePerByte;
      } else {
        throw Exception('Failed to load BTC transaction fee');
      }
    } catch (e) {
      return 1.0;
    }
  }
}
