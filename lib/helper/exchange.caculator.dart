import 'package:wallet/helper/fiat.currency.helper.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';

class ExchangeCalculator {
  static double getNotionalInFiatCurrency(
    ProtonExchangeRate exchangeRate,
    int amountInSatoshi,
  ) {
    FiatCurrency fiatCurrency = exchangeRate.fiatCurrency;
    if (fiatCurrency2Info.containsKey(fiatCurrency)) {
      FiatCurrencyInfo fiatCurrencyInfo = fiatCurrency2Info[fiatCurrency]!;
      return exchangeRate.exchangeRate *
          amountInSatoshi /
          fiatCurrencyInfo.cents /
          100000000;
    }
    return exchangeRate.exchangeRate * amountInSatoshi / 100000000;
  }

  static String getBitcoinUnitLabel(
    BitcoinUnit bitcoinUnit,
    int amountInSatoshi,
  ) {
    double amount = amountInSatoshi.toDouble();
    switch (bitcoinUnit) {
      case BitcoinUnit.btc:
        amount = amountInSatoshi / 100000000;
        return "${amount.toStringAsFixed(8)} ${bitcoinUnit.name.toUpperCase()}";
      case BitcoinUnit.mbtc:
        amount = amountInSatoshi / 100000;
        return "${amount.toStringAsFixed(5)} ${bitcoinUnit.name.toUpperCase()}";
      default:
        break;
    }
    return "${amount.toInt()} ${bitcoinUnit.name.toUpperCase()}";
  }
}
