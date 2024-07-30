// home.viewmodel.dart
import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:sentry/sentry.dart';
import 'package:wallet/constants/app.config.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/history.transaction.dart';
import 'package:wallet/constants/script_type.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/exceptions.dart';
import 'package:wallet/helper/extension/enum.extension.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/helper/user.agent.dart';
import 'package:wallet/helper/user.settings.provider.dart';
import 'package:wallet/helper/walletkey_helper.dart';
import 'package:wallet/managers/api.service.manager.dart';
import 'package:wallet/managers/app.state.manager.dart';
import 'package:wallet/managers/channels/native.view.channel.dart';
import 'package:wallet/managers/event.loop.manager.dart';
import 'package:wallet/managers/features/create.wallet.bloc.dart';
import 'package:wallet/managers/features/delete.wallet.bloc.dart';
import 'package:wallet/managers/features/proton.recovery/proton.recovery.bloc.dart';
import 'package:wallet/managers/features/proton.recovery/proton.recovery.event.dart';
import 'package:wallet/managers/features/wallet.balance.bloc.dart';
import 'package:wallet/managers/features/wallet.list.bloc.dart';
import 'package:wallet/managers/features/wallet.list/wallet.list.dart';
import 'package:wallet/managers/features/wallet.transaction.bloc.dart';
import 'package:wallet/managers/local.auth.manager.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/providers/exclusive.invite.data.provider.dart';
import 'package:wallet/managers/providers/user.data.provider.dart';
import 'package:wallet/managers/providers/wallet.data.provider.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/managers/wallet/proton.wallet.manager.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/contacts.model.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/rust/api/api_service/price_graph_client.dart';
import 'package:wallet/rust/api/bdk_wallet/mnemonic.dart';
import 'package:wallet/rust/api/proton_api.dart' as proton_api;
import 'package:wallet/rust/common/errors.dart';
import 'package:wallet/rust/common/word_count.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/rust/proton_api/invite.dart';
import 'package:wallet/rust/proton_api/proton_address.dart';
import 'package:wallet/rust/proton_api/proton_users.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/rust/proton_api/wallet_account.dart';
import 'package:wallet/scenes/components/alerts/force.upgrade.dialog.dart';
import 'package:wallet/scenes/components/alerts/logout.error.dialog.dart';
import 'package:wallet/scenes/components/discover/proton.feeditem.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/bottom.sheet/early.access.dart';
import 'package:wallet/scenes/home.v3/bottom.sheet/onboarding.guide.dart';
import 'package:wallet/scenes/home.v3/bottom.sheet/upgrade.intro.dart';
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
    this.protonRecoveryBloc,
  );

  int selectedPage = 0;

  late UserSettingProvider userSettingProvider;
  bool hasMailIntegration = false;
  bool isFetching = false;
  bool isLogout = false;
  bool displayBalance = true;
  bool acceptTermsAndConditions = false;
  int currentHistoryPage = 0;
  int currentAddressPage = 0;
  bool isShowingNoInternet = false;
  List<ProtonAddress> protonAddresses = [];
  WalletModel? walletForPreference;
  List userAccountsForPreference = [];
  List<ContactsModel> contactsEmails = [];
  AccountModel? historyAccountModel;
  BodyListStatus bodyListStatus = BodyListStatus.transactionList;
  bool canInvite = false;
  RemainingMonthlyInvitations? remainingMonthlyInvitations;
  PriceGraphClient? priceGraphClient;

  Map<String, ValueNotifier> accountFiatCurrencyNotifiers = {};

  ValueNotifier<FiatCurrency> fiatCurrencyNotifier =
      ValueNotifier(defaultFiatCurrency);
  ValueNotifier<BitcoinUnit> bitcoinUnitNotifier =
      ValueNotifier(BitcoinUnit.btc);
  late ValueNotifier<ProtonAddress> emailIntegrationNotifier;
  bool emailIntegrationEnable = false;

  late ValueNotifier accountValueNotifierForPreference;

  TextEditingController transactionSearchController =
      TextEditingController(text: "");
  TextEditingController addressSearchController =
      TextEditingController(text: "");
  TextEditingController walletPreferenceTextEditingController =
      TextEditingController(text: "");

  bool initialed = false;
  String errorMessage = "";
  List<HistoryTransaction> historyTransactions = [];

  Map<String, ValueNotifier> getAccountFiatCurrencyNotifiers(
      List<AccountModel> userAccounts);

  void updateBitcoinUnit(BitcoinUnit symbol);

  void updateBodyListStatus(BodyListStatus bodyListStatus);

  void setSearchHistoryTextField({required bool show});

  void setSearchAddressTextField({required bool show});

  void setDisplayBalance({required bool display});

  Future<bool> createWallet();

  Future<bool> sendExclusiveInvite(ProtonAddress protonAddress, String email);

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

  // ApiUserSettings? userSettings;
  late TextEditingController hideEmptyUsedAddressesController;
  late TextEditingController twoFactorAmountThresholdController;

  bool hideEmptyUsedAddresses = false;
  bool showWalletRecovery = true;
  bool hadSetup2FA = false;
  bool hadSetupRecovery = false;
  bool showSearchHistoryTextField = false;
  bool showSearchAddressTextField = false;

  ProtonUserSettings? protonUserSettings;

  void setOnBoard();

  void selectWallet(WalletMenuModel walletMenuModel);

  void loadProton2FAState();

  void loadProtonRecoveryState();

  void selectAccount(
      WalletMenuModel walletMenuModel, AccountMenuModel accountMenuModel);

  void showMoreTransactionHistory();

  void showMoreAddress();

  Future<bool> addWalletAccount(
    int walletID,
    String serverWalletID,
    ScriptTypeInfo scriptType,
    String label,
    int accountIndex,
  );

  void updateDrawerStatus(WalletDrawerStatus walletDrawerStatus);

  void openWalletPreference(String walletID);

  void checkProtonAddresses();

  Future<void> renameAccount(
      WalletModel walletModel, AccountModel accountModel, String newName);

  Future<void> deleteAccount(
      WalletModel walletModel, AccountModel accountModel);

  Future<bool> addEmailAddressToWalletAccount(
      String serverWalletID,
      WalletModel walletModel,
      AccountModel accountModel,
      String serverAddressID);

  Future<void> removeEmailAddressFromWalletAccount(WalletModel walletModel,
      AccountModel accountModel, String serverAddressID);

  Future<void> updateWalletName(WalletModel walletModel, String newName);

  ProtonAddress? getProtonAddressByID(String addressID);

  int totalTodoSteps = 3;
  int currentTodoStep = 0;
  WalletDrawerStatus walletDrawerStatus = WalletDrawerStatus.close;

  String selectedTXID = "";
  bool isWalletPassphraseMatch = true;
  bool isValidToken = false;
  bool isRemovingBvE = false;

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

  String userEmail = "";
  String displayName = "";
  String transactionListFilterBy = "";
  String addressListFilterBy = "";

  Future<void> updatePassphrase(String key, String passphrase);

  void updateTransactionListFilterBy(String filterBy);

  void updateAddressListFilterBy(String filterBy);

  //
  final WalletListBloc walletListBloc;
  final WalletTransactionBloc walletTransactionBloc;
  final WalletBalanceBloc walletBalanceBloc;
  final DataProviderManager dataProviderManager;
  final CreateWalletBloc createWalletBloc;
  final DeleteWalletBloc deleteWalletBloc;
  final ProtonRecoveryBloc protonRecoveryBloc;
  BitcoinUnit bitcoinUnit = BitcoinUnit.btc;
  ProtonExchangeRate currentExchangeRate = ProtonExchangeRate(
      id: 'default',
      bitcoinUnit: BitcoinUnit.btc,
      fiatCurrency: defaultFiatCurrency,
      exchangeRateTime: '',
      exchangeRate: BigInt.one,
      cents: BigInt.one);

  /// app version
  String appVersion = "Proton Wallet";
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
    super.protonRecoveryBloc,
    this.userManager,
    this.eventLoop,
    this.protonWalletManager,
    this.apiServiceManager,
    this.channel,
    this.appStateManager,
  );

  // user manager
  final UserManager userManager;

  // event loop manger
  final EventLoop eventLoop;

  // wallet mangaer
  final ProtonWalletManager protonWalletManager;

  // networking
  final ProtonApiServiceManager apiServiceManager;

  /// native channel
  final NativeViewChannel channel;

  /// app state
  final AppStateManager appStateManager;
  StreamSubscription? _appStateSubscription;
  StreamSubscription? _protonRecoveryStateSubscription;
  StreamSubscription? _protonUserDataSubscription;
  StreamSubscription? _subscription;
  StreamSubscription? _blockInfoDataSubscription;
  StreamSubscription? _exclusiveInviteDataSubscription;

  final selectedSectionChangedController = StreamController<int>.broadcast();

  @override
  void dispose() {
    selectedSectionChangedController.close();
    //clean up wallet ....
    _appStateSubscription?.cancel();
    _protonUserDataSubscription?.cancel();
    _subscription?.cancel();
    _blockInfoDataSubscription?.cancel();
    _protonRecoveryStateSubscription?.cancel();
    _exclusiveInviteDataSubscription?.cancel();
    super.dispose();
  }

  void datasourceStreamSinkAdd() {
    sinkAddSafe();
  }

  Future<void> initAppStateSubscription() async {
    // app state
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
    // recovery state
    _protonRecoveryStateSubscription =
        protonRecoveryBloc.stream.listen((state) {
      hadSetupRecovery = state.isRecoveryEnabled;
      checkPreference();
    });

    // block info
    _blockInfoDataSubscription = dataProviderManager
        .blockInfoDataProvider.dataUpdateController.stream
        .listen((onData) {
      walletTransactionBloc.syncWallet(forceSync: false);
    });

    // user data
    _protonUserDataSubscription =
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

    // exclusive invite
    _exclusiveInviteDataSubscription =
        dataProviderManager.exclusiveInviteDataProvider.stream.listen((state) {
      if (state is AvailableUpdated) {
        remainingMonthlyInvitations = state.updatedData;
        loadInviteState();
      }
    });
  }

  Future<void> loadContacts() async {
    await dataProviderManager.contactsDataProvider.preLoad();
    contactsEmails =
        await dataProviderManager.contactsDataProvider.getContacts() ?? [];
  }

  Future<void> loadInviteState() async {
    if (remainingMonthlyInvitations == null) {
      canInvite = false;
    } else {
      canInvite = remainingMonthlyInvitations!.available > 0;
    }
    datasourceStreamSinkAdd();
  }

  @override
  Future<bool> sendExclusiveInvite(
      ProtonAddress protonAddress, String email) async {
    final String emailAddressID = protonAddress.id;
    try {
      await apiServiceManager
          .getApiService()
          .getInviteClient()
          .sendNewcomerInvite(
            inviteeEmail: email.trim(),
            inviterAddressId: emailAddressID,
          );
      dataProviderManager.exclusiveInviteDataProvider.updateData();
    } on BridgeError catch (error) {
      final errMsg = parseSampleDisplayError(error);
      final BuildContext? context = Coordinator.rootNavigatorKey.currentContext;
      if (context != null && context.mounted) {
        CommonHelper.showErrorDialog(errMsg);
      }
      return false;
    } catch (e) {
      final BuildContext? context = Coordinator.rootNavigatorKey.currentContext;
      if (context != null && context.mounted) {
        CommonHelper.showErrorDialog(e.toString());
      }
      return false;
    }
    return true;
  }

  @override
  Future<void> loadProton2FAState() async {
    try {
      protonUserSettings =
          await apiServiceManager.getProtonUsersApiClient().getUserSettings();
    } catch (e) {
      logger.e(e
          .toString()); // only need to load once. keep it simple so maintain it in VM
    }
    if (protonUserSettings != null) {
      if (protonUserSettings!.twoFa != null) {
        hadSetup2FA = protonUserSettings!.twoFa!.enabled != 0;
        checkPreference();
      }
    }
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
  }

  @override
  Future<void> loadData() async {
    await initAppStateSubscription();
    // init network
    await apiServiceManager.initalOldApiService();
    // read app version
    appVersion = await UserAgent().display;

    // user
    final userInfo = userManager.userInfo;
    userEmail = userInfo.userMail;
    displayName = userInfo.userDisplayName;
    protonWalletManager.login(userInfo.userId);

    try {
      // check if user is eligible
      final int eligible = await apiServiceManager
          .getApiService()
          .getSettingsClient()
          .getUserWalletEligibility();
      if (eligible == 0) {
        EarlyAccessSheet.show(
          Coordinator.rootNavigatorKey.currentContext!,
          userEmail,
          logout,
        );
        return;
      }
    } on BridgeError catch (e, stacktrace) {
      appStateManager.handleForceUpgrade(e);
      appStateManager.handleError(e);
      logger.e("importWallet error: $e, stacktrace: $stacktrace");
      Sentry.captureException(e, stackTrace: stacktrace);
      return;
    } catch (e, stacktrace) {
      logger.e("importWallet error: $e, stacktrace: $stacktrace");
      return;
    }

    // ----------------
    // settings

    // transactions
    try {
      /// init subscriptions
      initSubscription();

      /// init controllers
      initControllers();

      userSettingProvider = Provider.of<UserSettingProvider>(
          Coordinator.rootNavigatorKey.currentContext!,
          listen: false);
      preloadSettings();
      walletListBloc.init(
        startLoadingCallback: selectDefaultWallet,
        onboardingCallback: setOnBoard,
      );
      priceGraphClient =
          apiServiceManager.getApiService().getPriceGraphClient();
      loadProtonRecoveryState();
      loadProton2FAState();
      dataProviderManager.exclusiveInviteDataProvider.preLoad();

      // async
      loadContacts();
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
      // checkNetwork();
      loadDiscoverContents();
      checkProtonAddresses();

      bitcoinUnitNotifier.addListener(() async {
        updateBitcoinUnit(bitcoinUnitNotifier.value);
      });

      transactionSearchController.addListener(datasourceStreamSinkAdd);

      addressSearchController.addListener(datasourceStreamSinkAdd);

      eventLoop.start();
    } on BridgeError catch (e, stacktrace) {
      appStateManager.handleForceUpgrade(e);
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
      initialed = true;
    }
    datasourceStreamSinkAdd();
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
        break;
      }
    }
    checkPreference();
  }

  Future<void> loadDiscoverContents() async {
    protonFeedItems = await ProtonFeedItem.loadFromApi(
        apiServiceManager.getApiService().getDiscoveryContentClient());
  }

  @override
  Future<void> checkProtonAddresses() async {
    try {
      await dataProviderManager.protonEmailAddressProvider.preLoad();
      protonAddresses = await dataProviderManager.protonEmailAddressProvider
          .getProtonEmailAddresses();
      emailIntegrationNotifier = ValueNotifier(protonAddresses.first);
      datasourceStreamSinkAdd();
    } catch (e) {
      errorMessage = e.toString();
    }
  }

  @override
  Future<void> openWalletPreference(String walletID) async {
    walletForPreference = await DBHelper.walletDao!.findByServerID(walletID);
    if (walletForPreference != null) {
      userAccountsForPreference =
          await DBHelper.accountDao!.findAllByWalletID(walletID);
      walletPreferenceTextEditingController.text = walletForPreference!.name;
      accountValueNotifierForPreference =
          ValueNotifier(userAccountsForPreference.firstOrNull);
      updateDrawerStatus(WalletDrawerStatus.openWalletPreference);
    }
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
    checkPreference();
    updateBodyListStatus(BodyListStatus.transactionList);
  }

  @override
  Future<void> setOnBoard() async {
    OnboardingGuideSheet.show(
      Coordinator.rootNavigatorKey.currentContext!,
      this,
      firstWallet: true,
    );
    // move(NavID.setupOnboard);
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

  Future<void> updateBtcPrice() async {}

  Future<void> loadUserSettings() async {
    final settings =
        await dataProviderManager.userSettingsDataProvider.getSettings();
    if (settings != null) {
      bitcoinUnitNotifier.value = settings.bitcoinUnit.toBitcoinUnit();
      hideEmptyUsedAddresses = settings.hideEmptyUsedAddresses;
      twoFactorAmountThresholdController.text =
          settings.twoFactorAmountThreshold.toString();
      acceptTermsAndConditions = settings.acceptTermsAndConditions;
    }
    datasourceStreamSinkAdd();
  }

  @override
  Future<void> updateBitcoinUnit(BitcoinUnit symbol) async {
    if (initialed) {
      final userSettings = await proton_api.bitcoinUnit(symbol: symbol);
      await dataProviderManager.userSettingsDataProvider
          .insertUpdate(userSettings);
      dataProviderManager.userSettingsDataProvider.updateBitcoinUnit(symbol);
      loadUserSettings();
    }
  }

  @override
  Future<void> updateWalletName(WalletModel walletModel, String newName) async {
    final SecretKey secretKey =
        await WalletManager.getWalletKey(walletModel.walletID);
    try {
      final String encryptedName =
          await WalletKeyHelper.encrypt(secretKey, newName);
      await proton_api.updateWalletName(
          walletId: walletModel.walletID, newName: encryptedName);
      walletListBloc.updateWalletName(walletModel, newName);
    } on BridgeError catch (e, stacktrace) {
      errorMessage = parseSampleDisplayError(e);
      logger.e("importWallet error: $e, stacktrace: $stacktrace");
    } catch (e) {
      errorMessage = e.toString();
    }
    if (errorMessage.isNotEmpty) {
      CommonHelper.showErrorDialog("updateWalletName failed: $errorMessage");
      errorMessage = "";
    }
  }

  @override
  Future<void> renameAccount(WalletModel walletModel, AccountModel accountModel,
      String newName) async {
    try {
      final SecretKey secretKey =
          await WalletManager.getWalletKey(walletModel.walletID);
      final ApiWalletAccount walletAccount =
          await proton_api.updateWalletAccountLabel(
              walletId: walletModel.walletID,
              walletAccountId: accountModel.accountID,
              newLabel: await WalletKeyHelper.encrypt(secretKey, newName));
      accountModel.label = base64Decode(walletAccount.label);
      accountModel.labelDecrypt = newName;
      await DBHelper.accountDao!.update(accountModel);
      walletListBloc.updateAccountName(walletModel, accountModel, newName);
    } on BridgeError catch (e, stacktrace) {
      errorMessage = parseSampleDisplayError(e);
      logger.e("importWallet error: $e, stacktrace: $stacktrace");
      Sentry.captureException(e, stackTrace: stacktrace);
    } catch (e) {
      errorMessage = e.toString();
    }
    if (errorMessage.isNotEmpty) {
      CommonHelper.showErrorDialog("updateWalletName failed: $errorMessage");
      errorMessage = "";
    }
  }

  @override
  Future<void> deleteAccount(
      WalletModel walletModel, AccountModel accountModel) async {
    if (initialed) {
      try {
        await proton_api.deleteWalletAccount(
            walletId: walletModel.walletID,
            walletAccountId: accountModel.accountID);
        await dataProviderManager.walletDataProvider
            .deleteWalletAccount(accountModel: accountModel);
      } on BridgeError catch (e, stacktrace) {
        errorMessage = parseSampleDisplayError(e);
        logger.e("importWallet error: $e, stacktrace: $stacktrace");
      } catch (e) {
        errorMessage = e.toString();
      }
      if (errorMessage.isNotEmpty) {
        CommonHelper.showErrorDialog("deleteAccount(): $errorMessage");
        errorMessage = "";
      }
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
  ProtonAddress? getProtonAddressByID(String addressID) {
    for (ProtonAddress protonAddress in protonAddresses) {
      if (protonAddress.id == addressID) {
        return protonAddress;
      }
    }
    return const ProtonAddress(
        id: 'default',
        domainId: '',
        email: 'default',
        status: 1,
        type: 1,
        receive: 1,
        send: 1,
        displayName: '');
  }

  @override
  Future<void> removeEmailAddressFromWalletAccount(
    WalletModel walletModel,
    AccountModel accountModel,
    String serverAddressID,
  ) async {
    try {
      final ApiWalletAccount walletAccount =
          await proton_api.removeEmailAddress(
        walletId: walletModel.walletID,
        walletAccountId: accountModel.accountID,
        addressId: serverAddressID,
      );
      bool deleted = true;
      for (ApiEmailAddress emailAddress in walletAccount.addresses) {
        if (emailAddress.id == serverAddressID) {
          deleted = false;
        }
      }
      if (deleted) {
        await WalletManager.deleteAddress(serverAddressID);
        walletListBloc.removeEmailIntegration(
            walletModel, accountModel, serverAddressID);
      }
    } on BridgeError catch (e, stacktrace) {
      errorMessage = parseSampleDisplayError(e);
      logger.e("importWallet error: $e, stacktrace: $stacktrace");
    } catch (e) {
      errorMessage = e.toString();
    }
    if (errorMessage.isNotEmpty) {
      CommonHelper.showErrorDialog(errorMessage);
      errorMessage = "";
    }
    datasourceStreamSinkAdd();
  }

  @override
  Future<void> logout() async {
    isLogout = true;
    EasyLoading.show(maskType: EasyLoadingMaskType.black);
    try {
      eventLoop.stop();
      await protonWalletManager.logout();
      await userManager.logout();
      await WalletManager.cleanBDKCache();
      try {
        userSettingProvider.destroy();
        protonWalletManager.destroy();
      } catch (e) {
        // no provider init for non eligible user
      }
      await WalletManager.cleanSharedPreference();
      await DBHelper.reset();
      await Future.delayed(
        const Duration(seconds: 3),
      ); // TODO(fix): fix await for DBHelper.reset();
    } on BridgeError catch (e, stacktrace) {
      errorMessage = parseSampleDisplayError(e);
      logger.e("importWallet error: $e, stacktrace: $stacktrace");
      Sentry.captureException(e, stackTrace: stacktrace);
    } catch (e) {
      errorMessage = e.toString();
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
        // walletView
        selectedWallet = walletMenuModel.walletModel;
        selectedAccount = null;
        isWalletView = true;
      }
      for (AccountMenuModel accountMenuModel in walletMenuModel.accounts) {
        if (accountMenuModel.isSelected) {
          // wallet account view
          selectedWallet = walletMenuModel.walletModel;
          selectedAccount = accountMenuModel.accountModel;
          isWalletView = false;
        }
      }
    }

    // TODO(fix): pass wallet server id and wallet account server id
    switch (to) {
      case NavID.importWallet:
        final preInputName = nameTextController.text;
        coordinator.showImportWallet(preInputName);
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
      case NavID.testWebsocket:
        coordinator.showWebSocket();
      case NavID.securitySetting:
        coordinator.showSecuritySetting();
      case NavID.welcome:
        coordinator.logout();
      case NavID.historyDetails:
        coordinator.showHistoryDetails(
          selectedWallet?.walletID ?? "",
          historyAccountModel?.accountID ?? "",
          selectedTXID,
          fiatCurrencyNotifier.value,
        );
      case NavID.twoFactorAuthSetup:
        coordinator.showTwoFactorAuthSetup();
      case NavID.twoFactorAuthDisable:
        coordinator.showTwoFactorAuthDisable();
      case NavID.setupBackup:
        coordinator.showSetupBackup(
          selectedWallet?.walletID ?? "",
        );
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
      default:
        break;
    }
  }

  @override
  Future<bool> addWalletAccount(
    int walletID,
    String serverWalletID,
    ScriptTypeInfo scriptType,
    String label,
    int accountIndex,
  ) async {
    try {
      await createWalletBloc.createWalletAccount(
        serverWalletID,
        scriptType,
        label,
        fiatCurrencyNotifier.value,
        accountIndex,
      );
    } on BridgeError catch (e, stacktrace) {
      errorMessage = parseSampleDisplayError(e);
      logger.e("importWallet error: $e, stacktrace: $stacktrace");
    } catch (e) {
      errorMessage = e.toString();
    }
    if (errorMessage.isNotEmpty) {
      if (errorMessage.toLowerCase() ==
          "You have reached the creation limit for this type of wallet account"
              .toLowerCase()) {
        errorMessage = "";
        final BuildContext? context =
            Coordinator.rootNavigatorKey.currentContext;
        if (context != null && context.mounted) {
          UpgradeIntroSheet.show(
            context,
            () async {
              await move(NavID.nativeUpgrade);
            },
            isWalletAccountExceedLimit: true,
          );
        }
        return false;
      }
      CommonHelper.showErrorDialog(errorMessage);
      errorMessage = "";
      return false;
    }
    return true;
  }

  @override
  Future<bool> addEmailAddressToWalletAccount(
    String serverWalletID,
    WalletModel walletModel,
    AccountModel accountModel,
    String serverAddressID,
  ) async {
    try {
      await WalletManager.addEmailAddress(
        serverWalletID,
        accountModel.accountID,
        serverAddressID,
      );
      walletListBloc.addEmailIntegration(
        walletModel,
        accountModel,
        serverAddressID,
      );
    } on BridgeError catch (e, stacktrace) {
      errorMessage = parseSampleDisplayError(e);
      logger.e("importWallet error: $e, stacktrace: $stacktrace");
    } catch (e) {
      errorMessage = e.toString();
    }
    if (errorMessage.isNotEmpty) {
      CommonHelper.showErrorDialog(errorMessage);
      errorMessage = "";
      datasourceStreamSinkAdd();
      return false;
    }
    datasourceStreamSinkAdd();
    return true;
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
  Map<String, ValueNotifier> getAccountFiatCurrencyNotifiers(
      List<AccountModel> userAccounts) {
    for (AccountModel accountModel in userAccounts) {
      if (!accountFiatCurrencyNotifiers.containsKey(accountModel.accountID)) {
        final ValueNotifier valueNotifier =
            ValueNotifier(WalletManager.getAccountFiatCurrency(accountModel));
        valueNotifier.addListener(() {
          updateWalletAccountFiatCurrency(accountModel, valueNotifier.value);
        });
        accountFiatCurrencyNotifiers[accountModel.accountID] = valueNotifier;
      }
    }
    return accountFiatCurrencyNotifiers;
  }

  Future<void> updateWalletAccountFiatCurrency(
    AccountModel accountModel,
    FiatCurrency newFiatCurrency,
  ) async {
    final WalletModel walletModel =
        await DBHelper.walletDao!.findByServerID(accountModel.walletID);

    final walletClient = apiServiceManager.getWalletClient();
    final walletAccount = await walletClient.updateWalletAccountFiatCurrency(
      walletId: walletModel.walletID,
      walletAccountId: accountModel.accountID,
      newFiatCurrency: newFiatCurrency,
    );

    accountModel.fiatCurrency = walletAccount.fiatCurrency.name.toUpperCase();
    await DBHelper.accountDao!.update(accountModel);
    walletListBloc.updateAccountFiat(
        walletModel, accountModel, newFiatCurrency.name.toUpperCase());
    walletBalanceBloc.handleTransactionUpdate();
  }

  Future<void> checkNetwork() async {
    final List<ConnectivityResult> connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) {
      if (!isShowingNoInternet) {
        isShowingNoInternet = true;
        EasyLoading.show(maskType: EasyLoadingMaskType.black);
      }
    } else {
      if (isShowingNoInternet) {
        isShowingNoInternet = false;
        EasyLoading.dismiss();
      }
    }
    await Future.delayed(const Duration(seconds: 1));
    if (!isLogout) {
      checkNetwork();
    }
  }

  @override
  Future<void> updatePassphrase(String key, String passphrase) async {}

  @override
  Future<bool> createWallet() async {
    WalletModel? walletModel;
    AccountModel? accountModel;
    try {
      bool isFirstWallet = false;
      final List<WalletData>? wallets =
          await walletListBloc.walletsDataProvider.getWallets();
      if (wallets == null) {
        isFirstWallet = true;
      } else if (wallets.isEmpty) {
        isFirstWallet = true;
      }

      final FrbMnemonic mnemonic = FrbMnemonic(wordCount: WordCount.words12);
      final String strMnemonic = mnemonic.asString();
      final String walletName = nameTextController.text;
      final String strPassphrase = passphraseTextController.text;

      final apiWallet = await createWalletBloc.createWallet(
        walletName,
        strMnemonic,
        appConfig.coinType.network,
        WalletModel.createByProton,
        strPassphrase,
      );

      // default Primary Account (without BvE)
      final _ = await createWalletBloc.createWalletAccount(
        apiWallet.wallet.id,
        appConfig.scriptTypeInfo,
        "Primary Account",
        fiatCurrencyNotifier.value,
        0, // default wallet account index
      );

      // Auto create Bitcoin via Email account at 84'/0'/1'
      if (isFirstWallet) {
        final apiWalletAccountBvE = await createWalletBloc.createWalletAccount(
          apiWallet.wallet.id,
          appConfig.scriptTypeInfo,
          "Bitcoin via Email",
          fiatCurrencyNotifier.value,
          1, // default wallet account index
        );
        final String walletID = apiWallet.wallet.id;
        walletModel = await DBHelper.walletDao!.findByServerID(walletID);

        final String accountID = apiWalletAccountBvE.id;
        accountModel = await DBHelper.accountDao!.findByServerID(accountID);
        if (walletModel != null && accountModel != null) {
          final ProtonAddress? protonAddress = protonAddresses.firstOrNull;
          if (protonAddress != null) {
            await addEmailAddressToWalletAccount(
              walletID,
              walletModel,
              accountModel,
              protonAddress.id,
            );
          }
        }
      }
    } on BridgeError catch (e, stacktrace) {
      final msg = parseSampleDisplayError(e);
      if (msg.toLowerCase() ==
          "You have reached the creation limit for this type of wallet"
              .toLowerCase()) {
        final BuildContext? context =
            Coordinator.rootNavigatorKey.currentContext;
        if (context != null && context.mounted) {
          UpgradeIntroSheet.show(context, () async {
            await move(NavID.nativeUpgrade);
          });
        }
        return false;
      }
      CommonHelper.showErrorDialog(msg);
      logger.e("importWallet error: $e, stacktrace: $stacktrace");
      Sentry.captureException(e, stackTrace: stacktrace);
      return false;
    } catch (e, stacktrace) {
      CommonHelper.showErrorDialog(e.toString());
      Sentry.captureException(e, stackTrace: stacktrace);
      return false;
    }
    return true;
    // no need to sync since it's brand new walllet
  }

  @override
  void updateBodyListStatus(BodyListStatus bodyListStatus) {
    this.bodyListStatus = bodyListStatus;
    datasourceStreamSinkAdd();
  }

  @override
  void updateTransactionListFilterBy(String filterBy) {
    transactionListFilterBy = filterBy;
    datasourceStreamSinkAdd();
  }

  @override
  void updateAddressListFilterBy(String filterBy) {
    addressListFilterBy = filterBy;
    datasourceStreamSinkAdd();
  }

  @override
  void setDisplayBalance({required bool display}) {
    displayBalance = display;
    datasourceStreamSinkAdd();
  }

  @override
  void loadProtonRecoveryState() {
    protonRecoveryBloc.add(LoadingRecovery());
  }
}
