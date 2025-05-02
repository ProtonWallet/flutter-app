import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:provider/provider.dart';
import 'package:sentry/sentry.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/helper/common.helper.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/exceptions.dart';
import 'package:wallet/helper/extension/datetime.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/helper/user.agent.dart';
import 'package:wallet/helper/user.settings.provider.dart';
import 'package:wallet/managers/api.service.manager.dart';
import 'package:wallet/managers/app.state.manager.dart';
import 'package:wallet/managers/channels/native.view.channel.dart';
import 'package:wallet/managers/event.loop.manager.dart';
import 'package:wallet/managers/features/wallet.balance/wallet.balance.bloc.dart';
import 'package:wallet/managers/features/wallet.list/wallet.list.bloc.dart';
import 'package:wallet/managers/features/wallet.list/wallet.list.bloc.model.dart';
import 'package:wallet/managers/features/wallet.trans/wallet.transaction.bloc.dart';
import 'package:wallet/managers/features/wallet/create.wallet.bloc.dart';
import 'package:wallet/managers/features/wallet/delete.wallet.bloc.dart';
import 'package:wallet/managers/features/wallet/wallet.name.bloc.dart';
import 'package:wallet/managers/local.auth.manager.dart';
import 'package:wallet/managers/preferences/preferences.keys.dart';
import 'package:wallet/managers/preferences/preferences.manager.dart';
import 'package:wallet/managers/providers/address.keys.provider.dart';
import 'package:wallet/managers/providers/backup.alert.timer.provider.dart';
import 'package:wallet/managers/providers/bdk.transaction.data.provider.dart';
import 'package:wallet/managers/providers/blockinfo.data.provider.dart';
import 'package:wallet/managers/providers/contacts.data.provider.dart';
import 'package:wallet/managers/providers/exclusive.invite.data.provider.dart';
import 'package:wallet/managers/providers/price.graph.data.provider.dart';
import 'package:wallet/managers/providers/unleash.data.provider.dart';
import 'package:wallet/managers/providers/user.data.provider.dart';
import 'package:wallet/managers/providers/user.settings.data.provider.dart';
import 'package:wallet/managers/providers/wallet.data.provider.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/history.transaction.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/rust/api/bdk_wallet/transaction_details.dart';
import 'package:wallet/rust/api/errors.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/rust/proton_api/invite.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/scenes/components/alerts/app.crypto.error.dialog.dart';
import 'package:wallet/scenes/components/alerts/force.upgrade.dialog.dart';
import 'package:wallet/scenes/components/alerts/logout.error.dialog.dart';
import 'package:wallet/scenes/components/discover/proton.feeditem.dart';
import 'package:wallet/scenes/components/home/transaction.filter.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/home.coordinator.dart';

enum WalletDrawerStatus {
  close,
  openSetting,
  openWalletPreference,
}

enum BodyListStatus {
  transactionList,
  bitcoinAddressList,
}

abstract class HomeViewModel extends ViewModel<HomeCoordinator> {
  HomeViewModel(
    super.coordinator,
    this.walletListBloc,
    this.walletTransactionBloc,
    this.walletBalanceBloc,
    this.createWalletBloc,
    this.deleteWalletBloc,
    this.walletNameBloc,
    this.priceGraphDataProvider,
  );

  int selectedPage = 0;

  late UserSettingProvider userSettingProvider;
  bool hasMailIntegration = false;
  bool isFetching = false;
  bool isLogout = false;
  bool displayBalance = true;
  bool isWalletView = true;
  bool acceptTermsAndConditions = false;
  int currentHistoryPage = 0;
  int currentAddressPage = 0;
  AccountMenuModel? selectedAccountMenuModel;
  BodyListStatus bodyListStatus = BodyListStatus.transactionList;
  bool canInvite = false;
  RemainingMonthlyInvitations? remainingMonthlyInvitations;

  final transactionSearchController = TextEditingController(text: "");
  final addressSearchController = TextEditingController(text: "");

  String errorMessage = "";
  List<HistoryTransaction> historyTransactions = [];

  void updateBodyListStatus(BodyListStatus bodyListStatus);

  void setSearchHistoryTextField({required bool show});

