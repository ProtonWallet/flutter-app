import 'package:flutter/material.dart';
import 'package:wallet/constants/env.dart';
import 'package:wallet/managers/api.service.manager.dart';
import 'package:wallet/managers/channels/native.view.channel.dart';
import 'package:wallet/managers/channels/platform.channel.manager.dart';
import 'package:wallet/managers/event.loop.manager.dart';
import 'package:wallet/managers/features/create.wallet.bloc.dart';
import 'package:wallet/managers/features/wallet.balance.bloc.dart';
import 'package:wallet/managers/features/wallet.list.bloc.dart';
import 'package:wallet/managers/features/wallet.transaction.bloc.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/managers/wallet/proton.wallet.manager.dart';
import 'package:wallet/models/native.session.model.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/scenes/backup.v2/backup.coordinator.dart';
import 'package:wallet/scenes/buy/buybitcoin.coordinator.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/debug/websocket.coordinator.dart';
import 'package:wallet/scenes/discover/discover.coordinator.dart';
import 'package:wallet/scenes/history/details.coordinator.dart';
import 'package:wallet/scenes/home.v3/home.view.dart';
import 'package:wallet/scenes/home.v3/home.viewmodel.dart';
import 'package:wallet/scenes/import/import.coordinator.dart';
import 'package:wallet/scenes/receive/receive.coordinator.dart';
import 'package:wallet/scenes/security.setting/security.setting.coordinator.dart';
import 'package:wallet/scenes/send/send.coordinator.dart';
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
    nativeViewChannel.switchToUpgrade(session);
  }

  void showNativeReportBugs() {
    nativeViewChannel.nativeReportBugs();
  }

  void showSend(int walletID, int accountID) {
    var view = SendCoordinator(walletID, accountID).start();
    showInBottomSheet(view);
  }

  void showSetupBackup(int walletID) {
    var view = SetupBackupCoordinator(walletID).start();
    push(view, fullscreenDialog: false);
  }

  void showReceive(
      String serverWalletID, String serverAccountID, bool isWalletView) {
    var view = ReceiveCoordinator(serverWalletID, serverAccountID, isWalletView)
        .start();
    showInBottomSheet(view);
  }

  void showWebSocket() {
    var view = WebSocketCoordinator().start();
    push(view, fullscreenDialog: true);
  }

  void showDiscover() {
    var view = DiscoverCoordinator().start();
    push(view);
  }

  void showBuy() {
    var view = BuyBitcoinCoordinator().start();
    push(view);
  }

  void showSecuritySetting() {
    var view = SecuritySettingCoordinator().start();
    push(view);
  }

  void showHistoryDetails(
      int walletID, int accountID, String txID, FiatCurrency userFiatCurrency) {
    var view =
        HistoryDetailCoordinator(walletID, accountID, txID, userFiatCurrency)
            .start();
    showInBottomSheet(view);
  }

  void showTwoFactorAuthSetup() {
    var view = TwoFactorAuthCoordinator().start();
    push(view);
  }

  void showTwoFactorAuthDisable() {
    var view = TwoFactorAuthDisableCoordinator().start();
    push(view);
  }

  void logout() {
    serviceManager.logout();
    var view = WelcomeCoordinator(nativeViewChannel: nativeViewChannel).start();
    pushReplacement(view);
  }

  void showImportWallet(String preInputName) {
    var view = ImportCoordinator(preInputName).start();
    showInBottomSheet(view);
  }

  @override
  ViewBase<ViewModel> start() {
    var userManager = serviceManager.get<UserManager>();
    var event = serviceManager.get<EventLoop>();
    var wallet = serviceManager.get<ProtonWalletManager>();
    var apiServiceManager = serviceManager.get<ProtonApiServiceManager>();
    var dataProviderManager = serviceManager.get<DataProviderManager>();
    var channelManager = serviceManager.get<PlatformChannelManager>();

    var walletBloc = WalletListBloc(
      dataProviderManager.walletDataProvider,
      dataProviderManager.walletPassphraseProvider,
      dataProviderManager.walletKeysProvider,
      userManager,
      dataProviderManager.userSettingsDataProvider,
      dataProviderManager.bdkTransactionDataProvider,
    );

    var walletTransactionBloc = WalletTransactionBloc(
      userManager,
      dataProviderManager.localTransactionDataProvider,
      dataProviderManager.bdkTransactionDataProvider,
      dataProviderManager.serverTransactionDataProvider,
      dataProviderManager.addressKeyProvider,
      dataProviderManager.walletKeysProvider,
      dataProviderManager.localBitcoinAddressDataProvider,
      dataProviderManager.walletDataProvider,
    );

    var walletBalanceBloc = WalletBalanceBloc(
      dataProviderManager.bdkTransactionDataProvider,
      dataProviderManager.balanceDataProvider,
      dataProviderManager.walletDataProvider,
      dataProviderManager.serverTransactionDataProvider,
    );

    var createWalletBloc = CreateWalletBloc(
      userManager,
      dataProviderManager.walletDataProvider,
      dataProviderManager.walletKeysProvider,
      dataProviderManager.walletPassphraseProvider,
    );

    var viewModel = HomeViewModelImpl(
      this,
      userManager,
      event,
      wallet,
      apiServiceManager,
      walletBloc,
      walletTransactionBloc,
      walletBalanceBloc,
      dataProviderManager,
      createWalletBloc,

      ///
      channelManager,
    );
    widget = HomeView(
      viewModel,
    );
    return widget;
  }
}
