import 'dart:async';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/models/account.dao.impl.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/transaction.info.dao.impl.dart';
import 'package:wallet/models/transaction.info.model.dart';
import 'package:wallet/models/wallet.dao.impl.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/rust/api/api_service/wallet_client.dart';

class LocalTransactionData {
  final AccountModel accountModel;
  List<TransactionInfoModel> transactions = [];

  LocalTransactionData({
    required this.accountModel,
    required this.transactions,
  });
}

class LocalTransactionDataProvider extends DataProvider {
  StreamController<DataUpdated> dataUpdateController =
      StreamController<DataUpdated>.broadcast();
  final WalletClient walletClient;
  final WalletDao walletDao;
  final AccountDao accountDao;
  final TransactionInfoDao transactionInfoDao;

  LocalTransactionDataProvider(
    this.walletClient,
    this.walletDao,
    this.accountDao,
    this.transactionInfoDao,
  );

  List<LocalTransactionData> transactionDataList = [];

  Future<List<LocalTransactionData>> _getFromDB() async {
    List<LocalTransactionData> transactionDataList = [];
    var wallets = (await walletDao.findAll())
        .cast<WalletModel>(); // TODO:: search by UserID

    if (wallets.isNotEmpty) {
      for (WalletModel walletModel in wallets) {
        List<AccountModel> accounts =
            (await accountDao.findAllByWalletID(walletModel.id!))
                .cast<AccountModel>();
        for (AccountModel accountModel in accounts) {
          List<TransactionInfoModel> transactions = await transactionInfoDao
              .findAllByServerAccountID(accountModel.serverAccountID);
          LocalTransactionData localTransactionData = LocalTransactionData(
              accountModel: accountModel, transactions: transactions);
          transactionDataList.add(localTransactionData);
        }
      }
      return transactionDataList;
    }
    return [];
  }

  Future<LocalTransactionData> getLocalTransactionDataByWalletAccount(
      WalletModel walletModel, AccountModel accountModel) async {
    List<LocalTransactionData> localTransactionsData =
        await getLocalTransactionData();
    for (LocalTransactionData localTransactionData in localTransactionsData) {
      if (localTransactionData.accountModel.serverAccountID ==
          accountModel.serverAccountID) {
        return localTransactionData;
      }
    }
    // no local transaction found for this account, return empty transactions array
    return LocalTransactionData(accountModel: accountModel, transactions: []);
  }

  Future<List<LocalTransactionData>> getLocalTransactionData() async {
    if (transactionDataList.isNotEmpty) {
      return transactionDataList;
    }
    transactionDataList = await _getFromDB();
    return transactionDataList;
  }

  Future<void> insert(TransactionInfoModel transactionInfoModel) async {
    await transactionInfoDao.insert(transactionInfoModel);
    transactionDataList = await _getFromDB();
    // dataUpdateController.add(DataUpdated("Local transaction data update"));
    // /// TODO:: enhance performance
  }

  @override
  Future<void> clear() async {
    dataUpdateController.close();
  }
}