  void setSearchAddressTextField({required bool show});

  void setDisplayBalance({required bool display});

  void deleteWallet(WalletModel walletModel) {
    deleteWalletBloc.add(DeleteWalletEvent(
      walletModel,
      DeleteWalletSteps.start,
    ));
  }

  void deleteWalletAuth(WalletModel walletModel, String pwd, String twofa) {
    deleteWalletBloc.add(DeleteWalletEvent(
      walletModel,
      DeleteWalletSteps.auth,
      password: pwd,
      twofa: twofa,
    ));
  }

  late TextEditingController hideEmptyUsedAddressesController;
  late TextEditingController twoFactorAmountThresholdController;

  bool hideEmptyUsedAddresses = false;
  bool showWalletRecovery = true;
  bool hadSetup2FA = false;
  bool hadSetupRecovery = false;
  bool showSearchHistoryTextField = false;
  bool showSearchAddressTextField = false;

  void setOnBoard();

  void selectWallet(WalletMenuModel walletMenuModel);

  void selectAccount(
    WalletMenuModel walletMenuModel,
    AccountMenuModel accountMenuModel,
  );

  void showMoreTransactionHistory();

  void showMoreAddress();

  void updateDrawerStatus(WalletDrawerStatus walletDrawerStatus);

  void showWalletSettings(WalletMenuModel walletMenuModel) {
    coordinator.showWalletSetting(
      walletListBloc,
      walletBalanceBloc,
      walletNameBloc,
      walletMenuModel,
    );
  }

  void showDeleteWallet(
    WalletMenuModel walletMenuModel, {
    required bool triggerFromSidebar,
  }) {
    coordinator.showDeleteWallet(
      walletMenuModel,
      triggerFromSidebar: triggerFromSidebar,
    );
  }

  void showImportWalletPassphrase(WalletMenuModel walletMenuModel) {
    coordinator.showImportWalletPassphrase(walletMenuModel);
  }

  void showTransactionAddressSwitch(AccountMenuModel accountMenuModel) {
    coordinator.showTransactionAddressSwitch(accountMenuModel);
  }

  WalletMenuModel? getSelectedWalletMenuModel() {
    return walletListBloc.getSelectedWalletMenuModel();
  }

  Future<void> showHistoryDetails(
    String walletID,
    String accountID,
    FrbTransactionDetails frbTransactionDetails,
  ) async {
    await coordinator.showHistoryDetails(
      walletID,
      accountID,
      frbTransactionDetails,
    );
    inAppReviewCheck();
  }

  Future<void> showBackupYourProton() async {
    if (!isShowingBackupYourProton) {
      /// avoid to show twice
      isShowingBackupYourProton = true;
      await coordinator.showBackupYourProton();
      isShowingBackupYourProton = false;
    }
  }

  Future<void> showBackupYourWallet(walletMenuModel) async {
    if (!isShowingBackupYourWallet && walletMenuModel != null) {
      /// avoid to show twice
      isShowingBackupYourWallet = true;
      await coordinator.showBackupYourWallet(walletMenuModel);
      isShowingBackupYourWallet = false;
    }
  }

  int totalTodoSteps = 3;
  int currentTodoStep = 0;
  WalletDrawerStatus walletDrawerStatus = WalletDrawerStatus.close;

  String walletIDtoAddAccount = "";
  bool isWalletPassphraseMatch = true;
  bool isValidToken = false;
  bool isShowingBackupYourProton = false;
  bool isShowingBackupYourWallet = false;
  bool showBackupYourWalletBanner = false;
  bool showBackupYourProtonBanner = false;
  bool showExportTransaction = false;

  late FocusNode walletRecoverPassphraseFocusNode;
  List<ProtonFeedItem> protonFeedItems = [];
  late TextEditingController walletRecoverPassphraseController;

  late FocusNode passphraseFocusNode;
  late FocusNode passphraseConfirmFocusNode;
  late TextEditingController passphraseTextController;
  late TextEditingController passphraseConfirmTextController;
  late FocusNode nameFocusNode;
  late TextEditingController nameTextController;

  @override
  bool get keepAlive => true;

  @override
  bool get screenSizeState => true;

