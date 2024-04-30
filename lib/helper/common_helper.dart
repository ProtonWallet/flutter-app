import 'package:wallet/rust/proton_api/user_settings.dart';

class CommonHelper {
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

  static String getFirstNChar(String str, int n) {
    if (n >= str.length) {
      return str;
    }
    if (n > 1) {
      return "${str.substring(0, n)}..";
    }
    return str.substring(0, n);
  }

  static bool isBitcoinAddress(String bitcoinAddress) {
    return bitcoinAddress.toLowerCase().startsWith("tb") &&
        bitcoinAddress.length > 30;
  }
}
