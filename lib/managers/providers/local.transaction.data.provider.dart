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
  final String userID;

  LocalTransactionDataProvider(
    this.walletClient,
    this.walletDao,
    this.accountDao,
    this.transactionInfoDao,
    this.userID,
  );

  List<LocalTransactionData> transactionDataList = [];

  Future<List<LocalTransactionData>> _getFromDB() async {
    final List<LocalTransactionData> transactionDataList = [];
    final wallets = await walletDao.findAllByUserID(userID);
    if (wallets.isNotEmpty) {
      for (WalletModel walletModel in wallets) {
        final List<AccountModel> accounts =
            (await accountDao.findAllByWalletID(walletModel.walletID))
                .cast<AccountModel>();
        for (AccountModel accountModel in accounts) {
          final transactions = await transactionInfoDao
              .findAllByServerAccountID(accountModel.accountID);
          final LocalTransactionData localTransactionData =
              LocalTransactionData(
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
    final localTransactionsData = await getLocalTransactionData();
    for (LocalTransactionData localTransactionData in localTransactionsData) {
      if (localTransactionData.accountModel.accountID ==
          accountModel.accountID) {
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
    // TODO(fix): enhance performance
  }

  @override
  Future<void> clear() async {
    dataUpdateController.close();
  }
}
