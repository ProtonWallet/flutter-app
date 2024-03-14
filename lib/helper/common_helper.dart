import 'package:wallet/rust/proton_api/user_settings.dart';

class CommonHelper {
  static CommonBitcoinUnit getBitcoinUnit(String str){
    switch (str){
      case "BTC":
        return CommonBitcoinUnit.btc;
      case "MBTC":
        return  CommonBitcoinUnit.mbtc;
      case "SATS":
        return CommonBitcoinUnit.sats;
      default:
        return CommonBitcoinUnit.sats;
    }
  }
  static ApiFiatCurrency getFiatCurrency(String str){
    switch (str){
      case "USD":
        return ApiFiatCurrency.usd;
      case "EUR":
        return ApiFiatCurrency.eur;
      case "CHF":
        return ApiFiatCurrency.chf;
      default:
        return ApiFiatCurrency.eur;
    }
  }
}