  Future<void> logout();

  String getUserEmail();

  String getDisplayName();

  TransactionFilterBy transactionListFilterBy = TransactionFilterBy.all;
  String addressListFilterBy = "";

  Future<void> updatePassphrase(String key, String passphrase);

  void updateTransactionListFilterBy(TransactionFilterBy filterBy);

  void updateAddressListFilterBy(String filterBy);

  final WalletNameBloc walletNameBloc;
  final WalletListBloc walletListBloc;
  final WalletTransactionBloc walletTransactionBloc;
  final WalletBalanceBloc walletBalanceBloc;
  final CreateWalletBloc createWalletBloc;
  final DeleteWalletBloc deleteWalletBloc;
  BitcoinUnit bitcoinUnit = BitcoinUnit.btc;
  ProtonExchangeRate currentExchangeRate = defaultExchangeRate;

  final PriceGraphDataProvider priceGraphDataProvider;

  /// app version
  String appVersion = "";

  bool get isBuyMobileDisabled;

  Future<void> inAppReviewCheck({bool fromSend = false});

  Future<void> backupYourWalletCheck();

  String getFiatCurrencyName({FiatCurrency? fiatCurrency});

  String getFiatCurrencySign({FiatCurrency? fiatCurrency});
}

class HomeViewModelImpl extends HomeViewModel {
  HomeViewModelImpl(
    super.coordinator,
    super.walletListBloc,
    super.walletTransactionBloc,
    super.walletBalanceBloc,
    super.createWalletBloc,
    super.deleteWalletBloc,
    super.walletNameBloc,
    this.userManager,
    this.walletManager,
    this.eventLoop,
    this.apiServiceManager,
    this.channel,
    this.appStateManager,
    this.userDataProvider,
    this.userSettingsDataProvider,
    super.priceGraphDataProvider,
    this.blockInfoDataProvider,
    this.exclusiveInviteDataProvider,
    this.contactsDataProvider,
    this.addressKeyProvider,
    this.walletDataProvider,
    this.unleashDataProvider,
    this.bdkTransactionDataProvider,
    this.backupAlertTimerProvider,
    this.shared,
  );

  /// cache
  final PreferencesManager shared;

  /// Managers
  final UserManager userManager;
  final WalletManager walletManager;
  final EventLoop eventLoop;
  final ProtonApiServiceManager apiServiceManager;

  /// native channel
  final NativeViewChannel channel;

  /// app state
  final AppStateManager appStateManager;
  StreamSubscription? _appStateSubscription;
  StreamSubscription? _userDataSubscription;
  StreamSubscription? _subscription;
  StreamSubscription? _blockInfoDataSubscription;
  StreamSubscription? _exclusiveInviteDataSubscription;
  StreamSubscription? _walletBalanceSubscription;

  final selectedSectionChangedController = StreamController<int>.broadcast();

  /// data providers
  final UserDataProvider userDataProvider;
  final UserSettingsDataProvider userSettingsDataProvider;
  final BlockInfoDataProvider blockInfoDataProvider;
  final ExclusiveInviteDataProvider exclusiveInviteDataProvider;
  final ContactsDataProvider contactsDataProvider;
  final AddressKeyProvider addressKeyProvider;
  final WalletsDataProvider walletDataProvider;
  final UnleashDataProvider unleashDataProvider;
  final BDKTransactionDataProvider bdkTransactionDataProvider;
  final BackupAlertTimerProvider backupAlertTimerProvider;

  @override
  void dispose() {
    selectedSectionChangedController.close();

    ///clean up wallet ....
    _appStateSubscription?.cancel();
    _userDataSubscription?.cancel();
    _subscription?.cancel();
    _blockInfoDataSubscription?.cancel();
    _exclusiveInviteDataSubscription?.cancel();
    _walletBalanceSubscription?.cancel();
    super.dispose();
  }

  void datasourceStreamSinkAdd() {
    sinkAddSafe();
  }

