import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/channels/native.view.channel.dart';
import 'package:wallet/managers/features/settings/clear.cache.bloc.dart';
import 'package:wallet/managers/manager.factory.dart';
import 'package:wallet/managers/providers/unleash.data.provider.dart';
import 'package:wallet/managers/providers/user.settings.data.provider.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/models/drift/db/app.database.dart';
import 'package:wallet/provider/theme.provider.dart';
import 'package:wallet/rust/api/proton_api.dart' as proton_api;
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/proton.accounts/account.deletion.dart';
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
  late ValueNotifier<ThemeMode> themeModeValueNotifier;

  Future<void> clearLogs();

  Future<void> deleteAccount();

  bool isTraceLoggerEnabled();
}

class SettingsViewModelImpl extends SettingsViewModel {
  final UserManager userManager;
  final NativeViewChannel nativeViewChannel;
  final UserSettingsDataProvider userSettingsDataProvider;
  final UnleashDataProvider unleashDataProvider;
  final ManagerFactory serviceManager;

  SettingsViewModelImpl(
    super.coordinator,
    super.clearCacheBloc,
    this.userManager,
    this.nativeViewChannel,
    this.userSettingsDataProvider,
    this.unleashDataProvider,
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

    /// init theme mode valueNotifier
    final themeProvider = Provider.of<ThemeProvider>(
        Coordinator.rootNavigatorKey.currentContext!,
        listen: false);
    final currentThemeMode =
        themeProvider.getThemeMode(themeProvider.themeMode);
    themeModeValueNotifier = ValueNotifier(currentThemeMode);
    themeModeValueNotifier.addListener(updateThemeMode);

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

  void updateThemeMode() {
    final themeProvider = Provider.of<ThemeProvider>(
        Coordinator.rootNavigatorKey.currentContext!,
        listen: false);
    final currentThemeMode =
        themeProvider.getThemeMode(themeProvider.themeMode);
    if (currentThemeMode != themeModeValueNotifier.value) {
      themeProvider.toggleChangeTheme(themeModeValueNotifier.value.name);
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

  @override
  Future<void> deleteAccount() async {
    const clientChild = "web-account-lite";
    final selector = await proton_api.forkSelector(clientChild: clientChild);
    final checkoutUrl =
        "https://account.proton.me/lite?action=delete-account#selector=$selector";
    coordinator.showInBottomSheet(
      AccountDeletionView(checkoutUrl: checkoutUrl),
      enableDrag: false,
    );
  }

  @override
  bool isTraceLoggerEnabled() {
    return unleashDataProvider.isTraceLoggerEnabled();
  }
}
