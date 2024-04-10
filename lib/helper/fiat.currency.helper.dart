import 'package:wallet/rust/proton_api/user_settings.dart';

class FiatCurrencyHelper {
  static String getText(FiatCurrency apiFiatCurrency) {
    if (apiFiatCurrency == FiatCurrency.eur) {
      return "EUR €";
    }
    if (apiFiatCurrency == FiatCurrency.chf) {
      return "CHF ₣";
    }
    if (apiFiatCurrency == FiatCurrency.usd) {
      return "USD \$";
    }
    return "Unknown";
  }
}