  /// capture errors
  Future<void> initAppStateSubscription() async {
    /// app state
    _appStateSubscription = appStateManager.stream.listen((state) {
      if (state is AppSessionFailed) {
        showLogoutErrorDialog(errorMessage, logout);
      } else if (state is AppUnlockFailedState) {
        LocalAuthManager.auth.stopAuthentication();
        logout();
      } else if (state is AppUnlockForceLogoutState) {
        logout();
      } else if (state is AppForceUpgradeState) {
        showUpgradeErrorDialog(state.message, logout);
      } else if (state is AppCryptoFailed) {
        showAppCryptoErrorDialog(state.message);
      }
    }, onError: (e, stacktrace) {
      Sentry.captureException(e, stackTrace: stacktrace);
      logger.e(e.toString());
    }, onDone: () {
      logger.d("app state done");
    });
  }

  Future<void> initSubscription() async {
    /// block info
    /// listen blockheight event after app is up 3 mins
    /// since app will sync automatically when it's open
    Future.delayed(const Duration(seconds: 180), () {
      if (!isLogout) {
        _blockInfoDataSubscription =
            blockInfoDataProvider.dataUpdateController.stream.listen((onData) {
          if (!appStateManager.isInBackground) {
            walletTransactionBloc.syncWallet(
              forceSync: false,
              heightChanged: true,
            );
          }
        });
      }
    });

    /// user data
    _userDataSubscription = userDataProvider.stream.listen((state) {
      if (state is TwoFaUpdated) {
        hadSetup2FA = state.updatedData;
        checkPreference();
      } else if (state is RecoveryUpdated) {
        hadSetupRecovery = state.updatedData;
        checkPreference();
        backupYourWalletCheck(checkOnly: true);
      } else if (state is ShowWalletRecoveryUpdated) {
        showWalletRecovery = state.updatedData;
        checkPreference();
        backupYourWalletCheck(checkOnly: true);
      }
    });

    /// exclusive invite
    _exclusiveInviteDataSubscription =
        exclusiveInviteDataProvider.stream.listen((state) {
      if (state is AvailableUpdated) {
        remainingMonthlyInvitations = state.updatedData;
        loadInviteState();
      }
    });

    eventLoop.setRecoveryCallback((tasks) async {
      for (final item in tasks) {
        switch (item) {
          case LoadingTask.eligible:
            if (!await eligibleCheck()) {
              return;
            }
          case LoadingTask.homeRecheck:
            preLoadHomeData();
          case LoadingTask.syncRecheck:
            walletTransactionBloc.syncWallet(
              forceSync: false,
              heightChanged: true,
            );
        }
      }
    });

    _walletBalanceSubscription = walletBalanceBloc.stream.listen((state) {
      if (state.balanceInSatoshi > 0) {
        backupYourWalletCheck();
      }
    });
  }

  Future<void> loadContacts() async {
    await contactsDataProvider.preLoad();
  }

  Future<void> loadInviteState() async {
    if (remainingMonthlyInvitations == null) {
      canInvite = false;
    } else {
      canInvite = remainingMonthlyInvitations!.available > 0;
    }
    datasourceStreamSinkAdd();
  }

  Future<void> initControllers() async {
    hideEmptyUsedAddressesController = TextEditingController();
    twoFactorAmountThresholdController = TextEditingController(text: "3");
    walletRecoverPassphraseController = TextEditingController(text: "");
    passphraseTextController = TextEditingController(text: "");
    passphraseConfirmTextController = TextEditingController(text: "");
    nameTextController = TextEditingController();

    walletRecoverPassphraseFocusNode = FocusNode();
    passphraseFocusNode = FocusNode();
    passphraseConfirmFocusNode = FocusNode();
    nameFocusNode = FocusNode();
  }

  Future<void> preloadSettings() async {
    await userSettingsDataProvider.preLoad();
    loadUserSettings();

    // load local cached displayBalance setting
    displayBalance = await userSettingsDataProvider.getDisplayBalance();
  }

  Future<bool> eligibleCheck() async {
    appStateManager.loadingSuccess(LoadingTask.eligible);
    await appStateManager.setEligible();
    return true;
  }

