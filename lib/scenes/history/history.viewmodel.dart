import 'dart:async';

import 'package:wallet/generated/bridge_definitions.dart';
import 'package:wallet/helper/bdk/helper.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/debug/bdk.test.dart';

abstract class HistoryViewModel extends ViewModel {
  HistoryViewModel(super.coordinator);

  int selectedPage = 0;
  String mnemonicString = 'No Wallet';
  List<TransactionDetails> history = [];

  void updateSelected(int index);
  void updateMnemonic(String mnemonic);

  Future<void> updateStringValue();

  @override
  bool get keepAlive => true;

  bool hasHistory();

  ///debug functions
  void buildHistory();

  int getAmount(int index);
}

class HistoryViewModelImpl extends HistoryViewModel {
  HistoryViewModelImpl(super.coordinator);

  final datasourceChangedStreamController =
      StreamController<HistoryViewModel>.broadcast();
  final selectedSectionChangedController = StreamController<int>.broadcast();

  final BdkLibrary _lib = BdkLibrary();
  late Wallet _wallet;

  @override
  void dispose() {
    datasourceChangedStreamController.close();
    selectedSectionChangedController.close();
  }

  @override
  Future<void> loadData() async {
    final aliceMnemonic = await Mnemonic.fromString(
        'certain sense kiss guide crumble hint transfer crime much stereo warm coral');
    final aliceDescriptor = await _lib.createDescriptor(aliceMnemonic);
    _wallet = await _lib.restoreWallet(aliceDescriptor);

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
  void updateSelected(int index) {
    selectedPage = index;
    datasourceChangedStreamController.sink.add(this);
  }

  @override
  void updateMnemonic(String mnemonic) {
    mnemonicString = mnemonic;
    datasourceChangedStreamController.sink.add(this);
  }

  @override
  Future<void> updateStringValue() async {
    var mnemonic = await Mnemonic.create(WordCount.Words12);
    logger.d(mnemonic.asString());
    updateMnemonic(mnemonic.asString());
  }

  @override
  bool hasHistory() {
    return history.isEmpty ? false : true;
  }

  @override
  void buildHistory() {
    if (hasHistory()) {
      history.clear();
    } else {
      for (int i = 0; i < 100; i++) {
        // history.add("Item {i}");
      }
    }

    datasourceChangedStreamController.sink.add(this);
  }

  @override
  int getAmount(int index) {
    var amount = history[index].received - history[index].sent;
    return amount;
  }
}
