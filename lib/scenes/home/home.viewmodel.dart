import 'dart:async';

import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/viewmodel.dart';

abstract class HomeViewModel extends ViewModel {
  HomeViewModel(Coordinator coordinator) : super(coordinator);

  int selectedPage = 0;
  String mnemonicString = 'No Wallet';

  void updateSelected(int index);
  void updateMnemonic(String mnemonic);
}

class HomeViewModelImpl extends HomeViewModel {
  HomeViewModelImpl(Coordinator coordinator) : super(coordinator);

  final datasourceChangedStreamController =
      StreamController<HomeViewModel>.broadcast();
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
}
