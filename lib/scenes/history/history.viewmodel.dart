import 'dart:async';
import 'dart:convert';

import 'package:wallet/helper/bdk/helper.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/models/transaction.model.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/debug/bdk.test.dart';

import '../../helper/wallet_manager.dart';
import '../../rust/types.dart';

abstract class HistoryViewModel extends ViewModel {
  HistoryViewModel(super.coordinator, this.walletID, this.accountID);

  int walletID;
  int accountID;

  String selectedTXID = "";

  List<TransactionDetails> history = [];
  List<String> userLabels = [];

  @override
  bool get keepAlive => true;

  bool hasHistory();

  int getAmount(int index);
}

class HistoryViewModelImpl extends HistoryViewModel {
  HistoryViewModelImpl(super.coordinator, super.walletID, super.accountID);

  final datasourceChangedStreamController =
      StreamController<HistoryViewModel>.broadcast();

  final BdkLibrary _lib = BdkLibrary();
  late Wallet _wallet;

  @override
  void dispose() {
    datasourceChangedStreamController.close();
  }

  @override
  Future<void> loadData() async {
    _wallet = await WalletManager.loadWalletWithID(walletID, accountID);
    history = await _lib.getConfirmedTransactions(_wallet);
    history.sort((a, b) {
      return a.confirmationTime!.timestamp > b.confirmationTime!.timestamp
          ? -1
          : 1;
    });
    for (TransactionDetails transactionDetail in history) {
      TransactionModel? transactionModel = await DBHelper.transactionDao!
          .findByExternalTransactionID(utf8.encode(transactionDetail.txid));
      String userLabel =
          transactionModel != null ? utf8.decode(transactionModel.label) : "";
      userLabels.add(userLabel);
    }
    datasourceChangedStreamController.sink.add(this);
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  @override
  bool hasHistory() {
    return history.isEmpty ? false : true;
  }

  @override
  int getAmount(int index) {
    var amount = history[index].received - history[index].sent;
    return amount;
  }
}
