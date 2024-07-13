import 'dart:async';

import 'package:wallet/managers/channels/native.view.channel.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/settings/settings.coordinator.dart';

abstract class SettingsViewModel extends ViewModel<SettingsCoordinator> {
  SettingsViewModel(super.coordinator);

  String errorMessage = "";

  String displayName = "";
  String displayEmail = "";
}

class SettingsViewModelImpl extends SettingsViewModel {
  final UserManager userManager;
  final NativeViewChannel nativeViewChannel;

  SettingsViewModelImpl(
    super.coordinator,
    this.userManager,
    this.nativeViewChannel,
  );

  bool hadLocallogin = false;
  final datasourceChangedStreamController =
      StreamController<SettingsViewModel>.broadcast();

  @override
  void dispose() {
    datasourceChangedStreamController.close();
  }

  @override
  Future<void> loadData() async {
    displayName = userManager.userInfo.userDisplayName;
    displayEmail = userManager.userInfo.userMail;

    datasourceChangedStreamController.add(this);
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  @override
  Future<void> move(NavID to) async {
    switch (to) {
      case NavID.natvieReportBugs:
        nativeViewChannel.nativeReportBugs();
      case NavID.logs:
        coordinator.showLogs();
      default:
        break;
    }
  }
}
