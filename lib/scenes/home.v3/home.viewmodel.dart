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
import 'package:wallet/constants/env.dart';
import 'package:wallet/constants/history.transaction.dart';
import 'package:wallet/constants/script_type.dart';
import 'package:wallet/helper/bdk/mnemonic.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/crypto.price.info.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/managers/api.service.manager.dart';
import 'package:wallet/managers/event.loop.manager.dart';
import 'package:wallet/helper/extension/stream.controller.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/helper/user.settings.provider.dart';
import 'package:wallet/helper/walletkey_helper.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/managers/wallet/proton.wallet.manager.dart';
import 'package:wallet/rust/api/proton_api.dart' as proton_api;
import 'package:wallet/rust/bdk/types.dart';
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

abstract class HomeViewModel extends ViewModel<HomeCoordinator> {
  HomeViewModel(super.coordinator, this.apiEnv);

  ApiEnv apiEnv;

  CryptoPriceInfo btcPriceInfo = CryptoPriceInfo();

  int selectedPage = 0;

  late UserSettingProvider userSettingProvider;
  late ProtonWalletProvider protonWalletProvider;
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

  Map<int, TextEditingController> accountNameControllers = {};
  Map<int, ValueNotifier> accountFiatCurrencyNotifiers = {};

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

  void getUserSettings();

  Map<int, TextEditingController> getAccountNameControllers(
      List<AccountModel> userAccounts);

  Map<int, ValueNotifier> getAccountFiatCurrencyNotifiers(
      List<AccountModel> userAccounts);

  void updateBitcoinUnit(BitcoinUnit symbol);

  void saveUserSettings();

  void setSearchHistoryTextField(bool show);

  Future<void> createWallet();
  Future<void> deleteWallet(WalletModel walletModel);

  ApiUserSettings? userSettings;
  late TextEditingController hideEmptyUsedAddressesController;
  late TextEditingController twoFactorAmountThresholdController;
  late TextEditingController walletNameController;

  bool hideEmptyUsedAddresses = false;
  bool hadBackup = false;
  bool hadBackupProtonAccount = false;
  bool hadSetup2FA = false;
  bool showSearchHistoryTextField = false;

  void setOnBoard();

  void selectWallet(WalletModel walletModel);

  void selectAccount(WalletModel walletModel, AccountModel accountModel);

  void showMoreTransactionHistory();

  Future<void> addWalletAccount(
      int walletID, ScriptType scriptType, String label);

  void checkPreference();

  void updateDrawerStatus(WalletDrawerStatus walletDrawerStatus);

  void openWalletPreference(int walletID);

  void checkProtonAddresses();

  Future<void> renameAccount(AccountModel accountModel, String newName);

  Future<void> deleteAccount(
      WalletModel walletModel, AccountModel accountModel);

  Future<void> addEmailAddressToWalletAccount(
      String serverWalletID, String serverAccountID, String serverAddressID);

  Future<void> removeEmailAddress(
      String serverWalletID, String serverAccountID, String serverAddressID);

  Future<void> updateWalletName(String serverWalletID, String newName);

  ProtonAddress? getProtonAddressByID(String addressID);

  int totalTodoSteps = 3;
  int currentTodoStep = 0;
  WalletDrawerStatus walletDrawerStatus = WalletDrawerStatus.close;

  String selectedTXID = "";
  bool isWalletPassphraseMatch = true;
  bool isValidToken = false;

  late FocusNode newAccountNameFocusNode;
  late FocusNode walletNameFocusNode;
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

  Future<void> logout();

  String userEmail = "";
  String displayName = "";

  Future<void> updatePassphrase(String key, String passphrase);
}

class HomeViewModelImpl extends HomeViewModel {
  HomeViewModelImpl(super.coordinator, super.apiEnv, this.userManager,
      this.eventLoop, this.protonWalletManager, this.apiServiceManager);

  // user manager
  final UserManager userManager;

  // event loop manger
  final EventLoop eventLoop;

  // wallet mangaer
  final ProtonWalletManager protonWalletManager;

  // networking
  final ProtonApiServiceManager apiServiceManager;

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

