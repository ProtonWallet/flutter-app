class WalletBDKData {}

class WalletBdkDataProvider {
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
