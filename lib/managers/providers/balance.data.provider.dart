import 'dart:async';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/models/account.dao.impl.dart';
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

class BalanceDataProvider extends DataProvider {
  final AccountDao accountDao;

  BalanceDataProvider(this.accountDao);

  List<BDKBalanceData> bdkBalanceDataList = [];

  Future<BDKBalanceData> getBDKBalanceDataByWalletAccount(
    WalletModel walletModel,
    AccountModel accountModel,
  ) async {
    final FrbAccount? account = await WalletManager.loadWalletWithID(
      walletModel.walletID,
      accountModel.accountID,
      serverScriptType: accountModel.scriptType,
    );
    return BDKBalanceData(
      walletModel: walletModel,
      accountModel: accountModel,
      account: account,
    );
  }

  @override
  Future<void> clear() async {
    // dataUpdateController.close();
  }
}
