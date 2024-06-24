//home.viewmodel.dart
import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet/components/discover/proton.feeditem.dart';
import 'package:wallet/constants/app.config.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/history.transaction.dart';
import 'package:wallet/constants/script_type.dart';
import 'package:wallet/helper/bdk/mnemonic.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/crypto.price.info.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/extension/enum.extension.dart';
import 'package:wallet/managers/api.service.manager.dart';
import 'package:wallet/managers/channels/native.view.channel.dart';
import 'package:wallet/managers/event.loop.manager.dart';
import 'package:wallet/helper/extension/stream.controller.dart';
import 'package:wallet/helper/user.settings.provider.dart';
import 'package:wallet/helper/walletkey_helper.dart';
import 'package:wallet/managers/features/models/wallet.list.dart';
import 'package:wallet/managers/features/wallet.balance.bloc.dart';
import 'package:wallet/managers/features/wallet.list.bloc.dart';
import 'package:wallet/managers/features/wallet.transaction.bloc.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/managers/wallet/proton.wallet.manager.dart';
import 'package:wallet/rust/api/proton_api.dart' as proton_api;
import 'package:wallet/rust/bdk/types.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/rust/proton_api/proton_address.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/rust/proton_api/wallet_account.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/home.v3/bottom.sheet/onboarding.guide.dart';
import 'package:wallet/scenes/home.v3/home.coordinator.dart';
import 'package:wallet/managers/services/crypto.price.service.dart';

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
    this.walletBloc,
    this.walletTransactionBloc,
    this.walletBalanceBloc,
    this.dataProviderManager,
  );

  CryptoPriceInfo btcPriceInfo = CryptoPriceInfo();

  int selectedPage = 0;

  late UserSettingProvider userSettingProvider;
  bool hasWallet = true;
  bool hasMailIntegration = false;
  bool isFetching = false;
  bool isLogout = false;
  int currentHistoryPage = 0;
  bool isShowingNoInternet = false;
  List<ProtonAddress> protonAddresses = [];
  WalletModel? walletForPreference;
  List userAccountsForPreference = [];
  AccountModel? historyAccountModel;
  BodyListStatus bodyListStatus = BodyListStatus.transactionList;

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
  TextEditingController walletPreferenceTextEditingController =
      TextEditingController(text: "");

  bool initialed = false;
  String errorMessage = "";
  List<HistoryTransaction> historyTransactions = [];

  Map<String, ValueNotifier> getAccountFiatCurrencyNotifiers(
      List<AccountModel> userAccounts);

  void updateBitcoinUnit(BitcoinUnit symbol);

  void updateBodyListStatus(BodyListStatus bodyListStatus);

  void setSearchHistoryTextField(bool show);

  Future<void> createWallet();

  Future<void> deleteWallet(WalletModel walletModel);

  // ApiUserSettings? userSettings;
  late TextEditingController hideEmptyUsedAddressesController;
  late TextEditingController twoFactorAmountThresholdController;

  bool hideEmptyUsedAddresses = false;
  bool hadBackup = false;
  bool hadBackupProtonAccount = false;
  bool hadSetup2FA = false;
  bool showSearchHistoryTextField = false;

  void setOnBoard();

  void selectWallet(WalletMenuModel walletMenuModel);

  void selectAccount(
      WalletMenuModel walletMenuModel, AccountMenuModel accountMenuModel);

  void showMoreTransactionHistory();

  Future<void> addWalletAccount(
      int walletID, ScriptType scriptType, String label);

  void checkPreference(WalletModel walletModel);

  void updateDrawerStatus(WalletDrawerStatus walletDrawerStatus);

  void openWalletPreference(int walletID);

  void checkProtonAddresses();

  Future<void> renameAccount(
      WalletModel walletModel, AccountModel accountModel, String newName);

  Future<void> deleteAccount(
      WalletModel walletModel, AccountModel accountModel);

  Future<void> addEmailAddressToWalletAccount(
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

  late FocusNode newAccountNameFocusNode;
  late FocusNode walletRecoverPassphraseFocusNode;
  List<ProtonFeedItem> protonFeedItems = [];
  late TextEditingController newAccountNameController;
  late TextEditingController walletRecoverPassphraseController;
  late ValueNotifier newAccountScriptTypeValueNotifier;

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

  Future<void> updatePassphrase(String key, String passphrase);

  void updateTransactionListFilterBy(String filterBy);

  //
  final WalletListBloc walletBloc;
  final WalletTransactionBloc walletTransactionBloc;
  final WalletBalanceBloc walletBalanceBloc;
  final DataProviderManager dataProviderManager;
  BitcoinUnit bitcoinUnit = BitcoinUnit.btc;
  ProtonExchangeRate currentExchangeRate = const ProtonExchangeRate(
      id: 'default',
      bitcoinUnit: BitcoinUnit.btc,
      fiatCurrency: defaultFiatCurrency,
      exchangeRateTime: '',
      exchangeRate: 1,
      cents: 1);
}

