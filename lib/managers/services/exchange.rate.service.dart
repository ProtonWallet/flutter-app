import 'package:wallet/rust/api/proton_api.dart' as proton_api;
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';

class ExchangeRateService {
  static Map<String, ProtonExchangeRate> fiatCurrency2exchangeRate = {};

  static Future<void> runOnce(FiatCurrency fiatCurrency, {int? time}) async {
    final String key = getKey(fiatCurrency, time: time);

    final exchangeRate = await proton_api.getExchangeRate(
        fiatCurrency: fiatCurrency,
        time: time == null ? null : BigInt.from(time));
    fiatCurrency2exchangeRate[key] = exchangeRate;
  }

  static Future<ProtonExchangeRate> getExchangeRate(
    FiatCurrency fiatCurrency, {
    int? time,
  }) async {
    final String key = getKey(fiatCurrency, time: time);
    if (!fiatCurrency2exchangeRate.containsKey(key)) {
      await runOnce(fiatCurrency, time: time);
    }
    return fiatCurrency2exchangeRate[key]!;
  }

  static ProtonExchangeRate? getExchangeRateOrNull(FiatCurrency fiatCurrency) {
    final String key = getKey(fiatCurrency);
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
