import 'package:wallet/managers/providers/wallet.data.provider.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/wallet.model.dart';

class WalletListModel {
  /// state
  bool hasValidPassword = false;

  ///
  final WalletModel wallet;
  final List<AccountModel> accounts;
  WalletListModel({required this.wallet, required this.accounts});

  static List<WalletListModel> fromWalletData(List<WalletData> items) {
    return items
        .map((item) =>
            WalletListModel(wallet: item.wallet, accounts: item.accounts))
        .toList();
  }
}
