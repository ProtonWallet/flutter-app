import 'dart:async';

import 'package:wallet/helper/wallet_manager.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/setup/onboard.coordinator.dart';

abstract class SetupOnboardViewModel
    extends ViewModel<SetupOnbaordCoordinator> {
  SetupOnboardViewModel(super.coordinator);
  bool hasAccount = false;
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
    hasAccount = await WalletManager.hasWallet();
    datasourceChangedStreamController.sink.add(this);
    return;
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  @override
  void move(NavigationIdentifier to) {
    switch (to) {
      case ViewIdentifiers.setupCreate:
        coordinator.showSetupCreate();
        break;
      case ViewIdentifiers.importWallet:
        coordinator.showImportWallet();
        break;
    }
  }
}
