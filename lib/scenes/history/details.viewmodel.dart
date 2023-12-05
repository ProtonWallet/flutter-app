import 'dart:async';

import 'package:wallet/generated/bridge_definitions.dart';
import 'package:wallet/helper/bdk/mnemonic.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/viewmodel.dart';

abstract class HistoryDetailViewModel extends ViewModel {
  HistoryDetailViewModel(Coordinator coordinator) : super(coordinator);

  int selectedPage = 0;
  String mnemonicString = 'No Wallet';
  List<String> history = [];

  void updateSelected(int index);
  void updateMnemonic(String mnemonic);

  Future<void> updateStringValue();

  bool hasHistory();

  ///debug functions
  void buildHistory();
}

class HistoryDetailViewModelImpl extends HistoryDetailViewModel {
  HistoryDetailViewModelImpl(Coordinator coordinator) : super(coordinator);

  final datasourceChangedStreamController =
      StreamController<HistoryDetailViewModel>.broadcast();
  final selectedSectionChangedController = StreamController<int>.broadcast();

  @override
  void dispose() {
    datasourceChangedStreamController.close();
    selectedSectionChangedController.close();
  }

  @override
  Future<void> loadData() async {
    return;
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
        history.add("Item {i}");
      }
    }

    datasourceChangedStreamController.sink.add(this);
  }
}
