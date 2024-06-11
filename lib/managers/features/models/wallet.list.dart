class WalletMenuModel {
  /// state
  bool hasValidPassword = false;
  String walletName = 'Proton Wallet';
  int accountSize = 0;
  // String icon;

  List<AccountMenuModel> accounts = [];

  // final WalletModel wallet;
  // final List<AccountModel> accounts;
  // WalletListModel({required this.wallet, required this.accounts});

  // static List<WalletMenuModel> fromWalletData(List<WalletData> items) {
  //   return items
  //       .map((item) =>
  //           WalletListModel(wallet: item.wallet, accounts: item.accounts))
  //       .toList();
  // }
}

class AccountMenuModel {
  // String icon = "";
  bool loading = true;
}
