import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet/constants/app.config.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/env.dart';
import 'package:wallet/constants/history.transaction.dart';
import 'package:wallet/constants/script_type.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/crypto.price.helper.dart';
import 'package:wallet/helper/crypto.price.info.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/event_loop_helper.dart';
import 'package:wallet/helper/exchange.rate.service.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/helper/user.session.dart';
import 'package:wallet/helper/user.settings.provider.dart';
import 'package:wallet/helper/walletkey_helper.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/provider/proton.wallet.provider.dart';
import 'package:wallet/rust/api/proton_api.dart' as proton_api;
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/rust/proton_api/proton_address.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/rust/proton_api/wallet_account.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/helper/wallet_manager.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/discover/discover.viewmodel.dart';
import 'package:wallet/scenes/home.v3/home.coordinator.dart';

enum WalletDrawerStatus {
  close,
  openSetting,
  openWalletPreference,
}

abstract class HomeViewModel extends ViewModel<HomeCoordinator> {
  HomeViewModel(super.coordinator, this.apiEnv);

  ApiEnv apiEnv;

  int selectedPage = 0;
  CryptoPriceInfo btcPriceInfo =
      CryptoPriceInfo(symbol: "BTCUSDT", price: 0.0, priceChange24h: 0.0);

  late UserSettingProvider userSettingProvider;
  late ProtonWalletProvider protonWalletProvider;
  bool hasWallet = true;
  bool hasMailIntegration = false;
  bool isFetching = false;
  int currentHistoryPage = 0;
  bool isShowingNoInternet = false;
  List<ProtonAddress> protonAddresses = [];
  WalletModel? walletForPreference;
  List userAccountsForPreference = [];

  Map<int, TextEditingController> accountNameControllers = {};

  ValueNotifier<FiatCurrency> fiatCurrencyNotifier =
      ValueNotifier(FiatCurrency.chf);
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

  void updateBitcoinUnit(BitcoinUnit symbol);

  void saveUserSettings();

  void setSearchHistoryTextField(bool show);

  ApiUserSettings? userSettings;
  late TextEditingController hideEmptyUsedAddressesController;
  late TextEditingController twoFactorAmountThresholdController;
  late TextEditingController walletNameController;

  bool hideEmptyUsedAddresses = false;
  bool hadBackup = false;
  bool hadBackupProtonAccount = false;
  bool hadSetup2FA = false;
  bool hadSetupEmailIntegration = false;
  bool hadSetFiatCurrency = false;
  bool showSearchHistoryTextField = false;

  void setOnBoard();

  void selectAccount(WalletModel walletModel, AccountModel accountModel);

  void updateBtcPrice();

  void showMoreTransactionHistory();

  void updateFiatCurrency(FiatCurrency fiatCurrency);

  Future<void> updateEmailIntegration();

  Future<void> addWalletAccount(
      int walletID, ScriptType scriptType, String label);

  void checkPreference();

  void updateDrawerStatus(WalletDrawerStatus walletDrawerStatus);

  void openWalletPreference(int walletID);

  void checkProtonAddresses();

  Future<void> renameAccount(AccountModel accountModel, String newName);

  Future<void> deleteAccount(
      WalletModel walletModel, AccountModel accountModel);

  Future<void> addBitcoinAddress();

  Future<void> addEmailAddressToWalletAccount(
      String serverWalletID, String serverAccountID, String serverAddressID);

  Future<void> removeEmailAddress(
      String serverWalletID, String serverAccountID, String serverAddressID);

  ProtonAddress? getProtonAddressByID(String addressID);

  int totalTodoSteps = 5;
  int currentTodoStep = 0;
  WalletDrawerStatus walletDrawerStatus = WalletDrawerStatus.close;

  String selectedTXID = "";
  bool isWalletPassphraseMatch = true;

  late FocusNode newAccountNameFocusNode;
  late FocusNode walletNameFocusNode;
  late FocusNode walletPassphraseFocusNode;
  List<ProtonFeedItem> protonFeedItems = [];
  late TextEditingController newAccountNameController;
  late TextEditingController walletPassphraseController;
  late ValueNotifier newAccountScriptTypeValueNotifier;

  @override
  bool get keepAlive => true;

  Future<void> logout();
}

class HomeViewModelImpl extends HomeViewModel {
  HomeViewModelImpl(super.coordinator, super.apiEnv);

  final datasourceChangedStreamController =
      StreamController<HomeViewModel>.broadcast();
  final selectedSectionChangedController = StreamController<int>.broadcast();

