import 'dart:async';

import 'package:wallet/helper/wallet_manager.dart';
import 'package:wallet/scenes/core/viewmodel.dart';

abstract class SetupOnboardViewModel extends ViewModel {
  SetupOnboardViewModel(super.coordinator);
  bool hasAccount = false;

  void goHome();
}

class SetupOnboardViewModelImpl extends SetupOnboardViewModel {
  SetupOnboardViewModelImpl(super.coordinator);
  final datasourceChangedStreamController =
      StreamController<SetupOnboardViewModel>.broadcast();
  @override
  void dispose() {
    datasourceChangedStreamController.close();
  }

  @override
  Future<void> loadData() async {
    hasAccount = await WalletManager.hasAccount();
    datasourceChangedStreamController.sink.add(this);
    return;
  }

  @override
  void goHome() {
    // coordinator.move(to, context);
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;
}
