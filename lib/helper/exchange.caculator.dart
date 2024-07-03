import 'dart:math';

import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/widgets.dart';
import 'package:wallet/constants/constants.dart';
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
      var outValue = exchangeRate.exchangeRate *
          amountInSatoshi /
          fiatCurrencyInfo.cents /
          100000000;
      return outValue;
    }
    return exchangeRate.exchangeRate * amountInSatoshi / 100000000;
  }

  static int getDisplayDigit(
    ProtonExchangeRate exchangeRate,
  ) {
    try {
      return (log(exchangeRate.cents) / log(10)).round();
    } catch (e) {
      //
    }
    return defaultDisplayDigits;
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

  static Widget getBitcoinUnitLabelWidget(
      BitcoinUnit bitcoinUnit, int amountInSatoshi,
      {required TextStyle textStyle}) {
    double amount = amountInSatoshi.toDouble();
    switch (bitcoinUnit) {
      case BitcoinUnit.btc:
        amount = amountInSatoshi / 100000000;
        return AnimatedFlipCounter(
          duration: const Duration(milliseconds: 500),
          value: amount,
          suffix: " ${bitcoinUnit.name.toUpperCase()}",
          fractionDigits: 8,
          textStyle: textStyle,
        );
      case BitcoinUnit.mbtc:
        amount = amountInSatoshi / 100000;
        return AnimatedFlipCounter(
          duration: const Duration(milliseconds: 500),
          value: amount,
          suffix: " ${bitcoinUnit.name.toUpperCase()}",
          fractionDigits: 5,
          textStyle: textStyle,
        );
      default:
        break;
    }
    return AnimatedFlipCounter(
      duration: const Duration(milliseconds: 500),
      value: amount.toInt(),
      suffix: " ${bitcoinUnit.name.toUpperCase()}",
      fractionDigits: 0,
      textStyle: textStyle,
    );
  }

  static double getNotionalInBTC(
    ProtonExchangeRate exchangeRate,
    double amountInFiatCurrency,
  ) {
    FiatCurrency fiatCurrency = exchangeRate.fiatCurrency;
    if (fiatCurrency2Info.containsKey(fiatCurrency)) {
      FiatCurrencyInfo fiatCurrencyInfo = fiatCurrency2Info[fiatCurrency]!;
      return amountInFiatCurrency /
          (exchangeRate.exchangeRate / fiatCurrencyInfo.cents);
    }
    return amountInFiatCurrency / (exchangeRate.exchangeRate / 100);
  }
}
