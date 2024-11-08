import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/channels/native.view.channel.dart';
import 'package:wallet/managers/features/settings/clear.cache.bloc.dart';
import 'package:wallet/managers/manager.factory.dart';
// import 'package:wallet/managers/proton.wallet.manager.dart';
import 'package:wallet/managers/providers/user.settings.data.provider.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/models/drift/db/app.database.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/settings/settings.coordinator.dart';

abstract class SettingsViewModel extends ViewModel<SettingsCoordinator> {
  SettingsViewModel(super.coordinator, this.clearCacheBloc);

  String errorMessage = "";

  String displayName = "";
  String displayEmail = "";
  String userName = "";
  String logsFolderSize = "";

  late WalletUserSettings? walletUserSettings;
  bool loadedWalletUserSettings = false;
  bool receiveInviterNotification = false;
  bool receiveEmailIntegrationNotification = false;

  void updateReceiveInviterNotification(enable);

  void updateReceiveEmailIntegrationNotification(enable);

  final ClearCacheBloc clearCacheBloc;
  late ValueNotifier<int> stopgapValueNotifier;

  Future<void> clearLogs();
}

class SettingsViewModelImpl extends SettingsViewModel {
  final UserManager userManager;
  final NativeViewChannel nativeViewChannel;
  final UserSettingsDataProvider userSettingsDataProvider;
  final ManagerFactory serviceManager;

  SettingsViewModelImpl(
    super.coordinator,
    super.clearCacheBloc,
    this.userManager,
    this.nativeViewChannel,
    this.userSettingsDataProvider,
    this.serviceManager,
  );

  bool hadLocallogin = false;

  void updateStopGap() {
    userSettingsDataProvider.setCustomStopgap(stopgapValueNotifier.value);
  }

  @override
  Future<void> loadData() async {
    displayName = userManager.userInfo.userDisplayName;
    displayEmail = userManager.userInfo.userMail;
    userName = userManager.userInfo.userName;

    /// init custom stopgap valueNotifier
    final customStopgap = await userSettingsDataProvider.getCustomStopgap();
    stopgapValueNotifier = ValueNotifier(customStopgap);
    stopgapValueNotifier.addListener(updateStopGap);
    loadSettings();

    logsFolderSize = await LoggerService.getLogsSize();

    sinkAddSafe();
  }

  Future<void> loadSettings() async {
    walletUserSettings = await userSettingsDataProvider.getSettings();
    if (walletUserSettings != null) {
      receiveEmailIntegrationNotification =
          walletUserSettings!.receiveEmailIntegrationNotification;
      receiveInviterNotification =
          walletUserSettings!.receiveInviterNotification;
    }
    loadedWalletUserSettings = true;
    sinkAddSafe();
  }

  @override
  Future<void> move(NavID to) async {
    switch (to) {
      case NavID.natvieReportBugs:
        nativeViewChannel.nativeReportBugs(userName, displayEmail);
      case NavID.logs:
        coordinator.showLogs();
      default:
        break;
    }
  }

  @override
  void updateReceiveEmailIntegrationNotification(enable) {
    if (enable != receiveEmailIntegrationNotification) {
      receiveEmailIntegrationNotification = enable;
      userSettingsDataProvider
          .updateReceiveEmailIntegrationNotification(enable);
      sinkAddSafe();
    }
  }

  @override
  void updateReceiveInviterNotification(enable) {
    if (enable != receiveInviterNotification) {
      receiveInviterNotification = enable;
      userSettingsDataProvider.updateReceiveInviterNotification(enable);
      sinkAddSafe();
    }
  }

  @override
  Future<void> clearLogs() async {
    await LoggerService.clearLogs();
    logsFolderSize = await LoggerService.getLogsSize();
    sinkAddSafe();
  }
}
