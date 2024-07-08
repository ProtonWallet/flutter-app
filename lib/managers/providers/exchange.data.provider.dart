import 'dart:async';

import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/rust/api/api_service/exchange_rate_client.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';

class ExchangeDataProvider extends DataProvider {
  Map<String, ProtonExchangeRate> fiatCurrency2exchangeRate = {};
  final ExchangeRateClient exchangeRateClient;

  ExchangeDataProvider({required this.exchangeRateClient});

  StreamController<DataUpdated> dataUpdateController =
      StreamController<DataUpdated>();

  Future<void> runOnce(FiatCurrency fiatCurrency, {int? time}) async {
    String key = getKey(fiatCurrency, time: time);
    fiatCurrency2exchangeRate[key] = await exchangeRateClient.getExchangeRate(
      fiatCurrency: fiatCurrency,
      time: time == null ? null : BigInt.from(time),
    );
  }

  Future<ProtonExchangeRate> getExchangeRate(FiatCurrency fiatCurrency,
      {int? time}) async {
    String key = getKey(fiatCurrency, time: time);
    if (fiatCurrency2exchangeRate.containsKey(key) == false) {
      await runOnce(fiatCurrency, time: time);
    }
    return fiatCurrency2exchangeRate[key]!;
  }

  ProtonExchangeRate? getExchangeRateOrNull(FiatCurrency fiatCurrency) {
    String key = getKey(fiatCurrency, time: null);
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
}
