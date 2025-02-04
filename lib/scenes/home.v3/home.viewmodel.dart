import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:sentry/sentry.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/helper/common.helper.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/exceptions.dart';
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
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/providers/exclusive.invite.data.provider.dart';
import 'package:wallet/managers/providers/user.data.provider.dart';
import 'package:wallet/managers/providers/wallet.data.provider.dart';
import 'package:wallet/managers/request.queue.manager.dart';
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
    this.dataProviderManager,
    this.createWalletBloc,
    this.deleteWalletBloc,
    this.walletNameBloc,
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

  void showHistoryDetails(
    String walletID,
    String accountID,
    FrbTransactionDetails frbTransactionDetails,
  ) {
    coordinator.showHistoryDetails(walletID, accountID, frbTransactionDetails);
  }

  int totalTodoSteps = 3;
  int currentTodoStep = 0;
  WalletDrawerStatus walletDrawerStatus = WalletDrawerStatus.close;

  String walletIDtoAddAccount = "";
  bool isWalletPassphraseMatch = true;
  bool isValidToken = false;

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
  final DataProviderManager dataProviderManager;
  final CreateWalletBloc createWalletBloc;
  final DeleteWalletBloc deleteWalletBloc;
  BitcoinUnit bitcoinUnit = BitcoinUnit.btc;
  ProtonExchangeRate currentExchangeRate = defaultExchangeRate;

  /// app version
  String appVersion = "";
}

class HomeViewModelImpl extends HomeViewModel {
  HomeViewModelImpl(
    super.coordinator,
    super.walletListBloc,
    super.walletTransactionBloc,
    super.walletBalanceBloc,
    super.dataProviderManager,
    super.createWalletBloc,
    super.deleteWalletBloc,
    super.walletNameBloc,
    this.userManager,
    this.walletManager,
    this.eventLoop,
    this.apiServiceManager,
    this.channel,
    this.appStateManager,
  );

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

  final selectedSectionChangedController = StreamController<int>.broadcast();

