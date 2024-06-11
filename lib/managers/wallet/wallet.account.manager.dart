import 'package:wallet/constants/constants.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/managers/manager.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';

// wallet account. could have multiple accounts in one wallet
class WalletAccountManager implements Manager {
  //final BdkLibrary _lib = BdkLibrary(coinType: appConfig.coinType);

  static Future<FiatCurrency> getAccountFiatCurrency(
      AccountModel? accountModel) async {
    if (accountModel != null) {
      return CommonHelper.getFiatCurrencyByName(accountModel.fiatCurrency.toUpperCase());
    }
    return defaultFiatCurrency;
  }

  @override
  Future<void> dispose() async {}

  @override
  Future<void> init() async {}

  @override
  Future<void> logout() async {}

  @override
  Future<void> login(String userID) async {
    // TODO: implement login
    throw UnimplementedError();
  }
}
