import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/wallet.model.dart';

class WalletBDKData {
  final WalletModel wallet;
  final List<AccountModel> accounts;
  WalletBDKData({required this.wallet, required this.accounts});
}

class WalletBdkDataProvider {
  // final WalletClient walletClient;
  // final WalletDao walletDao;
  // final AccountDao accountDao;
  // final AddressDao addressDao;
  final String userID = ""; // need to add userid.

  // need to monitor the db changes apply to this cache
  List<WalletBDKData>? walletsData;

  // WalletsDataProvider(
  //   this.walletDao,
  //   this.accountDao,
  //   this.addressDao,
  //   this.walletClient,
  // );

  void getBalance() {}
}
