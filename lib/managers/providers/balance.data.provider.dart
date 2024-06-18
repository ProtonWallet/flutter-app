import 'dart:async';
import 'package:wallet/helper/bdk/helper.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/models/account.dao.impl.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/wallet.model.dart';

class BDKBalanceData {
  final WalletModel walletModel;
  final AccountModel accountModel;
  final Wallet? wallet;

  BDKBalanceData({
    required this.walletModel,
    required this.accountModel,
    required this.wallet,
  });

  Future<int> getBalance() async {
    if (wallet != null) {
      var balance = await wallet!.getBalance();
      return balance.trustedPending + balance.confirmed;
    }
    return 0;
  }
}

class BalanceDataProvider implements DataProvider {
  StreamController<BDKDataUpdated> dataUpdateController =
      StreamController<BDKDataUpdated>.broadcast();
  final AccountDao accountDao;

  BalanceDataProvider(
    this.accountDao,
  );

  List<BDKBalanceData> bdkBalanceDataList = [];

  Future<BDKBalanceData> getBDKBalanceDataByWalletAccount(
      WalletModel walletModel, AccountModel accountModel) async {
    Wallet? wallet =
        await WalletManager.loadWalletWithID(walletModel.id!, accountModel.id!);
    return BDKBalanceData(
        walletModel: walletModel, accountModel: accountModel, wallet: wallet);
  }

  @override
  Future<void> clear() async {
    dataUpdateController.close();
  }
}
