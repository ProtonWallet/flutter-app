import 'package:wallet/helper/fiat.currency.helper.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';

class ExchangeCaculator {
  ///
  static double getNotionalInFiatCurrency(
    int amountInSATS,
    ProtonExchangeRate exchangeRate,
  ) {
    // exchangeRate ??= walletUserSetting.exchangeRate;
    FiatCurrency fiatCurrency = exchangeRate.fiatCurrency;
    if (fiatCurrency2Info.containsKey(fiatCurrency)) {
      FiatCurrencyInfo fiatCurrencyInfo = fiatCurrency2Info[fiatCurrency]!;
      return exchangeRate.exchangeRate *
          amountInSATS /
          fiatCurrencyInfo.cents /
          100000000;
    }
    return exchangeRate.exchangeRate * amountInSATS / 100000000;
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