  @override
  Future<void> loadData() async {
    setupLogger();

    /// init app state listener
    await initAppStateSubscription();

    /// init subscriptions
    await initSubscription();

    /// read app version
    appVersion = await UserAgent().display;

    /// check
    final checked = await eligibleCheck();
    if (!checked) {
      return;
    }

    /// init controllers
    initControllers();

    userSettingProvider = Provider.of<UserSettingProvider>(
        Coordinator.rootNavigatorKey.currentContext!,
        listen: false);

    userSettingsDataProvider.exchangeRateUpdateController.stream
        .listen((onData) {
      currentExchangeRate = userSettingsDataProvider.exchangeRate;
      datasourceStreamSinkAdd();
    });

    userSettingsDataProvider.bitcoinUnitUpdateController.stream
        .listen((onData) {
      bitcoinUnit = userSettingsDataProvider.bitcoinUnit;
      datasourceStreamSinkAdd();
    });

    transactionSearchController.addListener(datasourceStreamSinkAdd);

    addressSearchController.addListener(datasourceStreamSinkAdd);

    /// workaround, load addressKey to memory first, or it will need to wait until other api call finish
    /// will need to prioritize api calls in other MR
    final _ = await addressKeyProvider.getAddressKeysForTL();

    /// preload data
    preLoadHomeData();
  }

  Future<void> preLoadHomeData() async {
    try {
      ///reset error message
      errorMessage = "";

      /// load user settings
      preloadSettings();

      /// change call back to steam listener
      walletListBloc.init(
        startLoadingCallback: selectDefaultWallet,
        onboardingCallback: setOnBoard,
      );
      walletListBloc.stream.listen((state) {
        for (final walletMenuModel in state.walletsModel) {
          if (walletDataProvider.selectedServerWalletID ==
              walletMenuModel.walletModel.walletID) {
            showWalletRecovery =
                walletMenuModel.walletModel.showWalletRecovery == 1;
            checkPreference();
          }
        }
      });
      exclusiveInviteDataProvider.preLoad();
      userDataProvider.preLoad();

      /// lagLoad unnecessary data to improve homepage loading speed
      Future.delayed(const Duration(seconds: 5), () {
        if (!isLogout) {
          try {
            loadContacts();
            loadDiscoverContents();
          } catch (e) {
            e.toString();
          }
        }
      });
    } on BridgeError catch (e, stacktrace) {
      appStateManager.updateStateFrom(e);
      errorMessage = e.localizedString;
      logger.e("importWallet error: $e, stacktrace: $stacktrace");
      Sentry.captureException(e, stackTrace: stacktrace);
    } catch (e) {
      errorMessage = e.toString();
    }
    if (errorMessage.isNotEmpty) {
      CommonHelper.showErrorDialog("App init: $errorMessage");
      errorMessage = "";
    } else {
      appStateManager.isHomeInitialed = true;
    }
    datasourceStreamSinkAdd();
    eventLoop.start();
  }

  void selectDefaultWallet() {
    for (WalletMenuModel walletMenuModel in walletListBloc.state.walletsModel) {
      if (walletMenuModel.hasValidPassword) {
        walletDataProvider.updateSelected(
          walletMenuModel.walletModel.walletID,
          null,
        );
        showWalletRecovery =
            walletMenuModel.walletModel.showWalletRecovery == 1;
        selectedAccountMenuModel = null;
        isWalletView = true;
        break;
      }
    }
    checkPreference();
  }

  Future<void> loadDiscoverContents() async {
    final contents = await apiServiceManager
        .getApiService()
        .getDiscoveryContentClient()
        .getDiscoveryContents();
    protonFeedItems = await ProtonFeedItem.loadsFromContents(contents);
  }

  @override
  void updateDrawerStatus(WalletDrawerStatus walletDrawerStatus) {
    this.walletDrawerStatus = walletDrawerStatus;
    datasourceStreamSinkAdd();
  }

  @override
  Future<void> selectWallet(WalletMenuModel walletMenuModel) async {
    walletDataProvider.updateSelected(
      walletMenuModel.walletModel.walletID,
      null,
    );
    currentHistoryPage = 0;
    currentAddressPage = 0;
    showBackupYourProtonBanner = false;
    showBackupYourWalletBanner = false;

    /// only allow export transaction in account level
    showExportTransaction = false;
    showWalletRecovery = walletMenuModel.walletModel.showWalletRecovery == 1;
    selectedAccountMenuModel = null;
    isWalletView = true;
    checkPreference();
    updateBodyListStatus(BodyListStatus.transactionList);
  }

