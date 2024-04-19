import 'package:wallet/helper/wallet_manager.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';

class ExchangeRateService{
  static Map<FiatCurrency, ProtonExchangeRate> fiatCurrency2exchangeRate = {};

  static Future<void> runOnce(FiatCurrency fiatCurrency) async {
    fiatCurrency2exchangeRate[fiatCurrency] = await WalletManager.getExchangeRate(fiatCurrency);
  }

  static Future<ProtonExchangeRate> getExchangeRate(FiatCurrency fiatCurrency) async {
    if (fiatCurrency2exchangeRate.containsKey(fiatCurrency) == false){
      await runOnce(fiatCurrency);
    }
    return fiatCurrency2exchangeRate[fiatCurrency]!;
  }

  static void clear(){
    fiatCurrency2exchangeRate.clear();
  }
}