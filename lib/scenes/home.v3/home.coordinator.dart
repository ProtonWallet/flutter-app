import 'package:flutter/material.dart';
import 'package:wallet/constants/env.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/managers/api.service.manager.dart';
import 'package:wallet/managers/app.state.manager.dart';
import 'package:wallet/managers/channels/native.view.channel.dart';
import 'package:wallet/managers/channels/platform.channel.manager.dart';
import 'package:wallet/managers/event.loop.manager.dart';
import 'package:wallet/managers/features/create.wallet.bloc.dart';
import 'package:wallet/managers/features/delete.wallet.bloc.dart';
import 'package:wallet/managers/features/wallet.balance.bloc.dart';
import 'package:wallet/managers/features/wallet.list.bloc.dart';
import 'package:wallet/managers/features/wallet.transaction.bloc.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/models/native.session.model.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/scenes/backup.seed/backup.coordinator.dart';
import 'package:wallet/scenes/buy/buybitcoin.coordinator.dart';
import 'package:wallet/scenes/buy/buybitcoin.instruction.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/debug/websocket.coordinator.dart';
import 'package:wallet/scenes/discover/discover.coordinator.dart';
import 'package:wallet/scenes/history/details.coordinator.dart';
import 'package:wallet/scenes/home.v3/home.view.dart';
import 'package:wallet/scenes/home.v3/home.viewmodel.dart';
import 'package:wallet/scenes/import/import.coordinator.dart';
import 'package:wallet/scenes/lock/lock.overlay.coordinator.dart';
import 'package:wallet/scenes/receive/receive.coordinator.dart';
import 'package:wallet/scenes/recovery/recovery.coordinator.dart';
import 'package:wallet/scenes/security.setting/security.setting.coordinator.dart';
import 'package:wallet/scenes/send/send.coordinator.dart';
import 'package:wallet/scenes/settings/settings.coordinator.dart';
import 'package:wallet/scenes/two.factor.auth.disable/two.factor.auth.disable.coordinator.dart';
import 'package:wallet/scenes/two.factor.auth/two.factor.auth.coordinator.dart';
import 'package:wallet/scenes/welcome/welcome.coordinator.dart';

class HomeCoordinator extends Coordinator {
  late ViewBase widget;
  final NativeViewChannel nativeViewChannel;
  ApiEnv apiEnv;

  HomeCoordinator(this.apiEnv, this.nativeViewChannel) {
    Coordinator.nestedNavigatorKey ??=
        GlobalKey<NavigatorState>(debugLabel: "HomeNestedNavigatorKey");
  }

  @override
  void end() {
    Coordinator.nestedNavigatorKey = null;
  }

  void showNativeUpgrade(FlutterSession session) {
    // TODO(fix): uncomment this later
    // nativeViewChannel.switchToUpgrade(session);
  }

  void showNativeReportBugs() {
    // nativeViewChannel.nativeReportBugs();
  }

  void showRecovery() {
    final view = RecoveryCoordinator().start();
    showInBottomSheet(view);
  }

  void showSettings() {
    final view = SettingsCoordinator().start();
    showInBottomSheet(view);
  }

  void showSend(String walletID, String accountID) {
    final view =
        SendCoordinator(nativeViewChannel, walletID, accountID).start();
    showInBottomSheet(
      view,
      backgroundColor: ProtonColors.white,
    );
  }

  void showSetupBackup(String walletID) {
    final view = SetupBackupCoordinator(walletID).start();
    showInBottomSheet(
      view,
      backgroundColor: ProtonColors.white,
    );
  }

  void showReceive(
    String serverWalletID,
    String serverAccountID, {
    required bool isWalletView,
  }) {
    final view = ReceiveCoordinator(
      serverWalletID,
      serverAccountID,
      isWalletView: isWalletView,
    ).start();
    showInBottomSheet(view);
  }

  void showWebSocket() {
    final view = WebSocketCoordinator().start();
    push(view, fullscreenDialog: true);
  }

  void showDiscover() {
    final view = DiscoverCoordinator().start();
    showInBottomSheet(view);
  }

