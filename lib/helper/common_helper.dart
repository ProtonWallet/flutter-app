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
}
