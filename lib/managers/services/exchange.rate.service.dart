import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';

class ExchangeRateService {
  static Map<String, ProtonExchangeRate> fiatCurrency2exchangeRate = {};

  static Future<void> runOnce(FiatCurrency fiatCurrency, {int? time}) async {
    String key = getKey(fiatCurrency, time: time);
    fiatCurrency2exchangeRate[key] =
        await WalletManager.getExchangeRate(fiatCurrency, time: time);
  }

  static Future<ProtonExchangeRate> getExchangeRate(FiatCurrency fiatCurrency,
      {int? time}) async {
    String key = getKey(fiatCurrency, time: time);
    if (fiatCurrency2exchangeRate.containsKey(key) == false) {
      await runOnce(fiatCurrency, time: time);
    }
    return fiatCurrency2exchangeRate[key]!;
  }

  static ProtonExchangeRate? getExchangeRateOrNull(FiatCurrency fiatCurrency) {
    String key = getKey(fiatCurrency, time: null);
    return fiatCurrency2exchangeRate[key];
  }

  static void clear() {
    fiatCurrency2exchangeRate.clear();
  }

  static String getKey(FiatCurrency fiatCurrency, {int? time}) {
    String key = fiatCurrency.name;
    if (time != null) {
      key = "$key:$time";
    }
    return key;
  }
}