  @override
  Future<void> loadData() async {
    await apiServiceManager.initalOldApiService();
    var userInfo = userManager.userInfo;
    userEmail = userInfo.userMail;
    displayName = userInfo.userDisplayName;
    initServices();
    EasyLoading.show(
        status: "connecting to proton..", maskType: EasyLoadingMaskType.black);
    try {
      hideEmptyUsedAddressesController = TextEditingController();
      walletNameController = TextEditingController(text: "");
      twoFactorAmountThresholdController = TextEditingController(text: "3");
      newAccountNameController = TextEditingController(text: "BTC Account");
      newAccountScriptTypeValueNotifier = ValueNotifier(appConfig.scriptType);
      walletRecoverPassphraseController = TextEditingController(text: "");
      passphraseTextController = TextEditingController(text: "");
      passphraseConfirmTextController = TextEditingController(text: "");
      nameTextController = TextEditingController();

      walletRecoverPassphraseFocusNode = FocusNode();
      newAccountNameFocusNode = FocusNode();
      walletNameFocusNode = FocusNode();
      passphraseFocusNode = FocusNode();
      passphraseConfirmFocusNode = FocusNode();
      nameFocusNode = FocusNode();

      userSettingProvider = Provider.of<UserSettingProvider>(
          Coordinator.navigatorKey.currentContext!,
          listen: false);
      await Future.delayed(const Duration(
          seconds:
              1)); // TODO:: replace this workaround, we need to wait some time for rust to init api service
      isValidToken = await WalletManager.isValidToken();
      if (isValidToken) {
        await getUserSettings();
        hasWallet = await WalletManager.hasWallet();
        if (hasWallet == false) {
          await WalletManager.fetchWalletsFromServer();
          hasWallet = await WalletManager.hasWallet();
        }

        protonWalletProvider = Provider.of<ProtonWalletProvider>(
            Coordinator.navigatorKey.currentContext!,
            listen: false);
        protonWalletProvider.destroy();
        protonWalletProvider.addListener(() async {
          walletNameController.text =
              protonWalletProvider.protonWallet.currentWallet?.name ?? "";
        });
        await protonWalletProvider.init();

        WalletManager.initContacts();
        eventLoop.start();

        cryptoPriceDataService.start(); //start service
        checkNetwork();
        loadDiscoverContents();
        checkProtonAddresses();
        fiatCurrencyNotifier.addListener(() async {
          protonWalletProvider.protonWallet.newAccountFiatCurrency =
              fiatCurrencyNotifier.value;
        });
        bitcoinUnitNotifier.addListener(() async {
          updateBitcoinUnit(bitcoinUnitNotifier.value);
          userSettingProvider.updateBitcoinUnit(bitcoinUnitNotifier.value);
        });

        transactionSearchController.addListener(() {
          protonWalletProvider.applyHistoryTransactionFilterAndKeyword(
              protonWalletProvider.protonWallet.transactionFilter,
              transactionSearchController.text);
        });
        checkPreference();
      } else {
        errorMessage =
            "Muon token expired, please logout then login again. (This will be fix after muon v2)";
      }
    } catch (e) {
      errorMessage = e.toString();
    }
    EasyLoading.dismiss();
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
  Future<void> selectWallet(WalletModel walletModel) async {
    if ((protonWalletProvider.protonWallet.currentWallet != null &&
            protonWalletProvider.protonWallet.currentWallet!.serverWalletID !=
                walletModel.serverWalletID) ||
        protonWalletProvider.protonWallet.currentWallet == null ||
        protonWalletProvider.protonWallet.currentAccount != null) {
      transactionSearchController.text = "";
      currentHistoryPage = 0;
      await protonWalletProvider.setWallet(walletModel);
      walletNameController.text =
          protonWalletProvider.protonWallet.currentWallet?.name ?? "";
      checkPreference(runOnce: true);
      datasourceStreamSinkAdd();
    }
  }

  @override
  Future<void> selectAccount(
      WalletModel walletModel, AccountModel accountModel) async {
    if ((protonWalletProvider.protonWallet.currentAccount != null &&
            protonWalletProvider.protonWallet.currentAccount!.serverAccountID !=
                accountModel.serverAccountID) ||
        protonWalletProvider.protonWallet.currentAccount == null) {
      transactionSearchController.text = "";
      currentHistoryPage = 0;
      await protonWalletProvider.setWalletAccount(walletModel, accountModel);
      walletNameController.text =
          protonWalletProvider.protonWallet.currentWallet?.name ?? "";
      checkPreference(runOnce: true);
      datasourceStreamSinkAdd();
    }
  }

  @override
  void setOnBoard() async {
    hasWallet = true;
    OnboardingGuideSheet.show(Coordinator.navigatorKey.currentContext!, this);
    // move(NavID.setupOnboard);
  }

  @override
  void showMoreTransactionHistory() {
    currentHistoryPage++;
    datasourceStreamSinkAdd();
  }

  Future<void> updateBtcPrice() async {}

  @override
  Future<void> getUserSettings() async {
    userSettings = await proton_api.getUserSettings();
    loadUserSettings();
  }

  void loadUserSettings() {
    if (userSettings != null) {
      bitcoinUnitNotifier.value = userSettings!.bitcoinUnit;
      hideEmptyUsedAddresses = userSettings!.hideEmptyUsedAddresses == 1;
      int twoFactorAmountThreshold =
          userSettings!.twoFactorAmountThreshold ?? 1000;
      twoFactorAmountThresholdController.text =
          twoFactorAmountThreshold.toString();
    }
    datasourceStreamSinkAdd();
  }

  @override
  Future<void> saveUserSettings() async {
    if (initialed) {
      hideEmptyUsedAddresses = hideEmptyUsedAddressesController.text == "On";
      int twoFactorAmountThreshold =
          int.parse(twoFactorAmountThresholdController.text);
      BitcoinUnit bitcoinUnit = bitcoinUnitNotifier.value;

      userSettings = await proton_api.hideEmptyUsedAddresses(
          hideEmptyUsedAddresses: hideEmptyUsedAddresses);
      userSettings =
          await proton_api.twoFaThreshold(amount: twoFactorAmountThreshold);
      userSettings = await proton_api.bitcoinUnit(symbol: bitcoinUnit);
      userSettings = await proton_api.fiatCurrency(
          symbol: defaultFiatCurrency); // TODO:: remove this from user setting

      loadUserSettings();
      await WalletManager.saveUserSetting(userSettings!);
    }
  }

  @override
  Future<void> updateBitcoinUnit(BitcoinUnit symbol) async {
    if (initialed) {
      userSettings = await proton_api.bitcoinUnit(symbol: symbol);
      datasourceStreamSinkAdd();
    }
  }

  @override
  Future<void> renameAccount(AccountModel accountModel, String newName) async {
    WalletModel? currentWallet =
        protonWalletProvider.protonWallet.currentWallet;
    logger.i("currentWallet.name = ${currentWallet?.name}");
    try {
      SecretKey secretKey =
          await protonWalletManager.getWalletKey(currentWallet!.serverWalletID);
      WalletAccount walletAccount = await proton_api.updateWalletAccountLabel(
          walletId: currentWallet.serverWalletID,
          walletAccountId: accountModel.serverAccountID,
          newLabel: await WalletKeyHelper.encrypt(secretKey, newName));
      accountModel.label = base64Decode(walletAccount.label);
      accountModel.labelDecrypt = newName;
      await DBHelper.accountDao!.update(accountModel);
      await protonWalletProvider.insertOrUpdateWalletAccount(accountModel);
    } catch (e) {
      logger.e(e);
    }
  }

  @override
  Future<void> deleteAccount(
      WalletModel walletModel, AccountModel accountModel) async {
    if (initialed) {
      EasyLoading.show(
          status: "deleting account..", maskType: EasyLoadingMaskType.black);
      try {
        await WalletManager.deleteWalletAccount(walletModel, accountModel);
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
  Future<void> checkPreference({bool runOnce = false}) async {
    WalletModel? currentWallet =
        protonWalletProvider.protonWallet.currentWallet;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (currentWallet != null) {
      String serverWalletID = currentWallet.serverWalletID;
      hadBackup =
          preferences.getBool("todo_hadBackup_$serverWalletID") ?? false;
      currentTodoStep = 0;
      currentTodoStep += hadBackup ? 1 : 0;
      currentTodoStep += hadBackupProtonAccount ? 1 : 0;
      currentTodoStep += hadSetup2FA ? 1 : 0;
      datasourceStreamSinkAdd();
    }

    if (runOnce == false) {
      await Future.delayed(const Duration(seconds: 1));
      if (isLogout == false) {
        checkPreference();
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
  Future<void> removeEmailAddress(
      String serverWalletID, String serverAccountID, String serverAddressID,
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
      WalletAccount walletAccount = await proton_api.removeEmailAddress(
          walletId: serverWalletID,
          walletAccountId: serverAccountID,
          addressId: serverAddressID);
      bool deleted = true;
      for (EmailAddress emailAddress in walletAccount.addresses) {
        if (emailAddress.id == serverAddressID) {
          deleted = false;
        }
      }
      if (deleted) {
        await WalletManager.deleteAddress(serverAddressID);
      }
      AccountModel accountModel =
          await DBHelper.accountDao!.findByServerAccountID(serverAccountID);
      await protonWalletProvider.setIntegratedEmailIDs(accountModel);
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
      await userManager.logout();
      await WalletManager.cleanBDKCache();
      await DBHelper.reset();
      protonWalletProvider.destroy();
      userSettingProvider.destroy();
      protonWalletManager.destroy();
      await WalletManager.cleanSharedPreference();
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
    coordinator.logout();
  }

  @override
  Future<void> deleteWallet(WalletModel walletModel) async {
    EasyLoading.show(
        status: "deleting wallet..", maskType: EasyLoadingMaskType.black);
    try {
      await proton_api.deleteWallet(walletId: walletModel.serverWalletID);
      await WalletManager.deleteWallet(walletModel.id!);
    } catch (e) {
      errorMessage = e.toString();
    }
    EasyLoading.dismiss();
  }

  @override
  Future<void> move(NavID to) async {
    WalletModel? currentWallet =
        protonWalletProvider.protonWallet.currentWallet;
    AccountModel? currentAccount =
        protonWalletProvider.protonWallet.currentAccount;
    switch (to) {
      case NavID.importWallet:
        coordinator.showImportWallet();
        break;
      case NavID.send:
        coordinator.showSend(currentWallet!.id ?? 0, currentAccount?.id ?? 0);
        break;
      case NavID.receive:
        coordinator.showReceive(
            currentWallet!.id ?? 0, currentAccount?.id ?? 0);
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
            currentWallet!.id ?? 0,
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
        coordinator.showSetupBackup(currentWallet!.id ?? 0);
        break;
      case NavID.discover:
        coordinator.showDiscover();
        break;
      case NavID.buy:
        coordinator.showBuy(
            currentWallet!.id ?? 0,
            currentAccount!.id ??
                0); // TODO:: currentAccount will be null if it's in walletView
        break;
      case NavID.nativeUpgrade:
        final session = await userManager.getChildSession();
        coordinator.showNativeUpgrade(session);
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
      await WalletManager.addWalletAccount(
          walletID, scriptType, label, fiatCurrencyNotifier.value);
    } catch (e) {
      errorMessage = e.toString();
    }
    if (errorMessage.isNotEmpty) {
      BuildContext? context = Coordinator.navigatorKey.currentContext;
      if (context != null && context.mounted) {
        CommonHelper.showSnackbar(context, errorMessage, isError: true);
      }
      errorMessage = "";
    }
    EasyLoading.dismiss();
  }

  @override
  Future<void> addEmailAddressToWalletAccount(
      String serverWalletID, String serverAccountID, String serverAddressID,
      {isReloaded = false}) async {
    EasyLoading.show(
        status: "adding email..", maskType: EasyLoadingMaskType.black);
    try {
      await WalletManager.addEmailAddress(
          serverWalletID, serverAccountID, serverAddressID);
      AccountModel accountModel =
          await DBHelper.accountDao!.findByServerAccountID(serverAccountID);
      await protonWalletProvider.setIntegratedEmailIDs(accountModel);
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
        protonWalletProvider.applyHistoryTransactionFilterAndKeyword(
            protonWalletProvider.protonWallet.transactionFilter,
            transactionSearchController.text);
      }
    }
    showSearchHistoryTextField = show;
    datasourceStreamSinkAdd();
  }

  @override
  Map<int, TextEditingController> getAccountNameControllers(
      List<AccountModel> userAccounts) {
    for (AccountModel accountModel in userAccounts) {
      if (accountNameControllers.containsKey(accountModel.id!) == false) {
        accountNameControllers[accountModel.id!] =
            TextEditingController(text: accountModel.labelDecrypt);
      }
    }
    return accountNameControllers;
  }

  @override
  Map<int, ValueNotifier> getAccountFiatCurrencyNotifiers(
      List<AccountModel> userAccounts) {
    for (AccountModel accountModel in userAccounts) {
      if (accountFiatCurrencyNotifiers.containsKey(accountModel.id!) == false) {
        ValueNotifier valueNotifier = ValueNotifier(FiatCurrency.values
            .firstWhere(
                (v) =>
                    v.name.toUpperCase() ==
                    accountModel.fiatCurrency.toUpperCase(),
                orElse: () => defaultFiatCurrency));
        valueNotifier.addListener(() {
          updateWalletAccountFiatCurrency(accountModel, valueNotifier.value);
        });
        accountFiatCurrencyNotifiers[accountModel.id!] = valueNotifier;
      }
    }
    return accountFiatCurrencyNotifiers;
  }

  Future<void> updateWalletAccountFiatCurrency(
      AccountModel accountModel, FiatCurrency newFiatCurrency) async {
    WalletModel walletModel =
        await DBHelper.walletDao!.findById(accountModel.walletID);
    WalletAccount walletAccount =
        await proton_api.updateWalletAccountFiatCurrency(
            walletId: walletModel.serverWalletID,
            walletAccountId: accountModel.serverAccountID,
            newFiatCurrency: newFiatCurrency);
    accountModel.fiatCurrency = walletAccount.fiatCurrency.name.toUpperCase();
    await DBHelper.accountDao!.update(accountModel);
    if (protonWalletProvider.protonWallet.currentAccount == null) {
      // wallet view
      FiatCurrency fiatCurrency =
          await WalletManager.getDefaultAccountFiatCurrency(walletModel);
      protonWalletProvider
          .updateFiatCurrencyInUserSettingProvider(fiatCurrency);
    } else {
      if (accountModel.serverAccountID ==
          (protonWalletProvider.protonWallet.currentAccount?.serverAccountID ??
              "")) {
        protonWalletProvider
            .updateFiatCurrencyInUserSettingProvider(newFiatCurrency);
      }
    }
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
  Future<void> updateWalletName(String serverWalletID, String newName) async {
    SecretKey? secretKey = await protonWalletManager.getWalletKey(
        protonWalletProvider.protonWallet.currentWallet!.serverWalletID);
    try {
      String encryptedName = await WalletKeyHelper.encrypt(secretKey, newName);
      await proton_api.updateWalletName(
          walletId: serverWalletID, newName: encryptedName);
      protonWalletProvider.updateCurrentWalletName(newName);
    } catch (e) {
      errorMessage = e.toString();
    }
    if (errorMessage.isNotEmpty) {
      CommonHelper.showErrorDialog("loadData() 1: $errorMessage");
      errorMessage = "";
    }
  }

  @override
  Future<void> updatePassphrase(String key, String passphrase) async {
    await protonWalletManager.setPassphrase(key, passphrase);
  }

  @override
  Future<void> createWallet() async{
    try {
      Mnemonic mnemonic = await Mnemonic.create(WordCount.words12);
      String strMnemonic = mnemonic.asString();
      String walletName = nameTextController.text;
      String strPassphrase = passphraseTextController.text;
      await WalletManager.createWallet(
          walletName,
          strMnemonic,
          WalletModel.importByUser,
          Provider.of<ProtonWalletProvider>(
              Coordinator.navigatorKey.currentContext!,
              listen: false)
              .protonWallet
              .newAccountFiatCurrency,
          strPassphrase);

      await WalletManager.autoBindEmailAddresses();
      await Future.delayed(
          const Duration(seconds: 1)); // wait for account show on sidebar
    } catch (e) {
      errorMessage = e.toString();
    }
  }
}
