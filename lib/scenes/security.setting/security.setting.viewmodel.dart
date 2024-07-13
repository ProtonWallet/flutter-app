import 'dart:async';
import 'package:wallet/helper/extension/stream.controller.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/security.setting/security.setting.coordinator.dart';

abstract class SecuritySettingViewModel
    extends ViewModel<SecuritySettingCoordinator> {
  SecuritySettingViewModel(super.coordinator);
}

class SecuritySettingViewModelImpl extends SecuritySettingViewModel {
  SecuritySettingViewModelImpl(super.coordinator);
  final datasourceChangedStreamController =
      StreamController<SecuritySettingViewModel>.broadcast();
  @override
  void dispose() {
    datasourceChangedStreamController.close();
  }

  @override
  Future<void> loadData() async {
    datasourceChangedStreamController.sinkAddSafe(this);
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  @override
  Future<void> move(NavID to) async {
    switch (to) {
      case NavID.twoFactorAuthSetup:
        coordinator.showTwoFactorAuthSetup();
      case NavID.twoFactorAuthDisable:
        coordinator.showTwoFactorAuthDisable();
      default:
        break;
    }
  }
}
