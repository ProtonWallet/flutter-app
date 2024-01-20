import 'dart:async';

// import 'package:wallet/generated/bridge_definitions.dart';
import 'package:wallet/helper/bdk/helper.dart';
import 'package:wallet/rust/types.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/debug/bdk.test.dart';

import '../../helper/wallet_manager.dart';

abstract class HistoryViewModel extends ViewModel {
  HistoryViewModel(super.coordinator, this.walletID, this.accountID);

  int walletID;
  int accountID;

  String selectedTXID = "";

  List<TransactionDetails> history = [];

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
