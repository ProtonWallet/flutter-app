import 'dart:math';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/exchange.caculator.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';

class BitcoinAmount {
  int amountInSatoshi;
  BitcoinUnit bitcoinUnit;
  ProtonExchangeRate exchangeRate;

  BitcoinAmount({
    required this.amountInSatoshi,
    required this.bitcoinUnit,
    required this.exchangeRate,
  });

  double getNotionalInFiatCurrency() {
    return ExchangeCalculator.getNotionalInFiatCurrency(
        exchangeRate, amountInSatoshi);
  }

  int getDisplayDigit() {
    return (log(exchangeRate.cents.toInt()) / log(10)).round();
  }

  String toFiatCurrencyString() {
    int displayDigits = getDisplayDigit();
    double amountInFiatCurrency = getNotionalInFiatCurrency().abs();
    String amountString = CommonHelper.formatDouble(amountInFiatCurrency,
        displayDigits: displayDigits);
    String fiatCurrencyName =
        exchangeRate.fiatCurrency.name.toString().toUpperCase();
    if (amountInSatoshi > 0) {
      return "$fiatCurrencyName $amountString";
    }
    return "-$fiatCurrencyName $amountString";
  }

  @override
  String toString() {
    return ExchangeCalculator.getBitcoinUnitLabel(bitcoinUnit, amountInSatoshi);
  }
}
