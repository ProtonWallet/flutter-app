import 'dart:async';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/security-setting/security.setting.coordinator.dart';

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
    datasourceChangedStreamController.sink.add(this);
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  @override
  void move(NavigationIdentifier to) {
    switch (to) {
      case ViewIdentifiers.twoFactorAuthSetup:
        coordinator.showTwoFactorAuthSetup();
        break;
      case ViewIdentifiers.twoFactorAuthDisable:
        coordinator.showTwoFactorAuthDisable();
        break;
    }
  }
}