  @override
  void dispose() {
    datasourceChangedStreamController.close();
    selectedSectionChangedController.close();
    //clean up wallet ....
  }

  void datasourceStreamSinkAdd() {
    if (datasourceChangedStreamController.isClosed == false) {
      datasourceChangedStreamController.sink.add(this);
    }
  }

  @override
  Future<void> loadData() async {
    await WalletManager.initMuon(apiEnv);
    EasyLoading.show(
        status: "connecting to proton..", maskType: EasyLoadingMaskType.black);
    try {
      hideEmptyUsedAddressesController = TextEditingController();
      walletNameController = TextEditingController(text: "");
      twoFactorAmountThresholdController = TextEditingController(text: "3");
      newAccountNameController = TextEditingController(text: "BTC Account");
      newAccountScriptTypeValueNotifier = ValueNotifier(appConfig.scriptType);
      walletPassphraseController = TextEditingController(text: "");

      walletPassphraseFocusNode = FocusNode();
      newAccountNameFocusNode = FocusNode();
      walletNameFocusNode = FocusNode();

      userSettingProvider = Provider.of<UserSettingProvider>(
          Coordinator.navigatorKey.currentContext!,
          listen: false);
      protonWalletProvider = Provider.of<ProtonWalletProvider>(
          Coordinator.navigatorKey.currentContext!,
          listen: false);
      await Future.delayed(const Duration(
          seconds:
              1)); // TODO:: replace this workaround, we need to wait some time for rust to init api service

      hasWallet = await WalletManager.hasWallet();
      if (hasWallet == false) {
        await WalletManager.fetchWalletsFromServer();
        hasWallet = await WalletManager.hasWallet();
      }
      await WalletManager.initContacts();
      EventLoopHelper.start();
      protonWalletProvider.addListener(() {
        walletNameController.text = protonWalletProvider.protonWallet.currentWallet?.name ?? "";
      });
      await protonWalletProvider.init();
      await protonWalletProvider.setDefaultWalletAccount();
    } catch (e) {
      errorMessage = e.toString();
    }
    if (errorMessage.isNotEmpty) {
      CommonHelper.showErrorDialog("loadData() 1: $errorMessage");
      errorMessage = "";
    }
    try {
      await getUserSettings();
      await updateBtcPrice();
      checkPreference(); // no effect
      checkNetwork(); // no effect
      loadDiscoverContents();
      checkProtonAddresses();
      refreshWithUserSettingProvider();
      fiatCurrencyNotifier.addListener(() async {
        updateFiatCurrencyInUserSettingProvider(fiatCurrencyNotifier.value);
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
    } catch (e) {
      errorMessage = e.toString();
    }
    EasyLoading.dismiss();
    if (errorMessage.isNotEmpty) {
      CommonHelper.showErrorDialog("loadData() 2: $errorMessage");
      errorMessage = "";
    }
    initialed = true;
    if (hasWallet == false) {
      setOnBoard();
    }
    datasourceStreamSinkAdd();
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  Future<void> loadDiscoverContents() async {
    List discoverJsonContents = await ProtonFeedItem.loadJsonFromAsset();
    for (Map<String, dynamic> discoverJsonContent in discoverJsonContents) {
      protonFeedItems.add(ProtonFeedItem.fromJson(discoverJsonContent));
    }
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
    move(ViewIdentifiers.setupOnboard);
  }

  @override
  void showMoreTransactionHistory() {
    currentHistoryPage++;
    datasourceStreamSinkAdd();
  }

  @override
  Future<void> updateBtcPrice() async {
    btcPriceInfo = await CryptoPriceHelper.getPriceInfo("BTCUSDT");
    datasourceStreamSinkAdd();
    Future.delayed(const Duration(seconds: 10), () {
      updateBtcPrice();
    });
  }

  @override
  Future<void> getUserSettings() async {
    userSettings = await proton_api.getUserSettings();
    loadUserSettings();
  }

  Future<void> updateFiatCurrencyInUserSettingProvider(
      FiatCurrency fiatCurrency) async {
    userSettingProvider.updateFiatCurrency(fiatCurrency);
    ProtonExchangeRate exchangeRate =
        await ExchangeRateService.getExchangeRate(fiatCurrency);
    userSettingProvider.updateExchangeRate(exchangeRate);
  }

  void refreshWithUserSettingProvider() async {
    if (userSettingProvider.walletUserSetting.fiatCurrency !=
        fiatCurrencyNotifier.value) {
      fiatCurrencyNotifier.value =
          userSettingProvider.walletUserSetting.fiatCurrency;
    }
    await Future.delayed(const Duration(seconds: 1));
    refreshWithUserSettingProvider();
  }

  void loadUserSettings() {
    if (userSettings != null) {
      bitcoinUnitNotifier.value = userSettings!.bitcoinUnit;
      fiatCurrencyNotifier.value = userSettings!.fiatCurrency;
      hideEmptyUsedAddresses = userSettings!.hideEmptyUsedAddresses == 1;
      int twoFactorAmountThreshold =
          userSettings!.twoFactorAmountThreshold ?? 1000;
      twoFactorAmountThresholdController.text =
          twoFactorAmountThreshold.toString();
      updateFiatCurrencyInUserSettingProvider(userSettings!.fiatCurrency);
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
      FiatCurrency fiatCurrency = fiatCurrencyNotifier.value;

      userSettings = await proton_api.hideEmptyUsedAddresses(
          hideEmptyUsedAddresses: hideEmptyUsedAddresses);
      userSettings =
          await proton_api.twoFaThreshold(amount: twoFactorAmountThreshold);
      userSettings = await proton_api.bitcoinUnit(symbol: bitcoinUnit);
      userSettings = await proton_api.fiatCurrency(symbol: fiatCurrency);

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
    if (currentWallet != null) {
      try {
        SecretKey? secretKey =
            await WalletManager.getWalletKey(currentWallet.serverWalletID);
        WalletAccount walletAccount = await proton_api.updateWalletAccountLabel(
            walletId: currentWallet.serverWalletID,
            walletAccountId: accountModel.serverAccountID,
            newLabel: await WalletKeyHelper.encrypt(secretKey!, newName));
        accountModel.label = base64Decode(walletAccount.label);
        accountModel.labelDecrypt = newName;
        await DBHelper.accountDao!.update(accountModel);
        await protonWalletProvider.insertOrUpdateWalletAccount(accountModel);
      } catch (e) {
        logger.e(e);
      }
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
    AccountModel? currentAccount =
        protonWalletProvider.protonWallet.currentAccount;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (currentWallet != null) {
      String serverWalletID = currentWallet.serverWalletID;
      hadBackup =
          preferences.getBool("todo_hadBackup_$serverWalletID") ?? false;
      hadSetFiatCurrency =
          preferences.getBool("todo_hadSetFiatCurrency") ?? false;
    }
    if (currentAccount != null) {
      hadSetupEmailIntegration = preferences.getBool(
              "todo_hadSetEmailIntegration_${currentAccount.serverAccountID}") ??
          false;
    }
    currentTodoStep = 0;
    currentTodoStep += hadBackup ? 1 : 0;
    currentTodoStep += hadBackupProtonAccount ? 1 : 0;
    currentTodoStep += hadSetup2FA ? 1 : 0;
    currentTodoStep += hadSetFiatCurrency ? 1 : 0;
    currentTodoStep += hadSetupEmailIntegration ? 1 : 0;
    datasourceStreamSinkAdd();
    if (runOnce == false) {
      Future.delayed(const Duration(seconds: 1), () async {
        await checkPreference();
      });
    }
  }

  @override
  Future<void> updateEmailIntegration() async {
    WalletModel? currentWallet =
        protonWalletProvider.protonWallet.currentWallet;
    AccountModel? currentAccount =
        protonWalletProvider.protonWallet.currentAccount;
    try {
      if (currentWallet != null && currentAccount != null) {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        preferences.setBool(
            "todo_hadSetEmailIntegration_${currentAccount.serverAccountID}",
            true);

        datasourceStreamSinkAdd();
        await WalletManager.syncBitcoinAddressIndex(
            currentWallet.serverWalletID, currentAccount.serverAccountID);
        for (int i = 0; i < defaultBitcoinAddressCountForOneEmail; i++) {
          addBitcoinAddress();
        }
      }
    } catch (e) {
      errorMessage = e.toString();
    }
    if (errorMessage.isNotEmpty) {
      CommonHelper.showErrorDialog("updateEmailIntegration(): $errorMessage");
      errorMessage = "";
    }
  }

  @override
  Future<void> addBitcoinAddress() async {
    WalletModel? currentWallet =
        protonWalletProvider.protonWallet.currentWallet;
    AccountModel? currentAccount =
        protonWalletProvider.protonWallet.currentAccount;
    try {
      if (protonWalletProvider.protonWallet.wallet != null) {
        await WalletManager.addBitcoinAddress(
            protonWalletProvider.protonWallet.wallet!, currentWallet!, currentAccount!);
      }
    } catch (e) {
      errorMessage = e.toString();
    }
    if (errorMessage.isNotEmpty) {
      CommonHelper.showErrorDialog("addBitcoinAddress(): $errorMessage");
      errorMessage = "";
    }
  }

  @override
  Future<void> updateFiatCurrency(FiatCurrency fiatCurrency) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool("todo_hadSetFiatCurrency", true);
    hadSetFiatCurrency = true;
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
  Future<void> removeEmailAddress(String serverWalletID, String serverAccountID,
      String serverAddressID) async {
    EasyLoading.show(
        status: "removing email..", maskType: EasyLoadingMaskType.black);
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
      CommonHelper.showErrorDialog("removeEmailAddress(): $errorMessage");
      errorMessage = "";
    }
    datasourceStreamSinkAdd();
  }

  @override
  Future<void> logout() async {
    EasyLoading.show(
        status: "log out, cleaning cache..",
        maskType: EasyLoadingMaskType.black);
    try {
      await UserSessionProvider().logout();
      await DBHelper.reset();
      await Future.delayed(
          const Duration(seconds: 3)); // TODO:: fix await for DBHelper.reset();
    } catch (e) {
      errorMessage = e.toString();
    }
    EasyLoading.dismiss();
    if (errorMessage.isNotEmpty) {
      CommonHelper.showErrorDialog("logout(): $errorMessage");
      errorMessage = "";
    }
    coordinator.logout();
  }

  @override
  void move(NavigationIdentifier to) {
    WalletModel? currentWallet =
        protonWalletProvider.protonWallet.currentWallet;
    AccountModel? currentAccount =
        protonWalletProvider.protonWallet.currentAccount;
    switch (to) {
      case ViewIdentifiers.setupOnboard:
        coordinator.showSetupOnbaord();
        break;
      case ViewIdentifiers.send:
        coordinator.showSend(currentWallet?.id ?? 0, currentAccount?.id ?? 0);
        break;
      case ViewIdentifiers.receive:
        coordinator.showReceive(
            currentWallet?.id ?? 0, currentAccount?.id ?? 0);
        break;
      case ViewIdentifiers.testWebsocket:
        coordinator.showWebSocket();
        break;
      case ViewIdentifiers.securitySetting:
        coordinator.showSecuritySetting();
        break;
      case ViewIdentifiers.welcome:
        coordinator.logout();
        break;
      case ViewIdentifiers.walletDeletion:
        coordinator.showWalletDeletion(currentWallet?.id ?? 0);
        break;
      case ViewIdentifiers.historyDetails:
        coordinator.showHistoryDetails(currentWallet?.id ?? 0,
            currentAccount?.id ?? 0, selectedTXID, fiatCurrencyNotifier.value);
        break;
      case ViewIdentifiers.twoFactorAuthSetup:
        coordinator.showTwoFactorAuthSetup();
        break;
      case ViewIdentifiers.twoFactorAuthDisable:
        coordinator.showTwoFactorAuthDisable();
        break;
      case ViewIdentifiers.setupBackup:
        coordinator.showSetupBackup(currentWallet?.id ?? 0);
        break;
      case ViewIdentifiers.discover:
        coordinator.showDiscover();
        break;
    }
  }

  @override
  Future<void> addWalletAccount(
      int walletID, ScriptType scriptType, String label) async {
    EasyLoading.show(
        status: "Adding account..", maskType: EasyLoadingMaskType.black);
    try {
      await WalletManager.addWalletAccount(walletID, scriptType, label);
    } catch (e) {
      errorMessage = e.toString();
    }
    if (errorMessage.isNotEmpty) {
      CommonHelper.showErrorDialog("addWalletAccount(): $errorMessage");
      errorMessage = "";
    }
    EasyLoading.dismiss();
  }

  @override
  Future<void> addEmailAddressToWalletAccount(String serverWalletID,
      String serverAccountID, String serverAddressID) async {
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
      CommonHelper.showErrorDialog(
          "addEmailAddressToWalletAccount(): $errorMessage");
      errorMessage = "";
    }
    datasourceStreamSinkAdd();
  }

  @override
  void setSearchHistoryTextField(bool show) {
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
    Future.delayed(const Duration(seconds: 1), () {
      checkNetwork();
    });
  }
}