  @override
  Future<void> selectAccount(
    WalletMenuModel walletMenuModel,
    AccountMenuModel accountMenuModel,
  ) async {
    walletDataProvider.updateSelected(
      walletMenuModel.walletModel.walletID,
      accountMenuModel.accountModel.accountID,
    );
    currentHistoryPage = 0;
    currentAddressPage = 0;
    showBackupYourProtonBanner = false;
    showBackupYourWalletBanner = false;

    /// check if we can allow user to export transaction
    showExportTransaction = unleashDataProvider.isWalletExportTransaction();
    showWalletRecovery = walletMenuModel.walletModel.showWalletRecovery == 1;
    selectedAccountMenuModel = accountMenuModel;
    isWalletView = false;
    checkPreference();
    updateBodyListStatus(BodyListStatus.transactionList);
  }

  @override
  Future<void> setOnBoard() async {
    bool firstWallet = false;
    final List<WalletData>? wallets =
        await walletListBloc.walletsDataProvider.getWallets();
    if (wallets == null) {
      firstWallet = true;
    } else if (wallets.isEmpty) {
      firstWallet = true;
    }
    coordinator.showOnboardingGuide(
      walletListBloc,
      createWalletBloc,
      firstWallet: firstWallet,
    );
  }

  @override
  void showMoreTransactionHistory() {
    currentHistoryPage++;
    datasourceStreamSinkAdd();
  }

  @override
  void showMoreAddress() {
    currentAddressPage++;
    datasourceStreamSinkAdd();
  }

  Future<void> loadUserSettings() async {
    final settings = await userSettingsDataProvider.getSettings();
    if (settings != null) {
      hideEmptyUsedAddresses = settings.hideEmptyUsedAddresses;
      twoFactorAmountThresholdController.text =
          settings.twoFactorAmountThreshold.toString();
      acceptTermsAndConditions = settings.acceptTermsAndConditions;
    }
    datasourceStreamSinkAdd();
  }

  Future<void> checkPreference() async {
    int newTodoStep = 0;
    newTodoStep += showWalletRecovery ? 0 : 1;
    newTodoStep += hadSetup2FA ? 1 : 0;
    newTodoStep += hadSetupRecovery ? 1 : 0;
    currentTodoStep = newTodoStep;
    datasourceStreamSinkAdd();
  }

  @override
  Future<void> logout() async {
    isLogout = true;
    EasyLoading.show(maskType: EasyLoadingMaskType.black);
    try {
      eventLoop.stop();
      await userManager.logout();
      await walletManager.cleanBDKCache();
      try {
        userSettingProvider.destroy();
      } catch (e) {
        // no provider init for non eligible user
      }
      await walletManager.cleanSharedPreference();
      await DBHelper.reset();
      await appStateManager.logout();
    } on BridgeError catch (e, stacktrace) {
      appStateManager.updateStateFrom(e);
      errorMessage = e.localizedString;
      logger.e("importWallet error: $e, stacktrace: $stacktrace");
      Sentry.captureException(e, stackTrace: stacktrace);
    } catch (e, stacktrace) {
      errorMessage = e.toString();
      Sentry.captureException(e, stackTrace: stacktrace);
    }
    EasyLoading.dismiss();
    if (errorMessage.isNotEmpty) {
      CommonHelper.showErrorDialog(errorMessage);
      errorMessage = "";
    }
    channel.nativeLogout();
    coordinator.logout();
  }

