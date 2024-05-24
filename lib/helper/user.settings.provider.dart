import 'package:flutter/cupertino.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/helper/fiat.currency.helper.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/rust/proton_api/user_settings.dart'
    as proton_user_setting;
import 'package:wallet/rust/proton_api/user_settings.dart';

class WalletUserSetting {
  proton_user_setting.FiatCurrency fiatCurrency =
      defaultFiatCurrency;
  BitcoinUnit bitcoinUnit = BitcoinUnit.btc;
  ProtonExchangeRate exchangeRate = const ProtonExchangeRate(
      id: 'default',
      bitcoinUnit: BitcoinUnit.btc,
      fiatCurrency: defaultFiatCurrency,
      exchangeRateTime: '',
      exchangeRate: 1,
      cents: 1);

  void destroy() {
    // clear data to default one
    fiatCurrency = defaultFiatCurrency;
    bitcoinUnit = BitcoinUnit.btc;
    exchangeRate = const ProtonExchangeRate(
        id: 'default',
        bitcoinUnit: BitcoinUnit.btc,
        fiatCurrency: defaultFiatCurrency,
        exchangeRateTime: '',
        exchangeRate: 1,
        cents: 1);
  }
}

class UserSettingProvider with ChangeNotifier {
  final WalletUserSetting walletUserSetting = WalletUserSetting();

  void updateBitcoinUnit(BitcoinUnit bitcoinUnit) {
    walletUserSetting.bitcoinUnit = bitcoinUnit;
    notifyListeners();
  }

  void updateFiatCurrency(proton_user_setting.FiatCurrency fiatCurrency) {
    walletUserSetting.fiatCurrency = fiatCurrency;
    notifyListeners();
  }

  String getBitcoinUnitLabel(int amountInSatoshi) {
    double amount = amountInSatoshi.toDouble();
    switch (walletUserSetting.bitcoinUnit) {
      case BitcoinUnit.btc:
        amount = amountInSatoshi / 100000000;
        return "${amount.toStringAsFixed(8)} ${walletUserSetting.bitcoinUnit.name.toUpperCase()}";
      case BitcoinUnit.mbtc:
        amount = amountInSatoshi / 100000;
        return "${amount.toStringAsFixed(5)} ${walletUserSetting.bitcoinUnit.name.toUpperCase()}";
      default:
        break;
    }
    return "${amount.toInt()} ${walletUserSetting.bitcoinUnit.name.toUpperCase()}";
  }

  void updateExchangeRate(ProtonExchangeRate exchangeRate) {
    walletUserSetting.exchangeRate = exchangeRate;
    notifyListeners();
    logger.i(
        "Updating exchangeRate (${walletUserSetting.exchangeRate.fiatCurrency.name}) = ${walletUserSetting.exchangeRate.exchangeRate}");
  }

  double getNotionalInFiatCurrency(int amountInSATS) {
    FiatCurrency fiatCurrency = walletUserSetting.exchangeRate.fiatCurrency;
    if (fiatCurrency2Info.containsKey(fiatCurrency)) {
      FiatCurrencyInfo fiatCurrencyInfo = fiatCurrency2Info[fiatCurrency]!;
      return walletUserSetting.exchangeRate.exchangeRate *
          amountInSATS /
          fiatCurrencyInfo.cents /
          100000000;
    }
    return walletUserSetting.exchangeRate.exchangeRate *
        amountInSATS /
        100000000;
  }


  double getNotionalInBTC(double amountInFiatCurrency) {
    FiatCurrency fiatCurrency = walletUserSetting.exchangeRate.fiatCurrency;
    if (fiatCurrency2Info.containsKey(fiatCurrency)) {
      FiatCurrencyInfo fiatCurrencyInfo = fiatCurrency2Info[fiatCurrency]!;
      return amountInFiatCurrency / (walletUserSetting.exchangeRate.exchangeRate / fiatCurrencyInfo.cents);
    }
    return amountInFiatCurrency / (walletUserSetting.exchangeRate.exchangeRate / 100);
  }

  String getFiatCurrencyName() {
    return walletUserSetting.fiatCurrency.name.toString().toUpperCase();
  }

  String getFiatCurrencySign() {
    return fiatCurrency2Info.containsKey(walletUserSetting.fiatCurrency)
        ? fiatCurrency2Info[walletUserSetting.fiatCurrency]!.sign
        : "\$";
  }

  void destroy() {
    walletUserSetting.destroy();
  }
}
