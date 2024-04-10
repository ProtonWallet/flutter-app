import 'package:wallet/rust/proton_api/user_settings.dart';

class CommonHelper {
  static CommonBitcoinUnit getBitcoinUnit(String str) {
    switch (str) {
      case "BTC":
        return CommonBitcoinUnit.btc;
      case "MBTC":
        return CommonBitcoinUnit.mbtc;
      case "SATS":
        return CommonBitcoinUnit.sats;
      default:
        return CommonBitcoinUnit.sats;
    }
  }

  static FiatCurrency getFiatCurrency(String str) {
    switch (str) {
      case "USD":
        return FiatCurrency.usd;
      case "EUR":
        return FiatCurrency.eur;
      case "CHF":
        return FiatCurrency.chf;
      default:
        return FiatCurrency.eur;
    }
  }

  static String getFirstNChar(String str, int n){
    if (n >= str.length){
      return str;
    }
    return str.substring(0, n);
  }

  static double getEstimateValue({required double amount, required bool isBitcoinBase, required int currencyExchangeRate}) {
    if (isBitcoinBase) {
      return amount * currencyExchangeRate / 100;
    } else {
      return amount * 100 / currencyExchangeRate;
    }
  }
}
