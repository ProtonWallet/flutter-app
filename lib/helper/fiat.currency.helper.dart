import 'package:wallet/rust/proton_api/user_settings.dart';

class FiatCurrencyHelper{
  static String getText(ApiFiatCurrency apiFiatCurrency){
    if (apiFiatCurrency == ApiFiatCurrency.eur){
      return "EUR €";
    }
    if (apiFiatCurrency == ApiFiatCurrency.chf){
      return "CHF ₣";
    }
    if (apiFiatCurrency == ApiFiatCurrency.usd){
      return "USD \$";
    }
    return "Unknown";
  }
}