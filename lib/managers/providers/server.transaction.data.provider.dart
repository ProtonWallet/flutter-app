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

/// define class for server walletTransaction in wallet account level
class ServerTransactionData {
  final AccountModel accountModel;
  List<TransactionModel> transactions = [];

  ServerTransactionData({
    required this.accountModel,
    required this.transactions,
  });
}

class ServerTransactionDataProvider extends DataProvider {
  /// stream
  StreamController<DataUpdated> dataUpdateController =
      StreamController<DataUpdated>.broadcast();

  /// api client
  final WalletClient walletClient;

  /// db dao
  final WalletDao walletDao;
  final AccountDao accountDao;
  final ExchangeRateDao exchangeRateDao;
  final TransactionDao transactionDao;

  /// user id
  final String userID;

  ServerTransactionDataProvider(
    this.walletClient,
    this.walletDao,
    this.accountDao,
    this.exchangeRateDao,
    this.transactionDao,
    this.userID,
  );

  /// memory caches
  List<ServerTransactionData> serverTransactionDataList = [];

  /// provider status flag
  bool initialized = false;

  Future<List<ServerTransactionData>> _getFromDB() async {
    final List<ServerTransactionData> transactionDataList = [];

    /// get wallets from db
    final wallets = await walletDao.findAllByUserID(userID);
    if (wallets.isNotEmpty) {
      for (WalletModel walletModel in wallets) {
        /// get accounts from db for given wallet
        final accounts =
            await accountDao.findAllByWalletID(walletModel.walletID);
        for (AccountModel accountModel in accounts) {
          /// get walletTransactions from db for given account
          final transactions = await transactionDao.findAllByServerAccountID(
            accountModel.accountID,
          );
          final serverTransactionData = ServerTransactionData(
            accountModel: accountModel,
            transactions: transactions,
          );

          /// update the cache
          transactionDataList.add(serverTransactionData);
        }
      }
      return transactionDataList;
    }
    return [];
  }

  Future<ServerTransactionData> getServerTransactionDataByWalletAccount(
    WalletModel walletModel,
    AccountModel accountModel,
  ) async {
    return ServerTransactionData(
      accountModel: accountModel,
      transactions: await getTransByAccountID(
        walletModel.walletID,
        accountModel.accountID,
      ),
    );
  }

  Future<List<TransactionModel>> getTransByAccountID(
    String walletID,
    String accountID,
  ) async {
    /// load from caches
    List<TransactionModel> transactions =
        await transactionDao.findAllByServerAccountID(
      accountID,
    );

    /// fetch from server when no local cache
    if (transactions.isEmpty) {
      await fetchTransactions(
        walletID,
        accountID,
        isInitializeProcess: true,
      );

      /// load from caches
      transactions = await transactionDao.findAllByServerAccountID(
        accountID,
      );
    }
    return transactions;
  }

  Future<List<ServerTransactionData>> getServerTransactionData() async {
    if (initialized) {
      return serverTransactionDataList;
    }

    /// fetch from server
    final wallets = await walletDao.findAllByUserID(userID);
    for (WalletModel walletModel in wallets) {
      await fetchTransactions(
        walletModel.walletID,
        null,
        isInitializeProcess: true,
      );
    }
    serverTransactionDataList = await _getFromDB();
    initialized = true;
    return serverTransactionDataList;
  }

  Future<void> fetchTransactions(
    String walletID,
    String? accountID, {
    bool isInitializeProcess = false,
  }) async {
    /// fetch from server
    final walletTransactions = await walletClient.getWalletTransactions(
      walletId: walletID,
      walletAccountId: accountID,
    );

    /// insert or update data in db
    for (WalletTransaction walletTransaction in walletTransactions) {
      await handleWalletTransaction(
        walletTransaction,
        isInitializeProcess: isInitializeProcess,
      );
    }
  }

  Future<void> handleWalletTransaction(
    WalletTransaction walletTransaction, {
    bool notifyDataUpdate = false,
    bool isInitializeProcess = false,
  }) async {
    final DateTime now = DateTime.now();

    String exchangeRateID = "";
    if (walletTransaction.exchangeRate != null) {
      exchangeRateID = walletTransaction.exchangeRate!.id;
      final ExchangeRateModel exchangeRateModel = ExchangeRateModel(
        id: null,
        serverID: exchangeRateID,
        bitcoinUnit:
            walletTransaction.exchangeRate!.bitcoinUnit.name.toUpperCase(),
        fiatCurrency:
            walletTransaction.exchangeRate!.fiatCurrency.name.toUpperCase(),
        sign: "",
        exchangeRateTime: walletTransaction.exchangeRate!.exchangeRateTime,
        exchangeRate: walletTransaction.exchangeRate!.exchangeRate.toInt(),
        cents: walletTransaction.exchangeRate!.cents.toInt(),
      );
      await exchangeRateDao.insert(exchangeRateModel);
    }

    final TransactionModel transactionModel = TransactionModel(
      id: -1,
      type: walletTransaction.type?.index ?? TransactionType.unsupported.index,
      label: utf8.encode(walletTransaction.label ?? ""),
      externalTransactionID: utf8.encode(""),
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
      body: walletTransaction.body,
      isSuspicious: walletTransaction.isSuspicious,
      isPrivate: walletTransaction.isPrivate,
      isAnonymous: walletTransaction.isAnonymous,
    );
    await insertOrUpdate(
      transactionModel,
      notifyDataUpdate: notifyDataUpdate,
      isInitializeProcess: isInitializeProcess,
    );
  }

  Future<void> insertOrUpdate(
    TransactionModel transactionModel, {
    bool notifyDataUpdate = false,
    bool isInitializeProcess = false,
    UpdateType? updateType,
  }) async {
    final TransactionModel? transactionModelInDB =
        await transactionDao.findByServerID(transactionModel.serverID);
    final bool transactionModelExists = transactionModelInDB != null;
    if (transactionModelInDB != null) {
      /// need to update id since the update function is based on auto increase id
      transactionModel.id = transactionModelInDB.id;
    }
    await transactionDao.insertOrUpdate(transactionModel);

    /// refresh cache
    if (!isInitializeProcess) {
      /// only need to update cached serverTransactionDataList after initialized
      serverTransactionDataList = await _getFromDB();
    }
    if (notifyDataUpdate) {
      if (updateType != null) {
        dataUpdateController.add(DataUpdated(updateType));
      } else {
        if (transactionModelExists) {
          dataUpdateController.add(DataUpdated(UpdateType.updated));
        } else {
          dataUpdateController.add(DataUpdated(UpdateType.inserted));
        }
      }
    }
  }

  Future<void> reloadAccountTransactions(
    String walletID,
    String accountID,
  ) async {
    /// fetch from server
    await fetchTransactions(
      walletID,
      accountID,
      isInitializeProcess: true,
    );
    serverTransactionDataList = await _getFromDB();
  }

  @override
  Future<void> clear() async {
    dataUpdateController.close();
  }

  Future<void> reset(String walletId) async {
    serverTransactionDataList = [];
    await fetchTransactions(walletId, null, isInitializeProcess: true);
  }

  @override
  Future<void> reload() async {}
}
