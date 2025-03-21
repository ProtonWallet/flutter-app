import 'dart:math';

import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/helper/fiat.currency.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';

class ExchangeCalculator {
  static double getNotionalInFiatCurrency(
    ProtonExchangeRate exchangeRate,
    int amountInSatoshi,
  ) {
    final fiatCurrency = exchangeRate.fiatCurrency;
    if (fiatCurrency2Info.containsKey(fiatCurrency)) {
      final fiatCurrencyInfo = fiatCurrency2Info[fiatCurrency]!;
      final outValue = exchangeRate.exchangeRate *
          BigInt.from(amountInSatoshi) /
          BigInt.from(fiatCurrencyInfo.cents) /
          btc2satoshi;
      return outValue;
    }
    return exchangeRate.exchangeRate *
        BigInt.from(amountInSatoshi) /
        BigInt.from(btc2satoshi);
  }

  static int getDisplayDigit(ProtonExchangeRate exchangeRate) {
    try {
      return (log(exchangeRate.cents.toInt()) / log(10)).round();
    } catch (e, stacktrace) {
      logger.e("getDisplayDigit error: $e, stacktrace: $stacktrace");
    }
    return defaultDisplayDigits;
  }

  // TODO(fix): frbamount could be used here. we dont need to handle the caculation ourself
  static String getBitcoinUnitLabel(
    BitcoinUnit bitcoinUnit,
    int amountInSatoshi,
  ) {
    double amount = amountInSatoshi.toDouble();
    switch (bitcoinUnit) {
      case BitcoinUnit.btc:
        amount = amountInSatoshi / btc2satoshi;
        return "${amount.toStringAsFixed(8)} ${bitcoinUnit.name.toUpperCase()}";
      case BitcoinUnit.mbtc:
        amount = amountInSatoshi / 100000;
        return "${amount.toStringAsFixed(5)} mBTC";
      default:
        break;
    }
    return "${NumberFormat('#,###').format(amount.toInt())} ${bitcoinUnit.name.toUpperCase()}";
  }

  static Widget getBitcoinUnitLabelWidget(
    BitcoinUnit bitcoinUnit,
    int amountInSatoshi, {
    required TextStyle textStyle,
  }) {
    double amount = amountInSatoshi.toDouble();
    switch (bitcoinUnit) {
      case BitcoinUnit.btc:
        amount = amountInSatoshi / btc2satoshi;
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
      thousandSeparator: ",",
      suffix: " ${bitcoinUnit.name.toUpperCase()}",
      textStyle: textStyle,
    );
  }

  static double getNotionalInBTC(
    ProtonExchangeRate exchangeRate,
    double amountInFiatCurrency,
  ) {
    final fiatCurrency = exchangeRate.fiatCurrency;
    if (fiatCurrency2Info.containsKey(fiatCurrency)) {
      final fiatCurrencyInfo = fiatCurrency2Info[fiatCurrency]!;
      return amountInFiatCurrency /
          (exchangeRate.exchangeRate / BigInt.from(fiatCurrencyInfo.cents));
    }
    return amountInFiatCurrency /
        (exchangeRate.exchangeRate / BigInt.from(100));
  }
}
