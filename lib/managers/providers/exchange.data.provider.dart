import 'dart:async';

import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/rust/api/api_service/exchange_rate_client.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';

class ExchangeDataProvider extends DataProvider {
  /// api client
  final ExchangeRateClient exchangeRateClient;

  /// memory caches
  Map<String, ProtonExchangeRate> fiatCurrency2exchangeRate = {};

  ExchangeDataProvider({required this.exchangeRateClient});

  StreamController<DataUpdated> dataUpdateController =
      StreamController<DataUpdated>();

  Future<void> runOnce(FiatCurrency fiatCurrency, {int? time}) async {
    final String key = getKey(fiatCurrency, time: time);

    /// fetch from server and update the cache
    fiatCurrency2exchangeRate[key] = await exchangeRateClient.getExchangeRate(
      fiatCurrency: fiatCurrency,
      time: time == null ? null : BigInt.from(time),
    );
  }

  Future<ProtonExchangeRate> getExchangeRate(FiatCurrency fiatCurrency,
      {int? time}) async {
    final String key = getKey(fiatCurrency, time: time);

    /// check if we can found in cache
    if (!fiatCurrency2exchangeRate.containsKey(key)) {
      /// fetch from server and update the cache
      await runOnce(fiatCurrency, time: time);
    }
    return fiatCurrency2exchangeRate[key]!;
  }

  ProtonExchangeRate? getExchangeRateOrNull(FiatCurrency fiatCurrency) {
    final String key = getKey(fiatCurrency);
    return fiatCurrency2exchangeRate[key];
  }

  @override
  Future<void> clear() async {
    fiatCurrency2exchangeRate.clear();
    dataUpdateController.close();
  }

  String getKey(FiatCurrency fiatCurrency, {int? time}) {
    String key = fiatCurrency.name;
    if (time != null) {
      key = "$key:$time";
    }
    return key;
  }

  @override
  Future<void> reload() async {}
}
