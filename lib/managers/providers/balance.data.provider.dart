import 'dart:async';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/rust/api/bdk_wallet/account.dart';

class BDKBalanceData {
  final WalletModel walletModel;
  final AccountModel accountModel;
  final FrbAccount? account;

  BDKBalanceData({
    required this.walletModel,
    required this.accountModel,
    required this.account,
  });

  Future<int> getBalance() async {
    if (account != null) {
      final balance = await account!.getBalance();
      return balance.trustedSpendable().toSat().toInt();
    }
    return 0;
  }
}

class BalanceUpdated extends DataUpdated<List<BDKBalanceData>> {
  BalanceUpdated(super.updatedData);
}
