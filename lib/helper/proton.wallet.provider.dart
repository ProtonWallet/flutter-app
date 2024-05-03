import 'package:flutter/cupertino.dart';
import 'package:wallet/constants/history.transaction.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/wallet.model.dart';


class ProtonWallet {
  WalletModel? currentWallet;
  AccountModel? currentAccount;
  List<HistoryTransaction> historyTransactions = [];
  List<WalletModel> wallets = [];
  List<AccountModel> accounts = [];

}

class ProtonWalletProvider with ChangeNotifier {
  final ProtonWallet protonWallet = ProtonWallet();

  Future<void> setProtonWallet(WalletModel walletModel, AccountModel accountModel) async{
    protonWallet.currentWallet = walletModel;
    protonWallet.currentAccount = accountModel;
    notifyListeners();
  }

  Future<void> loadTransactions() async {
    
  }

}