  @override
  void dispose() {
    selectedSectionChangedController.close();

    ///clean up wallet ....
    _appStateSubscription?.cancel();
    _userDataSubscription?.cancel();
    _subscription?.cancel();
    _blockInfoDataSubscription?.cancel();
    _exclusiveInviteDataSubscription?.cancel();
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
      } else if (state is AppForceUpgradeState) {
        showUpgradeErrorDialog(state.message, logout);
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
        _blockInfoDataSubscription = dataProviderManager
            .blockInfoDataProvider.dataUpdateController.stream
            .listen((onData) {
          walletTransactionBloc.syncWallet(
              forceSync: false, heightChanged: true);
        });
      }
    });

    /// user data
    _userDataSubscription =
        dataProviderManager.userDataProvider.stream.listen((state) {
      if (state is TwoFaUpdated) {
        hadSetup2FA = state.updatedData;
        checkPreference();
      } else if (state is RecoveryUpdated) {
        hadSetupRecovery = state.updatedData;
        checkPreference();
      } else if (state is ShowWalletRecoveryUpdated) {
        showWalletRecovery = state.updatedData;
        checkPreference();
      }
    });

    /// exclusive invite
    _exclusiveInviteDataSubscription =
        dataProviderManager.exclusiveInviteDataProvider.stream.listen((state) {
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
  }

  Future<void> loadContacts() async {
    await dataProviderManager.contactsDataProvider.preLoad();
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
    await dataProviderManager.userSettingsDataProvider.preLoad();
    loadUserSettings();

    // load local cached displayBalance setting
    displayBalance =
        await dataProviderManager.userSettingsDataProvider.getDisplayBalance();
  }

  Future<bool> eligibleCheck() async {
    try {
      final cachedEligible = await appStateManager.getEligible();
      if (cachedEligible != 1) {
        /// Check if user is eligible from API
        final int eligible = await retry(
          () => apiServiceManager
              .getApiService()
              .getSettingsClient()
              .getUserWalletEligibility(),
        );
        appStateManager.loadingSuccess(LoadingTask.eligible);
        if (eligible == 0) {
          move(NavID.earlyAccess);
          eventLoop.stop();
          return false;
        } else {
          await appStateManager.setEligible();
        }
      }
    } on BridgeError catch (e, stacktrace) {
      appStateManager.updateStateFrom(e);
      appStateManager.loadingFailed(LoadingTask.eligible);
      logger.e("importWallet error: $e, stacktrace: $stacktrace");
      Sentry.captureException(e, stackTrace: stacktrace);
      CommonHelper.showErrorDialog(parseSampleDisplayError(e));
      eventLoop.start();
      return false;
    } catch (e, stacktrace) {
      logger.e("importWallet error: $e, stacktrace: $stacktrace");
      appStateManager.loadingFailed(LoadingTask.eligible);
      CommonHelper.showErrorDialog(e.toString());
      eventLoop.start();
      return false;
    }

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

    dataProviderManager
        .userSettingsDataProvider.exchangeRateUpdateController.stream
        .listen((onData) {
      currentExchangeRate =
          dataProviderManager.userSettingsDataProvider.exchangeRate;
      datasourceStreamSinkAdd();
    });

    dataProviderManager
        .userSettingsDataProvider.bitcoinUnitUpdateController.stream
        .listen((onData) {
      bitcoinUnit = dataProviderManager.userSettingsDataProvider.bitcoinUnit;
      datasourceStreamSinkAdd();
    });

    transactionSearchController.addListener(datasourceStreamSinkAdd);

    addressSearchController.addListener(datasourceStreamSinkAdd);

    /// workaround, load addressKey to memory first, or it will need to wait until other api call finish
    /// will need to prioritize api calls in other MR
    final _ =
        await dataProviderManager.addressKeyProvider.getAddressKeysForTL();

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
          if (dataProviderManager.walletDataProvider.selectedServerWalletID ==
              walletMenuModel.walletModel.walletID) {
            showWalletRecovery =
                walletMenuModel.walletModel.showWalletRecovery == 1;
            checkPreference();
          }
        }
      });
      dataProviderManager.exclusiveInviteDataProvider.preLoad();
      dataProviderManager.userDataProvider.preLoad();

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
      errorMessage = parseSampleDisplayError(e);
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
        dataProviderManager.walletDataProvider.updateSelected(
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
    dataProviderManager.walletDataProvider.updateSelected(
      walletMenuModel.walletModel.walletID,
      null,
    );
    currentHistoryPage = 0;
    currentAddressPage = 0;
    showWalletRecovery = walletMenuModel.walletModel.showWalletRecovery == 1;
    selectedAccountMenuModel = null;
    isWalletView = true;
    checkPreference();
    updateBodyListStatus(BodyListStatus.transactionList);
  }

  @override
  Future<void> selectAccount(WalletMenuModel walletMenuModel,
      AccountMenuModel accountMenuModel) async {
    dataProviderManager.walletDataProvider.updateSelected(
      walletMenuModel.walletModel.walletID,
      accountMenuModel.accountModel.accountID,
    );
    currentHistoryPage = 0;
    currentAddressPage = 0;
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
    final settings =
        await dataProviderManager.userSettingsDataProvider.getSettings();
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
    } on BridgeError catch (e, stacktrace) {
      appStateManager.updateStateFrom(e);
      errorMessage = parseSampleDisplayError(e);
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
    for (WalletMenuModel walletMenuModel in walletListBloc.state.walletsModel) {
      if (walletMenuModel.isSelected) {
        /// walletView
        selectedWallet = walletMenuModel.walletModel;
        selectedAccount = null;
        isWalletView = true;
      }
      for (AccountMenuModel accountMenuModel in walletMenuModel.accounts) {
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
        coordinator.showSend(
          selectedWallet?.walletID ?? "",
          selectedAccount?.accountID ?? "",
        );
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
        coordinator.showAddWalletAccount(
          walletIDtoAddAccount,
        );
      case NavID.acceptTermsConditionDialog:
        coordinator.showAcceptTermsAndCondition(getUserEmail());
      case NavID.earlyAccess:
        coordinator.showEarlyAccess(logout, getUserEmail());
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
    await dataProviderManager.userSettingsDataProvider
        .setDisplayBalance(display);
    displayBalance = display;
    datasourceStreamSinkAdd();
  }

  Future<void> setupLogger() async {
    try {
      final unleash = dataProviderManager.unleashDataProvider;
      await unleash.start();
      if (unleash.isTraceLoggerEnabled()) {
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
    return dataProviderManager.userDataProvider.user.protonUser?.displayName ??
        userInfo.userDisplayName;
  }

  @override
  String getUserEmail() {
    final userInfo = userManager.userInfo;
    return dataProviderManager.userDataProvider.user.protonUser?.email ??
        userInfo.userMail;
  }
}
