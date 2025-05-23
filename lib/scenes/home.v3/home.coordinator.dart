import 'package:flutter/material.dart';
import 'package:wallet/constants/env.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/managers/api.service.manager.dart';
import 'package:wallet/managers/app.state.manager.dart';
import 'package:wallet/managers/channels/native.view.channel.dart';
import 'package:wallet/managers/channels/platform.channel.manager.dart';
import 'package:wallet/managers/event.loop.manager.dart';
import 'package:wallet/managers/features/wallet.balance/wallet.balance.bloc.dart';
import 'package:wallet/managers/features/wallet.list/wallet.list.bloc.dart';
import 'package:wallet/managers/features/wallet.list/wallet.list.bloc.model.dart';
import 'package:wallet/managers/features/wallet.trans/wallet.transaction.bloc.dart';
import 'package:wallet/managers/features/wallet/create.wallet.bloc.dart';
import 'package:wallet/managers/features/wallet/delete.wallet.bloc.dart';
import 'package:wallet/managers/features/wallet/wallet.name.bloc.dart';
import 'package:wallet/managers/preferences/preferences.manager.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/models/native.session.model.dart';
import 'package:wallet/rust/api/bdk_wallet/transaction_details.dart';
import 'package:wallet/scenes/backup.seed/backup.coordinator.dart';
import 'package:wallet/scenes/buy/buybitcoin.coordinator.dart';
import 'package:wallet/scenes/buy/buybitcoin.instruction.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/discover/discover.coordinator.dart';
import 'package:wallet/scenes/history/details.coordinator.dart';
import 'package:wallet/scenes/home.v3/home.view.dart';
import 'package:wallet/scenes/home.v3/home.viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/accept.terms.condition/accept.terms.condition.coordinator.dart';
import 'package:wallet/scenes/home.v3/sub.views/add.wallet.account/add.wallet.account.coordinator.dart';
import 'package:wallet/scenes/home.v3/sub.views/backup.your.proton/backup.your.proton.coordinator.dart';
import 'package:wallet/scenes/home.v3/sub.views/backup.your.wallet/backup.your.wallet.coordinator.dart';
import 'package:wallet/scenes/home.v3/sub.views/delete.wallet/delete.wallet.coordinator.dart';
import 'package:wallet/scenes/home.v3/sub.views/onboarding.guide/onboarding.guide.coordinator.dart';
import 'package:wallet/scenes/home.v3/sub.views/passphrase/passphrase.coordinator.dart';
import 'package:wallet/scenes/home.v3/sub.views/secure.your.wallet/secure.your.wallet.coordinator.dart';
import 'package:wallet/scenes/home.v3/sub.views/send.invite/send.invite.coordinator.dart';
import 'package:wallet/scenes/home.v3/sub.views/transaction.addresses.switch/transaction.addresses.switch.coordinator.dart';
import 'package:wallet/scenes/home.v3/sub.views/unavailable/buying.unavailable.coordinator.dart';
import 'package:wallet/scenes/home.v3/sub.views/upgrade/upgrade.coordinator.dart';
import 'package:wallet/scenes/home.v3/sub.views/wallet.account.statement.export/wallet.account.statement.export.coordinator.dart';
import 'package:wallet/scenes/home.v3/sub.views/wallet.setting/wallet.setting.coordinator.dart';
import 'package:wallet/scenes/lock.core/lock.overlay.coordinator.dart';
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
    Coordinator.nestedNavigatorKey ??= GlobalKey<NavigatorState>(
      debugLabel: "HomeNestedNavigatorKey",
    );
  }

  @override
  void end() {
    Coordinator.nestedNavigatorKey = null;
  }

  void showNativeUpgrade(FlutterSession session) {
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

  Future<bool> showSend(String walletID, String accountID) {
    final view = SendCoordinator(
      nativeViewChannel,
      walletID,
      accountID,
    ).start();
    return showInBottomSheet(
      view,
      backgroundColor: ProtonColors.backgroundSecondary,
    );
  }

  void showSecureYourWallet(
    String walletID, {
    required bool hadSetupRecovery,
    required bool showWalletRecovery,
    required bool hadSetup2FA,
  }) {
    final view = SecureYourWalletCoordinator(
      walletID,
      hadSetupRecovery: hadSetupRecovery,
      showWalletRecovery: showWalletRecovery,
      hadSetup2FA: hadSetup2FA,
    ).start();
    showInBottomSheet(
      view,
      backgroundColor: ProtonColors.backgroundSecondary,
    );
  }

  Future<bool> showBackupYourWallet(
    WalletMenuModel walletMenuModel,
  ) {
    final view = BackupYourWalletCoordinator(
      walletMenuModel,
    ).start();
    return showInBottomSheet(
      view,
      backgroundColor: ProtonColors.backgroundSecondary,
    );
  }

  Future<bool> showBackupYourProton() {
    final view = BackupYourProtonCoordinator().start();
    return showInBottomSheet(
      view,
      backgroundColor: ProtonColors.backgroundSecondary,
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

  void showSetupBackup(String walletID) {
    final view = SetupBackupCoordinator(walletID).start();
    showInBottomSheet(
      view,
      backgroundColor: ProtonColors.backgroundSecondary,
    );
  }

  void showSecuritySetting() {
    final view = SecuritySettingCoordinator().start();
    showInBottomSheet(view);
  }

  Future<bool> showHistoryDetails(
    String walletID,
    String accountID,
    FrbTransactionDetails frbTransactionDetails,
  ) async {
    final view = HistoryDetailCoordinator(
      walletID,
      accountID,
      frbTransactionDetails,
    ).start();
    return showInBottomSheet(
      view,
      backgroundColor: ProtonColors.backgroundSecondary,
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

  void showAddWalletAccount(
    String walletID,
  ) {
    final view = AddWalletAccountCoordinator(
      walletID,
    ).start();
    showInBottomSheet(
      view,
      backgroundColor: ProtonColors.backgroundSecondary,
    );
  }

  void showAcceptTermsAndCondition(
    String email,
  ) {
    final view = AcceptTermsConditionCoordinator(
      email,
    ).start();
    showInBottomSheet(
      view,
      backgroundColor: ProtonColors.backgroundSecondary,
    );
  }

  void showSendInvite() {
    showInBottomSheet(
      SendInviteCoordinator().start(),
      backgroundColor: ProtonColors.backgroundSecondary,
    );
  }

  void showImportWalletPassphrase(WalletMenuModel walletMenuModel) {
    showInBottomSheet(
      PassphraseCoordinator(walletMenuModel).start(),
      backgroundColor: ProtonColors.backgroundSecondary,
    );
  }

  void showOnboardingGuide(
    WalletListBloc walletListBloc,
    CreateWalletBloc createWalletBloc, {
    bool firstWallet = false,
  }) {
    final view = OnboardingGuideCoordinator(
      walletListBloc,
      createWalletBloc,
    ).start();
    showInBottomSheet(
      view,
      backgroundColor: ProtonColors.backgroundSecondary,
      enableDrag: !firstWallet,
      isDismissible: !firstWallet,
    );
  }

  void logout() {
    serviceManager.logout();
    final view =
        WelcomeCoordinator(nativeViewChannel: nativeViewChannel).start();
    pushReplacementRemoveAll(view);
  }

  void showWalletAccountStatementExport(
    WalletListBloc walletListBloc,
    AccountMenuModel accountMenuModel,
  ) {
    final view = WalletAccountStatementExportCoordinator(
      walletListBloc,
      accountMenuModel,
    ).start();
    showInBottomSheet(view);
  }

  void showDeleteWallet(
    WalletMenuModel walletMenuModel, {
    required bool triggerFromSidebar,
  }) {
    final view = DeleteWalletCoordinator(
      walletMenuModel,
      triggerFromSidebar: triggerFromSidebar,
    ).start();
    showInBottomSheet(view);
  }

  void showWalletSetting(
    WalletListBloc walletListBloc,
    WalletBalanceBloc walletBalanceBloc,
    WalletNameBloc walletNameBloc,
    WalletMenuModel walletMenuModel,
  ) {
    final view = WalletSettingCoordinator(
      walletListBloc,
      walletBalanceBloc,
      walletNameBloc,
      walletMenuModel,
    ).start();
    showInBottomSheet(view);
  }

  void showUpgrade({required bool isWalletAccountExceedLimit}) {
    showInBottomSheet(
      UpgradeCoordinator(
        isWalletAccountExceedLimit: isWalletAccountExceedLimit,
      ).start(),
      backgroundColor: ProtonColors.backgroundSecondary,
    );
  }

  void showTransactionAddressSwitch(
    AccountMenuModel accountMenuModel,
  ) {
    final view =
        TransactionAddressesSwitchCoordinator(accountMenuModel).start();
    showInBottomSheet(view);
  }

  void showBuyUnavailableAlert() {
    final view = BuyingUnavailableCoordinator().start();
    showInBottomSheet(
      view,
      backgroundColor: ProtonColors.backgroundSecondary,
      enableDrag: false,
      isDismissible: false,
    );
  }

  @override
  ViewBase<ViewModel> start() {
    final userManager = serviceManager.get<UserManager>();
    final walletManager = serviceManager.get<WalletManager>();
    final event = serviceManager.get<EventLoop>();
    final apiServiceManager = serviceManager.get<ProtonApiServiceManager>();
    final dataProviderManager = serviceManager.get<DataProviderManager>();
    final channelManager = serviceManager.get<PlatformChannelManager>();
    final appStateManager = serviceManager.get<AppStateManager>();
    final shared = serviceManager.get<PreferencesManager>();

    /// build wallet list feature bloc
    final walletBloc = WalletListBloc(
      dataProviderManager.walletDataProvider,
      dataProviderManager.walletPassphraseProvider,
      dataProviderManager.walletKeysProvider,
      userManager,
      walletManager,
      dataProviderManager.userSettingsDataProvider,
      dataProviderManager.bdkTransactionDataProvider,
      appStateManager,
    );

    /// build wallet transaction feature bloc
    final walletTransactionBloc = WalletTransactionBloc(
      userManager,
      walletManager,
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
      walletManager,
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
      apiServiceManager.getProtonUsersApiClient(),
      appStateManager,
    );

    final walletNameBloc = WalletNameBloc(
      dataProviderManager.walletKeysProvider,
      apiServiceManager.getWalletClient(),
      DBHelper.accountDao!,
    );

    /// build locker overlay view
    final overlayView = LockCoordinator().start();

    final viewModel = HomeViewModelImpl(
      this,
      walletBloc,
      walletTransactionBloc,
      walletBalanceBloc,
      createWalletBloc,
      deleteWalletBloc,
      walletNameBloc,
      userManager,
      walletManager,
      event,
      apiServiceManager,

      ///
      channelManager,
      appStateManager,
      //
      dataProviderManager.userDataProvider,
      dataProviderManager.userSettingsDataProvider,
      dataProviderManager.priceGraphDataProvider,
      dataProviderManager.blockInfoDataProvider,
      dataProviderManager.exclusiveInviteDataProvider,
      dataProviderManager.contactsDataProvider,
      dataProviderManager.addressKeyProvider,
      dataProviderManager.walletDataProvider,
      dataProviderManager.unleashDataProvider,
      dataProviderManager.bdkTransactionDataProvider,
      dataProviderManager.backupAlertTimerProvider,
      shared,
    );

    widget = HomeView(
      viewModel,
      locker: overlayView,
    );
    return widget;
  }
}