  @override
  Future<void> move(NavID to) async {
    WalletModel? selectedWallet;
    AccountModel? selectedAccount;
    bool isWalletView = false;
    for (final walletMenuModel in walletListBloc.state.walletsModel) {
      if (walletMenuModel.isSelected) {
        /// walletView
        selectedWallet = walletMenuModel.walletModel;
        selectedAccount = null;
        isWalletView = true;
      }
      for (final accountMenuModel in walletMenuModel.accounts) {
        if (accountMenuModel.isSelected) {
          /// wallet account view
          selectedWallet = walletMenuModel.walletModel;
          selectedAccount = accountMenuModel.accountModel;
          isWalletView = false;
        }
      }
    }

    switch (to) {
      case NavID.send:
        if (await coordinator.showSend(
          selectedWallet?.walletID ?? "",
          selectedAccount?.accountID ?? "",
        )) {
          inAppReviewCheck(fromSend: true);
        }

      case NavID.receive:
        coordinator.showReceive(
          selectedWallet?.walletID ?? "",
          selectedAccount?.accountID ?? "",
          isWalletView: isWalletView,
        );
      case NavID.securitySetting:
        coordinator.showSecuritySetting();
      case NavID.welcome:
        coordinator.logout();
      case NavID.twoFactorAuthSetup:
        coordinator.showTwoFactorAuthSetup();
      case NavID.twoFactorAuthDisable:
        coordinator.showTwoFactorAuthDisable();
      case NavID.discover:
        coordinator.showDiscover();
      case NavID.buy:
        coordinator.showBuy(
          selectedWallet?.walletID ?? "",
          selectedAccount?.accountID ?? "",
        );
      case NavID.buyUnavailable:
        coordinator.showBuyUnavailableAlert();
      case NavID.nativeUpgrade:
        final session = await userManager.getChildSession();
        coordinator.showNativeUpgrade(session);
      case NavID.natvieReportBugs:
        coordinator.showNativeReportBugs();
      case NavID.recovery:
        coordinator.showRecovery();
      case NavID.settings:
        coordinator.showSettings();
      case NavID.addWalletAccount:
        coordinator.showAddWalletAccount(walletIDtoAddAccount);
      case NavID.acceptTermsConditionDialog:
        coordinator.showAcceptTermsAndCondition(getUserEmail());
      case NavID.sendInvite:
        coordinator.showSendInvite();
      case NavID.secureYourWallet:
        coordinator.showSecureYourWallet(
          selectedWallet?.walletID ?? "",
          hadSetupRecovery: hadSetupRecovery,
          showWalletRecovery: showWalletRecovery,
          hadSetup2FA: hadSetup2FA,
        );
      case NavID.setupBackup:
        coordinator.showSetupBackup(selectedWallet?.walletID ?? "");

      case NavID.walletAccountStatementExport:
        coordinator.showWalletAccountStatementExport(walletListBloc);
      default:
        break;
    }
  }

  @override
  void setSearchHistoryTextField({required bool show}) {
    if (!show) {
      if (transactionSearchController.text.isNotEmpty) {
        transactionSearchController.text = "";
      }
    }
    showSearchHistoryTextField = show;
    datasourceStreamSinkAdd();
  }

  @override
  void setSearchAddressTextField({required bool show}) {
    if (!show) {
      if (addressSearchController.text.isNotEmpty) {
        addressSearchController.text = "";
      }
    }
    showSearchAddressTextField = show;
    datasourceStreamSinkAdd();
  }

  @override
  Future<void> updatePassphrase(String key, String passphrase) async {}

  @override
  void updateBodyListStatus(BodyListStatus bodyListStatus) {
    this.bodyListStatus = bodyListStatus;
    datasourceStreamSinkAdd();
  }

  @override
  void updateTransactionListFilterBy(TransactionFilterBy filterBy) {
    transactionListFilterBy = filterBy;
    datasourceStreamSinkAdd();
  }

  @override
  void updateAddressListFilterBy(String filterBy) {
    addressListFilterBy = filterBy;
    datasourceStreamSinkAdd();
  }

  @override
  Future<void> setDisplayBalance({required bool display}) async {
    await userSettingsDataProvider.setDisplayBalance(display);
    displayBalance = display;
    datasourceStreamSinkAdd();
  }

  Future<void> setupLogger() async {
    try {
      await unleashDataProvider.start();
      if (unleashDataProvider.isTraceLoggerEnabled()) {
        await LoggerService.initDartLogger();
        await LoggerService.initRustLogger();
      }
    } catch (e, stacktrace) {
      Sentry.captureException(e, stackTrace: stacktrace);
      logger.e("setupLogger error: $e stacktrace: $stacktrace");
    }
  }

