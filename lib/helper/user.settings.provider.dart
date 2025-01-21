import 'package:flutter/cupertino.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/helper/fiat.currency.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/rust/proton_api/user_settings.dart'
    as proton_user_setting;
import 'package:wallet/rust/proton_api/user_settings.dart';

class WalletUserSetting {
  proton_user_setting.FiatCurrency fiatCurrency = defaultFiatCurrency;
  BitcoinUnit bitcoinUnit = BitcoinUnit.btc;
  ProtonExchangeRate exchangeRate = defaultExchangeRate;

  void destroy() {
    // clear data to default one
    fiatCurrency = defaultFiatCurrency;
    bitcoinUnit = BitcoinUnit.btc;
    exchangeRate = defaultExchangeRate;
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

  void updateExchangeRate(ProtonExchangeRate exchangeRate) {
    walletUserSetting.exchangeRate = exchangeRate;
    notifyListeners();
    logger.d(
      "updateExchangeRate (${walletUserSetting.exchangeRate.fiatCurrency.name}) = ${walletUserSetting.exchangeRate.exchangeRate}",
    );
  }

  double getNotionalInBTC(double amountInFiatCurrency) {
    final FiatCurrency fiatCurrency =
        walletUserSetting.exchangeRate.fiatCurrency;
    if (fiatCurrency2Info.containsKey(fiatCurrency)) {
      final FiatCurrencyInfo fiatCurrencyInfo =
          fiatCurrency2Info[fiatCurrency]!;
      return amountInFiatCurrency /
          (walletUserSetting.exchangeRate.exchangeRate /
              BigInt.from(fiatCurrencyInfo.cents));
    }
    return amountInFiatCurrency /
        (walletUserSetting.exchangeRate.exchangeRate / BigInt.from(100));
  }

  String getFiatCurrencyName({FiatCurrency? fiatCurrency}) {
    fiatCurrency ??= walletUserSetting.fiatCurrency;
    return fiatCurrency.name.toUpperCase();
  }

  String getFiatCurrencySign({FiatCurrency? fiatCurrency}) {
    fiatCurrency ??= walletUserSetting.fiatCurrency;
    return fiatCurrency2Info.containsKey(fiatCurrency)
        ? fiatCurrency2Info[fiatCurrency]!.sign
        : "\$";
  }

  void destroy() {
    walletUserSetting.destroy();
  }
}
