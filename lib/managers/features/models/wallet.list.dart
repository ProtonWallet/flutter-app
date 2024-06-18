import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/wallet.model.dart';

class WalletMenuModel {
  /// state
  bool hasValidPassword = false;
  String walletName = 'Proton Wallet';
  int accountSize = 0;
  bool isSignatureValid = true;
  int currentIndex = 0;

  bool isSelected = false;
  List<AccountMenuModel> accounts = [];

  final WalletModel walletModel;

  WalletMenuModel(this.walletModel);
}

class AccountMenuModel {
  // String icon = "";
  bool loading = true;
  String label = "Default Account";
  String currencyBalance = "";
  String btcBalance = "";
  int currentIndex = 0;
  int balance = 0;

  bool isSelected = false;
  final AccountModel accountModel;
  List<String> emailIds = [];

  AccountMenuModel(this.accountModel);
}
