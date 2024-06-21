import 'dart:async';
import 'dart:convert';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/models/account.dao.impl.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/exchangerate.dao.impl.dart';
import 'package:wallet/models/exchangerate.model.dart';
import 'package:wallet/models/transaction.dao.impl.dart';
import 'package:wallet/models/transaction.model.dart';
import 'package:wallet/models/wallet.dao.impl.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/rust/api/api_service/wallet_client.dart';
import 'package:wallet/rust/proton_api/wallet.dart';

class ServerTransactionData {
  final AccountModel accountModel;
  List<TransactionModel> transactions = [];

  ServerTransactionData({
    required this.accountModel,
    required this.transactions,
  });
}

class ServerTransactionDataProvider implements DataProvider {
  @override
  StreamController<DataUpdated> dataUpdateController =
      StreamController<DataUpdated>.broadcast();
  final WalletClient walletClient;
  final WalletDao walletDao;
  final AccountDao accountDao;
  final ExchangeRateDao exchangeRateDao;
  final TransactionDao transactionDao;

  ServerTransactionDataProvider(
    this.walletClient,
    this.walletDao,
    this.accountDao,
    this.exchangeRateDao,
    this.transactionDao,
  );

  List<ServerTransactionData> serverTransactionDataList = [];
  bool initialized = false;

  Future<List<ServerTransactionData>> _getFromDB() async {
    List<ServerTransactionData> transactionDataList = [];
    var wallets = (await walletDao.findAll())
        .cast<WalletModel>(); // TODO:: search by UserID

    if (wallets.isNotEmpty) {
      for (WalletModel walletModel in wallets) {
        List<AccountModel> accounts =
            (await accountDao.findAllByWalletID(walletModel.id!))
                .cast<AccountModel>();
        for (AccountModel accountModel in accounts) {
          List<TransactionModel> transactions = await transactionDao
              .findAllByServerAccountID(accountModel.serverAccountID);
          ServerTransactionData serverTransactionData = ServerTransactionData(
              accountModel: accountModel, transactions: transactions);
          transactionDataList.add(serverTransactionData);
        }
      }
      return transactionDataList;
    }
    return [];
  }

  Future<ServerTransactionData> getServerTransactionDataByWalletAccount(
      WalletModel walletModel, AccountModel accountModel) async {
    List<ServerTransactionData> serverTransactionsData =
        await getServerTransactionData();
    for (ServerTransactionData serverTransactionData
        in serverTransactionsData) {
      if (serverTransactionData.accountModel.serverAccountID ==
          accountModel.serverAccountID) {
        return serverTransactionData;
      }
    }
    // no server transaction found for this account, return empty transactions array
    return ServerTransactionData(accountModel: accountModel, transactions: []);
  }

  Future<List<ServerTransactionData>> getServerTransactionData() async {
    if (initialized) {
      return serverTransactionDataList;
    }
    // fetch from server
    List<WalletModel> wallets = (await walletDao.findAll()).cast<WalletModel>();

    for (WalletModel walletModel in wallets) {
      await handleWalletTransactions(walletModel);
    }
    serverTransactionDataList = await _getFromDB();
    initialized = true;
    return serverTransactionDataList;
  }

  Future<void> handleWalletTransactions(WalletModel walletModel) async {
    List<WalletTransaction> walletTransactions = await walletClient
        .getWalletTransactions(walletId: walletModel.serverWalletID);

    for (WalletTransaction walletTransaction in walletTransactions) {
      await handleWalletTransaction(walletModel, walletTransaction);
    }
  }

  Future<void> handleWalletTransaction(
      WalletModel walletModel, WalletTransaction walletTransaction,
      {bool notifyDataUpdate = false}) async {
    DateTime now = DateTime.now();

    String exchangeRateID = "";
    if (walletTransaction.exchangeRate != null) {
      exchangeRateID = walletTransaction.exchangeRate!.id;
      ExchangeRateModel exchangeRateModel = ExchangeRateModel(
        id: null,
        serverID: walletTransaction.exchangeRate!.id,
        bitcoinUnit:
            walletTransaction.exchangeRate!.bitcoinUnit.name.toUpperCase(),
        fiatCurrency:
            walletTransaction.exchangeRate!.fiatCurrency.name.toUpperCase(),
        sign: "",
        // TODO:: add sign once apiClient update for it
        exchangeRateTime: walletTransaction.exchangeRate!.exchangeRateTime,
        exchangeRate: walletTransaction.exchangeRate!.exchangeRate,
        cents: walletTransaction.exchangeRate!.cents,
      );
      await exchangeRateDao.insert(exchangeRateModel);
    }

    TransactionModel transactionModel = TransactionModel(
        id: null,
        walletID: walletModel.id!,
        label: utf8.encode(walletTransaction.label ?? ""),
        externalTransactionID: utf8.encode(""),

        /// deprecated
        createTime: now.millisecondsSinceEpoch ~/ 1000,
        modifyTime: now.millisecondsSinceEpoch ~/ 1000,
        hashedTransactionID:
            utf8.encode(walletTransaction.hashedTransactionId ?? ""),
        transactionID: walletTransaction.transactionId,
        serverID: walletTransaction.id,
        transactionTime: walletTransaction.transactionTime,
        exchangeRateID: exchangeRateID,
        serverWalletID: walletTransaction.walletId,
        serverAccountID: walletTransaction.walletAccountId!,
        sender: walletTransaction.sender,
        tolist: walletTransaction.tolist,
        subject: walletTransaction.subject,
        body: walletTransaction.body);
    await insertOrUpdate(
      transactionModel,
      notifyDataUpdate: notifyDataUpdate,
    );
  }

  Future<void> insertOrUpdate(TransactionModel transactionModel,
      {bool notifyDataUpdate = false}) async {
    await transactionDao.insertOrUpdate(transactionModel);
    if (notifyDataUpdate){
      dataUpdateController.add(DataUpdated(""));
    }
  }

  @override
  Future<void> clear() async {
    dataUpdateController.close();
  }
}
