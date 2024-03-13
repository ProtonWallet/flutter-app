import 'package:flutter/cupertino.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/rust/proton_api/user_settings.dart'
    as proton_user_setting;
import 'package:wallet/rust/proton_api/user_settings.dart';

class WalletUserSetting {
  proton_user_setting.FiatCurrency fiatCurrency =
      proton_user_setting.FiatCurrency.usd;
  BitcoinUnit bitcoinUnit = BitcoinUnit.btc;
  ProtonExchangeRate exchangeRate = const ProtonExchangeRate(
      id: 'default',
      bitcoinUnit: BitcoinUnit.btc,
      fiatCurrency: FiatCurrency.usd,
      exchangeRateTime: '',
      exchangeRate: 1,
      cents: 1);
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

  String getFiatCurrencyName() {
    return walletUserSetting.fiatCurrency.name.toString().toUpperCase();
  }

  String getFiatCurrencySign() {
    return fiatCurrency2Sign.containsKey(walletUserSetting.fiatCurrency)
        ? fiatCurrency2Sign[walletUserSetting.fiatCurrency] ?? "\$"
        : "\$";
  }
}