class HomeViewModelImpl extends HomeViewModel {
  HomeViewModelImpl(
    super.coordinator,
    this.userManager,
    this.eventLoop,
    this.protonWalletManager,
    this.apiServiceManager,
    super.dataProviderManager,
    super.walletBloc,
    super.walletTransactionBloc,
    super.walletBalanceBloc,
    this.channel,
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

  ///
  final datasourceChangedStreamController =
      StreamController<HomeViewModel>.broadcast();
  final selectedSectionChangedController = StreamController<int>.broadcast();

  CryptoPriceDataService cryptoPriceDataService =
      CryptoPriceDataService(duration: const Duration(seconds: 10));
  late StreamSubscription _subscription;

  @override
  void dispose() {
    datasourceChangedStreamController.close();
    selectedSectionChangedController.close();
    //clean up wallet ....
    disposeServices();
    super.dispose();
  }

  void datasourceStreamSinkAdd() {
    datasourceChangedStreamController.sinkAddSafe(this);
  }

  Future<void> initServices() async {
    // crypto price listener
    _subscription =
        cryptoPriceDataService.dataStream.listen((CryptoPriceInfo event) {
      btcPriceInfo = event;
      datasourceStreamSinkAdd();
    });
  }

  void disposeServices() {
    _subscription.cancel();
    cryptoPriceDataService.dispose();
  }

  Future<void> initControllers() async {
    hideEmptyUsedAddressesController = TextEditingController();
    twoFactorAmountThresholdController = TextEditingController(text: "3");
    newAccountNameController = TextEditingController(text: "My wallet account");
    newAccountScriptTypeValueNotifier = ValueNotifier(appConfig.scriptType);
    walletRecoverPassphraseController = TextEditingController(text: "");
    passphraseTextController = TextEditingController(text: "");
    passphraseConfirmTextController = TextEditingController(text: "");
    nameTextController = TextEditingController();

    walletRecoverPassphraseFocusNode = FocusNode();
    newAccountNameFocusNode = FocusNode();
    passphraseFocusNode = FocusNode();
    passphraseConfirmFocusNode = FocusNode();
    nameFocusNode = FocusNode();
  }

  Future<void> preloadSettings() async {
    await dataProviderManager.userSettingsDataProvider.preLoad();
    loadUserSettings();
  }

  Future<void> loadwallet() async {
    hasWallet = await WalletManager.hasWallet();
    if (hasWallet == false) {
      await WalletManager.fetchWalletsFromServer();
      hasWallet = await WalletManager.hasWallet();
    }
  }

  @override
  Future<void> loadData() async {
    // init network
    await apiServiceManager.initalOldApiService();

    // user
    var userInfo = userManager.userInfo;
    userEmail = userInfo.userMail;
    displayName = userInfo.userDisplayName;
    protonWalletManager.login(userInfo.userId);
    // build up the data provider. providers are used after login.

    // ----------------
    // settings

    // transactions

    /// init services
    initServices();

    /// init controllers
    initControllers();

    try {
      userSettingProvider = Provider.of<UserSettingProvider>(
          Coordinator.rootNavigatorKey.currentContext!,
          listen: false);

      loadwallet();
      loadUserSettings();
      walletBloc.init(callback: () {
        for (WalletMenuModel walletMenuModel in walletBloc.state.walletsModel) {
          if (walletMenuModel.isSelected) {
            walletBalanceBloc.selectWallet(walletMenuModel);
            walletTransactionBloc.selectWallet(walletMenuModel);
            break;
          }
          bool isSelectedAccount = false;
          for (AccountMenuModel accountMenuModel in walletMenuModel.accounts) {
            if (accountMenuModel.isSelected) {
              isSelectedAccount = true;
              walletBalanceBloc.selectAccount(
                  walletMenuModel, accountMenuModel);
              walletTransactionBloc.selectAccount(
                  walletMenuModel, accountMenuModel);
              break;
            }
          }
          if (isSelectedAccount) {
            break;
          }
        }
      });

      // async
      dataProviderManager.contactsDataProvider.preLoad();
      dataProviderManager.userSettingsDataProvider.preLoad();
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

      cryptoPriceDataService.start(); //start service
      // checkNetwork();
      loadDiscoverContents();
      checkProtonAddresses();

      bitcoinUnitNotifier.addListener(() async {
        updateBitcoinUnit(bitcoinUnitNotifier.value);
        userSettingProvider.updateBitcoinUnit(bitcoinUnitNotifier.value);
      });

      transactionSearchController.addListener((){
        datasourceStreamSinkAdd();
      });

      eventLoop.start();

      /// TODO:: check preference
      // checkPreference();
    } catch (e) {
      errorMessage = e.toString();
    }
    if (errorMessage.isNotEmpty) {
      CommonHelper.showErrorDialog("App init: $errorMessage");
      errorMessage = "";
    } else {
      initialed = true;
      if (hasWallet == false) {
        setOnBoard();
      }
    }
    datasourceStreamSinkAdd();
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  Future<void> loadDiscoverContents() async {
    protonFeedItems = await ProtonFeedItem.loadJsonFromAsset();
  }

  @override
  void checkProtonAddresses() async {
    List<ProtonAddress> addresses = await proton_api.getProtonAddress();
    protonAddresses =
        addresses.where((element) => element.status == 1).toList();
    emailIntegrationNotifier = ValueNotifier(protonAddresses.first);
    datasourceStreamSinkAdd();
  }

  @override
  void openWalletPreference(int walletID) async {
    walletForPreference = await DBHelper.walletDao!.findById(walletID);
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
    walletBloc.selectWallet(walletMenuModel.walletModel);
    walletBalanceBloc.selectWallet(walletMenuModel);
    walletTransactionBloc.selectWallet(walletMenuModel);
  }

  @override
  Future<void> selectAccount(WalletMenuModel walletMenuModel,
      AccountMenuModel accountMenuModel) async {
    walletBloc.selectAccount(
        walletMenuModel.walletModel, accountMenuModel.accountModel);
    walletBalanceBloc.selectAccount(walletMenuModel, accountMenuModel);
    walletTransactionBloc.selectAccount(walletMenuModel, accountMenuModel);
  }

  @override
  void setOnBoard() async {
    hasWallet = true;
    OnboardingGuideSheet.show(
        Coordinator.rootNavigatorKey.currentContext!, this);
    // move(NavID.setupOnboard);
  }

  @override
  void showMoreTransactionHistory() {
    currentHistoryPage++;
    datasourceStreamSinkAdd();
  }

  Future<void> updateBtcPrice() async {}

  Future<void> loadUserSettings() async {
    var settings =
        await dataProviderManager.userSettingsDataProvider.getSettings();
    if (settings != null) {
      bitcoinUnitNotifier.value = settings.bitcoinUnit.toBitcoinUnit();
      hideEmptyUsedAddresses = settings.hideEmptyUsedAddresses;
      twoFactorAmountThresholdController.text =
          settings.twoFactorAmountThreshold.toString();
    }
    datasourceStreamSinkAdd();
  }

  @override
  Future<void> updateBitcoinUnit(BitcoinUnit symbol) async {
    if (initialed) {
      var userSettings = await proton_api.bitcoinUnit(symbol: symbol);
      await dataProviderManager.userSettingsDataProvider
          .insertUpdate(userSettings);
      loadUserSettings();
    }
  }

  @override
  Future<void> updateWalletName(WalletModel walletModel, String newName) async {
    SecretKey secretKey =
        await WalletManager.getWalletKey(walletModel.serverWalletID);
    try {
      String encryptedName = await WalletKeyHelper.encrypt(secretKey, newName);
      await proton_api.updateWalletName(
          walletId: walletModel.serverWalletID, newName: encryptedName);
      walletBloc.updateWalletName(walletModel, newName);
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
      SecretKey secretKey =
          await WalletManager.getWalletKey(walletModel.serverWalletID);
      ApiWalletAccount walletAccount =
          await proton_api.updateWalletAccountLabel(
              walletId: walletModel.serverWalletID,
              walletAccountId: accountModel.serverAccountID,
              newLabel: await WalletKeyHelper.encrypt(secretKey, newName));
      accountModel.label = base64Decode(walletAccount.label);
      accountModel.labelDecrypt = newName;
      await DBHelper.accountDao!.update(accountModel);
      walletBloc.updateAccountName(walletModel, accountModel, newName);
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
      EasyLoading.show(
          status: "deleting account..", maskType: EasyLoadingMaskType.black);
      try {
        await proton_api.deleteWalletAccount(
            walletId: walletModel.serverWalletID,
            walletAccountId: accountModel.serverAccountID);
        await dataProviderManager.walletDataProvider
            .deleteWalletAccount(accountModel: accountModel);
      } catch (e) {
        errorMessage = e.toString();
      }
      EasyLoading.dismiss();
      if (errorMessage.isNotEmpty) {
        CommonHelper.showErrorDialog("deleteAccount(): $errorMessage");
        errorMessage = "";
      }
    }
    datasourceStreamSinkAdd();
  }

  @override
  Future<void> checkPreference(WalletModel walletModel,
      {bool runOnce = false}) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String serverWalletID = walletModel.serverWalletID;
    hadBackup = preferences.getBool("todo_hadBackup_$serverWalletID") ?? false;
    currentTodoStep = 0;
    currentTodoStep += hadBackup ? 1 : 0;
    currentTodoStep += hadBackupProtonAccount ? 1 : 0;
    currentTodoStep += hadSetup2FA ? 1 : 0;
    datasourceStreamSinkAdd();

    if (runOnce == false) {
      await Future.delayed(const Duration(seconds: 1));
      if (isLogout == false) {
        checkPreference(walletModel);
      }
    }
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
  Future<void> removeEmailAddressFromWalletAccount(WalletModel walletModel,
      AccountModel accountModel, String serverAddressID,
      {bool isTriedRemove = false}) async {
    if (isTriedRemove == false) {
      EasyLoading.show(
          status: "removing email..", maskType: EasyLoadingMaskType.black);
    } else {
      EasyLoading.show(
          status:
              "email already in used, try removing previous email binding..",
          maskType: EasyLoadingMaskType.black);
    }
    try {
      ApiWalletAccount walletAccount = await proton_api.removeEmailAddress(
          walletId: walletModel.serverWalletID,
          walletAccountId: accountModel.serverAccountID,
          addressId: serverAddressID);
      bool deleted = true;
      for (ApiEmailAddress emailAddress in walletAccount.addresses) {
        if (emailAddress.id == serverAddressID) {
          deleted = false;
        }
      }
      if (deleted) {
        await WalletManager.deleteAddress(serverAddressID);
        walletBloc.removeEmailIntegration(
            walletModel, accountModel, serverAddressID);
      }
    } catch (e) {
      errorMessage = e.toString();
    }
    EasyLoading.dismiss();
    if (errorMessage.isNotEmpty) {
      CommonHelper.showErrorDialog(errorMessage);
      errorMessage = "";
    }
    datasourceStreamSinkAdd();
  }

  @override
  Future<void> logout() async {
    isLogout = true;
    EasyLoading.show(
        status: "log out, cleaning cache..",
        maskType: EasyLoadingMaskType.black);
    try {
      eventLoop.stop();
      await protonWalletManager.logout();
      await userManager.logout();
      await WalletManager.cleanBDKCache();
      userSettingProvider.destroy();
      protonWalletManager.destroy();
      await WalletManager.cleanSharedPreference();
      await DBHelper.reset();
      await Future.delayed(
          const Duration(seconds: 3)); // TODO:: fix await for DBHelper.reset();
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
  Future<void> deleteWallet(WalletModel walletModel) async {
    EasyLoading.show(
        status: "deleting wallet..", maskType: EasyLoadingMaskType.black);
    try {
      await proton_api.deleteWallet(walletId: walletModel.serverWalletID);
      await dataProviderManager.walletDataProvider
          .deleteWallet(wallet: walletModel);
    } catch (e) {
      errorMessage = e.toString();
    }
    EasyLoading.dismiss();
  }

  @override
  Future<void> move(NavID to) async {
    WalletModel? selectedWallet;
    AccountModel? selectedAccount;
    for (WalletMenuModel walletMenuModel in walletBloc.state.walletsModel) {
      if (walletMenuModel.isSelected) {
        // walletView
        selectedWallet = walletMenuModel.walletModel;
        selectedAccount = null;
      }
      for (AccountMenuModel accountMenuModel in walletMenuModel.accounts) {
        if (accountMenuModel.isSelected) {
          // wallet account view
          selectedWallet = walletMenuModel.walletModel;
          selectedAccount = accountMenuModel.accountModel;
        }
      }
    }

    /// TODO:: pass wallet server id and wallet account server id
    switch (to) {
      case NavID.importWallet:
        coordinator.showImportWallet();
        break;
      case NavID.send:
        coordinator.showSend(selectedWallet?.id ?? 0, selectedAccount?.id ?? 0);
        break;
      case NavID.receive:
        coordinator.showReceive(
            selectedWallet?.id ?? 0, selectedAccount?.id ?? 0);
        break;
      case NavID.testWebsocket:
        coordinator.showWebSocket();
        break;
      case NavID.securitySetting:
        coordinator.showSecuritySetting();
        break;
      case NavID.welcome:
        coordinator.logout();
        break;
      case NavID.historyDetails:
        coordinator.showHistoryDetails(
            selectedWallet?.id ?? 0,
            historyAccountModel?.id ?? 0,
            selectedTXID,
            fiatCurrencyNotifier.value);
        break;
      case NavID.twoFactorAuthSetup:
        coordinator.showTwoFactorAuthSetup();
        break;
      case NavID.twoFactorAuthDisable:
        coordinator.showTwoFactorAuthDisable();
        break;
      case NavID.setupBackup:
        coordinator.showSetupBackup(selectedWallet?.id ?? 0);
        break;
      case NavID.discover:
        coordinator.showDiscover();
        break;
      case NavID.buy:
        coordinator.showBuy();
        break;
      case NavID.nativeUpgrade:
        final session = await userManager.getChildSession();
        coordinator.showNativeUpgrade(session);
        break;
      case NavID.natvieReportBugs:
        coordinator.showNativeReportBugs();
        break;
      default:
        break;
    }
  }

  @override
  Future<void> addWalletAccount(
      int walletID, ScriptType scriptType, String label) async {
    EasyLoading.show(
        status: "Adding account..", maskType: EasyLoadingMaskType.black);
    try {
      await dataProviderManager.walletDataProvider.createWalletAccount(
          walletID, scriptType, label, fiatCurrencyNotifier.value);
    } catch (e) {
      errorMessage = e.toString();
    }
    if (errorMessage.isNotEmpty) {
      BuildContext? context = Coordinator.rootNavigatorKey.currentContext;
      if (context != null && context.mounted) {
        CommonHelper.showSnackbar(context, errorMessage, isError: true);
      }
      errorMessage = "";
    }
    EasyLoading.dismiss();
  }

  @override
  Future<void> addEmailAddressToWalletAccount(
    String serverWalletID,
    WalletModel walletModel,
    AccountModel accountModel,
    String serverAddressID,
  ) async {
    EasyLoading.show(
        status: "adding email..", maskType: EasyLoadingMaskType.black);
    try {
      await WalletManager.addEmailAddress(
          serverWalletID, accountModel.serverAccountID, serverAddressID);
      walletBloc.addEmailIntegration(
          walletModel, accountModel, serverAddressID);
    } catch (e) {
      errorMessage = e.toString();
    }
    EasyLoading.dismiss();
    if (errorMessage.isNotEmpty) {
      CommonHelper.showErrorDialog(errorMessage);
      errorMessage = "";
    }
    datasourceStreamSinkAdd();
  }

  @override
  void setSearchHistoryTextField(bool show) {
    if (show == false) {
      if (transactionSearchController.text.isNotEmpty) {
        transactionSearchController.text = "";
      }
    }
    showSearchHistoryTextField = show;
    datasourceStreamSinkAdd();
  }

  @override
  Map<String, ValueNotifier> getAccountFiatCurrencyNotifiers(
      List<AccountModel> userAccounts) {
    for (AccountModel accountModel in userAccounts) {
      if (accountFiatCurrencyNotifiers
              .containsKey(accountModel.serverAccountID) ==
          false) {
        ValueNotifier valueNotifier =
            ValueNotifier(WalletManager.getAccountFiatCurrency(accountModel));
        valueNotifier.addListener(() {
          updateWalletAccountFiatCurrency(accountModel, valueNotifier.value);
        });
        accountFiatCurrencyNotifiers[accountModel.serverAccountID] =
            valueNotifier;
      }
    }
    return accountFiatCurrencyNotifiers;
  }

  Future<void> updateWalletAccountFiatCurrency(
      AccountModel accountModel, FiatCurrency newFiatCurrency) async {
    WalletModel walletModel =
        await DBHelper.walletDao!.findById(accountModel.walletID);
    ApiWalletAccount walletAccount =
        await proton_api.updateWalletAccountFiatCurrency(
            walletId: walletModel.serverWalletID,
            walletAccountId: accountModel.serverAccountID,
            newFiatCurrency: newFiatCurrency);
    accountModel.fiatCurrency = walletAccount.fiatCurrency.name.toUpperCase();
    await DBHelper.accountDao!.update(accountModel);
    walletBloc.updateAccountFiat(
        walletModel, accountModel, newFiatCurrency.name.toUpperCase());
  }

  Future<void> checkNetwork() async {
    List<ConnectivityResult> connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) {
      if (isShowingNoInternet == false) {
        isShowingNoInternet = true;
        EasyLoading.show(
            status: "waiting for connection..",
            maskType: EasyLoadingMaskType.black);
      }
    } else {
      if (isShowingNoInternet) {
        isShowingNoInternet = false;
        EasyLoading.dismiss();
      }
    }
    await Future.delayed(const Duration(seconds: 1));
    if (isLogout == false) {
      checkNetwork();
    }
  }

  @override
  Future<void> updatePassphrase(String key, String passphrase) async {}

  @override
  Future<void> createWallet() async {
    try {
      Mnemonic mnemonic = await Mnemonic.create(WordCount.words12);
      String strMnemonic = mnemonic.asString();
      String walletName = nameTextController.text;
      String strPassphrase = passphraseTextController.text;
      await dataProviderManager.walletDataProvider.createWallet(
          walletName,
          strMnemonic,
          WalletModel.importByUser,
          defaultFiatCurrency,

          /// TODO:: use fiat from user selection
          strPassphrase);
      await Future.delayed(
          const Duration(seconds: 1)); // wait for account show on sidebar
    } catch (e) {
      errorMessage = e.toString();
    }
  }

  @override
  void updateBodyListStatus(BodyListStatus bodyListStatus) {
    this.bodyListStatus = bodyListStatus;
    datasourceStreamSinkAdd();
  }

  @override
  void updateTransactionListFilterBy(String filterBy){
    transactionListFilterBy = filterBy;
    datasourceStreamSinkAdd();
  }
}
