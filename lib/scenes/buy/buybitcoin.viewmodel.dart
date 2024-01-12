import 'dart:async';
import 'package:wallet/scenes/core/viewmodel.dart';

abstract class BuyBitcoinViewModel extends ViewModel {
  BuyBitcoinViewModel(super.coordinator);
}

class BuyBitcoinViewModelImpl extends BuyBitcoinViewModel {
  BuyBitcoinViewModelImpl(super.coordinator);
  final datasourceChangedStreamController =
      StreamController<BuyBitcoinViewModel>.broadcast();
  @override
  void dispose() {
    datasourceChangedStreamController.close();
  }

  @override
  Future<void> loadData() async {}

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;
}
