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
  ProtonExchangeRate exchangeRate = const ProtonExchangeRate(
      id: 'default',
      bitcoinUnit: CommonBitcoinUnit.btc,
      fiatCurrency: FiatCurrency.usd,
      exchangeRateTime: '',
      exchangeRate: 1,
      cents: 1);
}

class UserSettingProvider with ChangeNotifier {
  final WalletUserSetting walletUserSetting = WalletUserSetting();

  void updateFiatCurrency(proton_user_setting.FiatCurrency fiatCurrency) {
    walletUserSetting.fiatCurrency = fiatCurrency;
    notifyListeners();
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
