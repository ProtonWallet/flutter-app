import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:wallet/generated/bridge_definitions.dart';
import 'package:wallet/helper/currency_helper.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/models/Transaction.model.dart';
import 'package:wallet/models/transaction.dao.impl.dart';
import 'package:wallet/scenes/core/viewmodel.dart';

import '../../helper/bdk/helper.dart';
import '../../helper/wallet_manager.dart';
import '../debug/bdk.test.dart';

abstract class HistoryDetailViewModel extends ViewModel {
  int walletID;
  int accountID;
  String txid;
  String userLabel = "";

  HistoryDetailViewModel(
      super.coordinator, this.walletID, this.accountID, this.txid);

  String strWallet = "";
  String strAccount = "";
  String address = "";
  int submitTimestamp = 0;
  int completeTimestamp = 0;
  double amount = 0.0;
  double notional = 0.0;
  double fee = 0.0;
  bool isSend = false;
  bool initialized = false;
  late TextEditingController memoController;
  late FocusNode memoFocusNode;
}

class HistoryDetailViewModelImpl extends HistoryDetailViewModel {
  HistoryDetailViewModelImpl(
      super.coordinator, super.walletID, super.accountID, super.txid);

  final BdkLibrary _lib = BdkLibrary();
  late Wallet _wallet;
  final datasourceChangedStreamController =
      StreamController<HistoryDetailViewModel>.broadcast();
  late TransactionDaoImpl transactionDaoImpl;

  @override
  void dispose() {
    datasourceChangedStreamController.close();
  }

  @override
  Future<void> loadData() async {
    memoController = TextEditingController();
    memoFocusNode = FocusNode();
    memoFocusNode.addListener(() {
      userFinishMemo();
    });
    transactionDaoImpl = TransactionDaoImpl(await DBHelper.database);
    TransactionModel? transactionModel =
        await transactionDaoImpl.findByExternalTransactionID(utf8.encode(txid));
    userLabel =
        transactionModel != null ? utf8.decode(transactionModel.label) : "";
    memoController.text = userLabel;
    datasourceChangedStreamController.sink.add(this);
    _wallet = await WalletManager.loadWalletWithID(walletID, accountID);
    List<TransactionDetails> history =
        await _lib.getConfirmedTransactions(_wallet);
    history.forEach((transaction) async {
      if (transaction.txid == txid) {
        address = transaction.txid
            .substring(0, 32); // TODO:: use txid to get correct address
        strWallet = await WalletManager.getNameWithID(walletID);
        strAccount = await WalletManager.getAccountLabelWithID(accountID);
        submitTimestamp = transaction.confirmationTime!.timestamp;
        completeTimestamp = transaction.confirmationTime!.timestamp;
        amount = transaction.received.toDouble() - transaction.sent.toDouble();
        fee = transaction.fee!.toDouble();
        notional = CurrencyHelper.sat2usdt(amount).abs();
        isSend = amount < 0;
        datasourceChangedStreamController.sink.add(this);
      }
    });
    initialized = true;
    return;
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  Future<void> userFinishMemo() async {
    if (!memoFocusNode.hasFocus) {
      if (userLabel != memoController.text) {
        userLabel = memoController.text;
        // user finish editing memo, save to local table for data persist
        transactionDaoImpl.insertOrUpdate(
            walletID, utf8.encode(txid), userLabel);
      }
    }
  }
}
