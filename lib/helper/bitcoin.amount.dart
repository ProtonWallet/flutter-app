import 'dart:math';
import 'package:wallet/constants/constants.dart';
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

  String toFiatCurrencyString({bool displayBalance = true}) {
    final int displayDigits = getDisplayDigit();
    final double amountInFiatCurrency = getNotionalInFiatCurrency().abs();
    final String amountString = displayBalance
        ? CommonHelper.formatDouble(amountInFiatCurrency,
            displayDigits: displayDigits)
        : hidedBalanceString;
    final String fiatCurrencyName =
        exchangeRate.fiatCurrency.name.toUpperCase();
    if (amountInSatoshi > 0) {
      return "$fiatCurrencyName $amountString";
    }
    return "-$fiatCurrencyName $amountString";
  }

  String toFiatCurrencySignString({bool displayBalance = true}) {
    final int displayDigits = getDisplayDigit();
    final double amountInFiatCurrency = getNotionalInFiatCurrency().abs();
    final String amountString = displayBalance
        ? CommonHelper.formatDouble(amountInFiatCurrency,
            displayDigits: displayDigits)
        : hidedBalanceString;
    final String sign =
        CommonHelper.getFiatCurrencySign(exchangeRate.fiatCurrency);
    if (amountInSatoshi > 0) {
      return "$sign$amountString";
    }
    return "-$sign$amountString";
  }

  @override
  String toString({bool displayBalance = true}) {
    if (!displayBalance) {
      return "$hidedBalanceString ${bitcoinUnit.name.toUpperCase() != "MBTC" ? bitcoinUnit.name.toUpperCase() : "mBTC"}";
    }
    return ExchangeCalculator.getBitcoinUnitLabel(bitcoinUnit, amountInSatoshi);
  }
}