  void showBuy(String walletID, String accountID) {
    final instructionView = BuyBitcoinInstruction(
      onConfirm: () {
        final view = BuyBitcoinCoordinator(walletID, accountID).start();
        showInBottomSheet(
          view,
        );
      },
    );
    showInBottomSheet(instructionView);
  }

  void showSecuritySetting() {
    final view = SecuritySettingCoordinator().start();
    showInBottomSheet(view);
  }

  void showHistoryDetails(
    String walletID,
    String accountID,
    String txID,
    FiatCurrency userFiatCurrency,
  ) {
    final view = HistoryDetailCoordinator(
      walletID,
      accountID,
      txID,
      userFiatCurrency,
    ).start();
    showInBottomSheet(
      view,
      backgroundColor: ProtonColors.white,
    );
  }

  void showTwoFactorAuthSetup() {
    final view = TwoFactorAuthCoordinator().start();
    push(view);
  }

  void showTwoFactorAuthDisable() {
    final view = TwoFactorAuthDisableCoordinator().start();
    push(view);
  }

  void logout() {
    serviceManager.logout();
    final view =
        WelcomeCoordinator(nativeViewChannel: nativeViewChannel).start();
    pushReplacementRemoveAll(view);
  }

  void showImportWallet(String preInputName) {
    final view = ImportCoordinator(preInputName).start();
    showInBottomSheet(view);
  }

  @override
  ViewBase<ViewModel> start() {
    final userManager = serviceManager.get<UserManager>();
    final event = serviceManager.get<EventLoop>();
    final apiServiceManager = serviceManager.get<ProtonApiServiceManager>();
    final dataProviderManager = serviceManager.get<DataProviderManager>();
    final channelManager = serviceManager.get<PlatformChannelManager>();
    final appStateManager = serviceManager.get<AppStateManager>();

    /// build wallet list feature bloc
    final walletBloc = WalletListBloc(
      dataProviderManager.walletDataProvider,
      dataProviderManager.walletPassphraseProvider,
      dataProviderManager.walletKeysProvider,
      userManager,
      dataProviderManager.userSettingsDataProvider,
      dataProviderManager.bdkTransactionDataProvider,
      appStateManager,
    );

    /// build wallet transaction feature bloc
    final walletTransactionBloc = WalletTransactionBloc(
      userManager,
      dataProviderManager.bdkTransactionDataProvider,
      dataProviderManager.serverTransactionDataProvider,
      dataProviderManager.addressKeyProvider,
      dataProviderManager.walletKeysProvider,
      dataProviderManager.localBitcoinAddressDataProvider,
      dataProviderManager.walletDataProvider,
      dataProviderManager.userSettingsDataProvider,
    );

    /// build wallet balance feature bloc
    final walletBalanceBloc = WalletBalanceBloc(
      dataProviderManager.bdkTransactionDataProvider,
      dataProviderManager.balanceDataProvider,
      dataProviderManager.walletDataProvider,
      dataProviderManager.serverTransactionDataProvider,
    );

    /// build create wallet feature bloc
    final createWalletBloc = CreateWalletBloc(
      userManager,
      dataProviderManager.walletDataProvider,
      dataProviderManager.walletKeysProvider,
      dataProviderManager.walletPassphraseProvider,
    );

    final deleteWalletBloc = DeleteWalletBloc(
        dataProviderManager.walletDataProvider,
        apiServiceManager.getWalletClient(),
        apiServiceManager.getProtonUsersApiClient());

    /// build locker overlay view
    final overlayView = LockCoordinator().start();

    final viewModel = HomeViewModelImpl(
      this,
      walletBloc,
      walletTransactionBloc,
      walletBalanceBloc,
      dataProviderManager,
      createWalletBloc,
      deleteWalletBloc,
      userManager,
      event,
      apiServiceManager,

      ///
      channelManager,
      appStateManager,
    );
    widget = HomeView(
      viewModel,
      locker: overlayView,
    );
    return widget;
  }
}