  @override
  String getDisplayName() {
    final userInfo = userManager.userInfo;
    return userDataProvider.user.protonUser?.displayName ??
        userInfo.userDisplayName;
  }

  @override
  String getUserEmail() {
    final userInfo = userManager.userInfo;
    return userDataProvider.user.protonUser?.email ?? userInfo.userMail;
  }

  @override
  bool get isBuyMobileDisabled {
    final check = unleashDataProvider.isBuyMobileDisabled();
    return check;
  }

  @override
  String getFiatCurrencyName({FiatCurrency? fiatCurrency}) {
    return userSettingsDataProvider.getFiatCurrencyName(
      fiatCurrency: fiatCurrency,
    );
  }

  @override
  String getFiatCurrencySign({FiatCurrency? fiatCurrency}) {
    return userSettingsDataProvider.getFiatCurrencySign(
      fiatCurrency: fiatCurrency,
    );
  }

  @override
  Future<void> backupYourWalletCheck({
    bool checkOnly = false,
  }) async {
    if (appStateManager.isInBackground) {
      return;
    }

    if (hadSetupRecovery && !showWalletRecovery) {
      /// skip when user already backup proton account and wallet seedphrase
      showBackupYourProtonBanner = false;
      showBackupYourWalletBanner = false;
      sinkAddSafe();
      return;
    }

    /// 1. get current selected wallet
    final selectedWallet = getSelectedWalletMenuModel();

    if (selectedWallet != null) {
      showBackupYourProtonBanner = false;
      showBackupYourWalletBanner = false;

      /// 2. check if match show alert condition
      final isExceedTimer = await backupAlertTimerProvider.isExceedTimer();
      final positiveBalance = walletBalanceBloc.state.balanceInSatoshi > 0;
      final walletCreateMoreThan3Day = (DateTime.now().secondsSinceEpoch() -
              selectedWallet.walletModel.createTime) >
          showBackupWalletAfterCreateInSeconds;

      if (isExceedTimer &&
          positiveBalance &&
          walletCreateMoreThan3Day &&
          unleashDataProvider.isWalletBackupAlert()) {
        /// check if proton account had backedup
        if (!hadSetupRecovery) {
          showBackupYourProtonBanner = true;
          if (!checkOnly) {
            showBackupYourProton();
          }
        } else if (showWalletRecovery) {
          showBackupYourWalletBanner = true;
          if (!checkOnly) {
            showBackupYourWallet(
              selectedWallet,
            );
          }
        }
      }
    }
    sinkAddSafe();
  }

  @override
  Future<void> inAppReviewCheck({bool fromSend = false}) async {
    final currentTime = DateTime.now().secondsSinceEpoch();
    final userInfo = userManager.userInfo;

    if (apple) {
      // check if in app review is showed before
      final int lastSeen =
          await shared.read(PreferenceKeys.inAppReviewTimmer) ?? 0;
      if (currentTime - lastSeen < thirtyDaysInSeconds) {
        return;
      }
    }

    final user = await userDataProvider.getUser(userInfo.userId);
    final inAppReviewFreeUser = unleashDataProvider.isInAppReviewFreeUser();
    if ((user == null || user.subscribed == 0) && !inAppReviewFreeUser) {
      return;
    }

    /// check if wallet synced
    if (!bdkTransactionDataProvider.anyFullSyncedDone()) {
      return;
    }

    /// check if there balance
    if (walletBalanceBloc.state.balanceInSatoshi <= 0) {
      return;
    }

    int detailClicked =
        await shared.read(PreferenceKeys.inAppReviewDetailCounter) ?? 0;
    if (!fromSend) {
      detailClicked += 1;
      await shared.write(
        PreferenceKeys.inAppReviewDetailCounter,
        detailClicked,
      );
    }

    /// show in app review
    final InAppReview inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      if (fromSend ||
          (android && detailClicked > 3) ||
          apple && detailClicked > 1) {
        await inAppReview.requestReview();
        await shared.write(PreferenceKeys.inAppReviewDetailCounter, 0);
        if (apple) {
          await shared.write(PreferenceKeys.inAppReviewTimmer, currentTime);
        }
      }
    }
  }
}
