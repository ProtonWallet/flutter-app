import 'dart:async';
import 'package:wallet/constants/app.config.dart';
import 'package:wallet/helper/bdk/helper.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/models/account.dao.impl.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/rust/bdk/types.dart';
import 'package:wallet/scenes/debug/bdk.test.dart';

class BDKWalletData {
  final WalletModel walletModel;
  final AccountModel accountModel;
  final Wallet wallet;

  BDKWalletData({
    required this.walletModel,
    required this.accountModel,
    required this.wallet,
  });
}

class BDKTransactionData {
  final AccountModel accountModel;
  List<TransactionDetails> transactions = [];

  BDKTransactionData({
    required this.accountModel,
    required this.transactions,
  });
}

class BDKTransactionDataProvider implements DataProvider {
  StreamController<BDKDataUpdated> dataUpdateController =
      StreamController<BDKDataUpdated>.broadcast();
  final AccountDao accountDao;

  /// TODO:: maybe use singleton?
  final BdkLibrary _lib = BdkLibrary(coinType: appConfig.coinType);
  Blockchain? blockchain;

  BDKTransactionDataProvider(
    this.accountDao,
  );

  List<BDKTransactionData> bdkTransactionDataList = [];
  Map<String, bool> isWalletSyncing = {};

  Future<void> init(List<WalletModel> wallets) async {
    bdkTransactionDataList.clear();
    for (WalletModel walletModel in wallets) {
      List<AccountModel> accounts =
          (await accountDao.findAllByWalletID(walletModel.id!))
              .cast<AccountModel>();
      for (AccountModel accountModel in accounts) {
        syncWallet(walletModel, accountModel);
        bdkTransactionDataList
            .add(await _getBDKTransactionData(walletModel, accountModel));
      }
    }
  }

  Future<BDKTransactionData> _getBDKTransactionData(
      WalletModel walletModel, AccountModel accountModel) async {
    Wallet? wallet =
        await WalletManager.loadWalletWithID(walletModel.id!, accountModel.id!);
    List<TransactionDetails> transactions = [];
    if (wallet != null) {
      transactions = await _lib.getAllTransactions(wallet);
    }
    return BDKTransactionData(
        accountModel: accountModel, transactions: transactions);
  }

  Future<BDKTransactionData> getBDKTransactionDataByWalletAccount(
      WalletModel walletModel, AccountModel accountModel) async {
    /// TODO:: use cache to enhance performance
    // for (BDKTransactionData bdkTransactionData in bdkTransactionDataList) {
    //   if (bdkTransactionData.accountModel.serverAccountID ==
    //       accountModel.serverAccountID) {
    //     return bdkTransactionData;
    //   }
    // }
    BDKTransactionData bdkTransactionData =
        await _getBDKTransactionData(walletModel, accountModel);
    // bdkTransactionDataList.add(bdkTransactionData);
    return bdkTransactionData;
  }

  bool isSyncing(WalletModel walletModel, AccountModel accountModel) {
    return isWalletSyncing[accountModel.serverAccountID] ?? false;
  }

  Future<void> syncWallet(
      WalletModel walletModel, AccountModel accountModel) async {
    bool isSyncing = isWalletSyncing.containsKey(accountModel.serverAccountID) ? isWalletSyncing[accountModel.serverAccountID]! : false;
    if (isSyncing == false) {
      blockchain ??= await _lib.initializeBlockchain(false);
      isWalletSyncing[accountModel.serverAccountID] = true;
      Wallet? wallet = await WalletManager.loadWalletWithID(
          walletModel.id!, accountModel.id!);
      if (wallet != null) {
        await _lib.syncWallet(blockchain!, wallet);
      }
      isWalletSyncing[accountModel.serverAccountID] = false;
      dataUpdateController.add(BDKDataUpdated());
    }
  }

  @override
  Future<void> clear() async {
    dataUpdateController.close();
  }
}
