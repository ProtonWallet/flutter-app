import 'dart:async';

import 'package:wallet/helper/extension/stream.controller.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
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
    datasourceChangedStreamController.sinkAddSafe(this);
    return;
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  @override
  Future<void> move(NavID to) async {
    switch (to) {
      case NavID.setupCreate:
        coordinator.showSetupCreate();
        break;
      case NavID.importWallet:
        coordinator.showImportWallet();
        break;
      default:
        break;
    }
  }
}
