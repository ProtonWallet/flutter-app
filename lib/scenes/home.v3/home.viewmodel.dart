import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/helper/bdk/helper.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/crypto.price.helper.dart';
import 'package:wallet/helper/crypto.price.info.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/event_loop_helper.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/helper/secure_storage_helper.dart';
import 'package:wallet/helper/user.session.dart';
import 'package:wallet/helper/walletkey_helper.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/transaction.model.dart';
import 'package:wallet/rust/api/proton_api.dart' as proton_api;
import 'package:wallet/rust/bdk/types.dart';
import 'package:wallet/rust/proton_api/proton_address.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/rust/proton_api/wallet.dart';
import 'package:wallet/rust/proton_api/wallet_account.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/debug/bdk.test.dart';
import 'package:wallet/helper/wallet_manager.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/home.v3/home.coordinator.dart';

enum WalletDrawerStatus {
  close,
  openSetting,
  openWalletPreference,
}

abstract class HomeViewModel extends ViewModel<HomeCoordinator> {
  HomeViewModel(super.coordinator);

  int selectedPage = 0;
  int selectedWalletID = -1;
  double totalBalance = 0.0;
  CryptoPriceInfo btcPriceInfo =
      CryptoPriceInfo(symbol: "BTCUSDT", price: 0.0, priceChange24h: 0.0);
  BitcoinTransactionFee bitcoinTransactionFee = BitcoinTransactionFee(
      block1Fee: 1.0,
      block2Fee: 1.0,
      block3Fee: 1.0,
      block5Fee: 1.0,
      block10Fee: 1.0,
      block20Fee: 1.0);
  String selectedAccountDerivationPath = WalletManager.getDerivationPath();

  void updateSelected(int index);

  List userWallets = [];
  bool hasWallet = true;
  bool hasMailIntegration = false;
  bool isFetching = false;
  bool isShowingNoInternet = false;
  List userAccounts = [];
  List<ProtonAddress> protonAddresses = [];
  List<String> integratedEmailIDs = [];
  WalletModel? currentWallet;
  WalletModel? walletForPreference;
  List userAccountsForPreference = [];

  AccountModel? currentAccount;
  ValueNotifier? accountNotifier;
  ValueNotifier<FiatCurrency> fiatCurrencyNotifier =
      ValueNotifier(FiatCurrency.chf);
  late ValueNotifier<ProtonAddress> emailIntegrationNotifier;
  bool emailIntegrationEnable = false;
  List<FiatCurrency> fiatCurrencies = [
    FiatCurrency.usd,
    FiatCurrency.eur,
    FiatCurrency.chf
  ];

  late ValueNotifier accountValueNotifierForPreference;

  TextEditingController walletPreferenceTextEditingController =
      TextEditingController(text: "");

  bool initialed = false;
  bool protonApiSessionError = false;
  String protonApiSessionErrorString = "";
  int unconfirmed = 0;
  int confirmed = 0;
  Map<String, bool> isSyncingMap = {};
  int exchangeRate = 0;
  int lastExchangeRateTime = 0;

  Future<void> updateExchangeRate();

  void getUserSettings();

  void updateBitcoinUnit(CommonBitcoinUnit symbol);

  void saveUserSettings();

  ApiUserSettings? userSettings;
  late TextEditingController bitcoinUnitController;
  late TextEditingController hideEmptyUsedAddressesController;
  late TextEditingController twoFactorAmountThresholdController;

  bool hideEmptyUsedAddresses = false;
  bool hadBackup = false;
  bool hadSetupEmailIntegration = false;
  bool hadSetFiatCurrency = false;

  void setOnBoard(BuildContext context);

  void checkNewWallet();

  void selectWallet(int walletID);

  Future<void> checkAccounts();

  void updateBtcPrice();

  void updateTransactionFee();

  void updateFiatCurrency(FiatCurrency fiatCurrency);

  Future<void> updateEmailIntegration();

  void syncWallet();

  void checkPreference();

  void updateDrawerStatus(WalletDrawerStatus walletDrawerStatus);

  void openWalletPreference(int walletID);

  void checkProtonAddresses();

  Future<void> renameAccount(String newName);

  Future<void> deleteAccount();

  Future<void> addBitcoinAddress();

  Future<void> checkBitcoinAddress();

  Future<void> removeEmailAddress(String addressID);

  ProtonAddress? getProtonAddressByID(String addressID);

  void reloadPage();

  int balance = 0;
  WalletDrawerStatus walletDrawerStatus = WalletDrawerStatus.close;

  String selectedTXID = "";

  List<TransactionDetails> history = [];
  List<String> userLabels = [];

  int getAmount(int index);

  @override
  bool get keepAlive => true;

  void logout();
}

class HomeViewModelImpl extends HomeViewModel {
  HomeViewModelImpl(super.coordinator);

  final datasourceChangedStreamController =
      StreamController<HomeViewModel>.broadcast();
  final selectedSectionChangedController = StreamController<int>.broadcast();
  Wallet? wallet;
  final BdkLibrary _lib = BdkLibrary();
  Blockchain? blockchain;

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
    EasyLoading.show(
        status: "connecting to proton..", maskType: EasyLoadingMaskType.black);
    bitcoinUnitController = TextEditingController();
    hideEmptyUsedAddressesController = TextEditingController();
    twoFactorAmountThresholdController = TextEditingController(text: "3");
    blockchain ??= await _lib.initializeBlockchain(false);
    try {
      // await proton_api.initApiService(
      //     userName: 'ProtonWallet', password: 'alicebob');
      String scopes = await SecureStorageHelper.get("scopes");
      String uid = await SecureStorageHelper.get("sessionId");
      String accessToken = await SecureStorageHelper.get("accessToken");
      String refreshToken = await SecureStorageHelper.get("refreshToken");
      String appVersion = "Other";
      String userAgent = "None";
      if (Platform.isWindows || Platform.isLinux) {
        uid = "culsidb6ydy2cp44idul37ocm2vaegsw";
        accessToken = "d2mvzcxdmms6evygtsz3ujlvzlrl5pki";
        refreshToken = "utvo4z6mnennsllibj2ggdraca4ycthb";
      }
      if (Platform.isAndroid) {
        appVersion = await SecureStorageHelper.get("appVersion");
        userAgent = await SecureStorageHelper.get("userAgent");
      }
      // if (Platform.isIOS) {
      //   appVersion = "android-wallet@1.0.0-dev";
      //   userAgent = "ProtonWallet/1.0.0 (Android 12; test; motorola; en)";
      // }
      proton_api.initApiServiceFromAuthAndVersion(
        uid: uid,
        access: accessToken,
        refresh: refreshToken,
        scopes: scopes.split(","),
        appVersion: appVersion,
        userAgent: userAgent,
      );
      await Future.delayed(const Duration(
          seconds:
              1)); // TODO:: replace this workaround, we need to wait some time for rust to init api service

      hasWallet = await WalletManager.hasWallet();
      if (hasWallet == false) {
        await WalletManager.fetchWalletsFromServer();
        hasWallet = await WalletManager.hasWallet();
      }
      updateExchangeRate();
      WalletManager.initContacts();
      EventLoopHelper.start();
      initialed = true;
    } catch (e) {
      protonApiSessionError = true;
      protonApiSessionErrorString = e.toString();
    }
    getUserSettings();
    checkAccounts();
    updateBtcPrice();
    updateTransactionFee();
    checkNewWallet();
    checkPreference();
    checkNetwork();
    checkProtonAddresses();
    fiatCurrencyNotifier.addListener(() {
      updateExchangeRate(runOnce: true);
    });
    try {
      EasyLoading.dismiss();
    } catch (e) {
      logger.d(e.toString());
    }
    datasourceStreamSinkAdd();
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  @override
  void updateSelected(int index) {
    selectedPage = index;
    datasourceStreamSinkAdd();
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

  @override
  Future<void> updateExchangeRate({bool runOnce = false}) async {
    if (runOnce == false) {
      if (WalletManager.getCurrentTime() >
          lastExchangeRateTime + exchangeRateRefreshThreshold) {
        lastExchangeRateTime = WalletManager.getCurrentTime();
        // don't send time since client time may be faster than server time, it will raise error
        exchangeRate = 6000000;
        // await WalletManager.getExchangeRate(fiatCurrencyNotifier.value);
      }
      Future.delayed(const Duration(seconds: exchangeRateRefreshThreshold + 1),
          () {
        updateExchangeRate();
      });
    } else {
      lastExchangeRateTime = WalletManager.getCurrentTime();
      // don't send time since client time may be faster than server time, it will raise error
      exchangeRate = 6000000;
      // await WalletManager.getExchangeRate(fiatCurrencyNotifier.value);
    }
    datasourceStreamSinkAdd();
    Future.delayed(const Duration(seconds: exchangeRateRefreshThreshold + 1),
        () {
      updateExchangeRate();
    });
  }

  @override
  int getAmount(int index) {
    var amount = history[index].received - history[index].sent;
    return amount;
  }

  @override
  Future<void> checkNewWallet() async {
    bool currentWalletExist = false;
    await DBHelper.walletDao!.findAll().then((results) async {
      for (WalletModel walletModel in results) {
        walletModel.accountCount =
            await DBHelper.accountDao!.getAccountCount(walletModel.id!);
        walletModel.balance =
            await WalletManager.getWalletBalance(walletModel.id!);
        if (currentWallet != null && currentWallet!.id! == walletModel.id!) {
          currentWalletExist = true;
        }
      }
      userWallets = results;
    });
    if (selectedWalletID == -1) {
      if (userWallets.isNotEmpty) {
        int walletID = userWallets.cast<WalletModel>().first.id!;
        selectWallet(walletID);
      }
    }
    if (currentWalletExist == false) {
      currentWallet = null;
      userAccounts = [];
      balance = 0;
    }
    datasourceStreamSinkAdd();
    Future.delayed(const Duration(milliseconds: 1000), () async {
      await checkNewWallet();
    });
  }

  Future<void> selectAccount(AccountModel accountModel) async {
    List<String> newUserLabels = [];
    currentAccount = accountModel;
    wallet = await WalletManager.loadWalletWithID(
        currentWallet!.id!, currentAccount!.id!);
    await loadIntegratedAddresses();
    if (wallet != null) {
      history = await _lib.getConfirmedTransactions(wallet!);
      history.sort((a, b) {
        return a.confirmationTime!.timestamp > b.confirmationTime!.timestamp
            ? -1
            : 1;
      });
      for (TransactionDetails transactionDetail in history) {
        TransactionModel? transactionModel = await DBHelper.transactionDao!
            .findByExternalTransactionID(utf8.encode(transactionDetail.txid));
        String userLabel =
            transactionModel != null ? utf8.decode(transactionModel.label) : "";
        newUserLabels.add(userLabel);
      }
    }
    userLabels = newUserLabels;
    syncWallet();
    datasourceStreamSinkAdd();
  }

  Future<void> loadIntegratedAddresses() async {
    integratedEmailIDs = await WalletManager.getAccountAddressIDs(
        currentAccount!.serverAccountID);
    emailIntegrationEnable = integratedEmailIDs.isNotEmpty;
    datasourceStreamSinkAdd();
  }

  @override
  Future<void> selectWallet(int walletID) async {
    selectedWalletID = walletID;
    balance = 0;
    userAccounts = [];
    await checkAccounts();
  }

  @override
  Future<void> checkAccounts() async {
    currentWallet = await DBHelper.walletDao!.findById(selectedWalletID);
    if (currentWallet != null) {
      userAccounts =
          await DBHelper.accountDao!.findAllByWalletID(selectedWalletID);
      if (userAccounts.isNotEmpty) {
        selectAccount(userAccounts.first);
      }
      accountNotifier = ValueNotifier(currentAccount);
      accountNotifier!.addListener(() {
        selectAccount(accountNotifier!.value);
      });
    }
    datasourceStreamSinkAdd();
  }

  @override
  void setOnBoard(BuildContext context) {
    hasWallet = true;
    Future.delayed(const Duration(milliseconds: 100), () {
      coordinator.showSetupOnbaord();
      datasourceStreamSinkAdd();
    });
  }

  @override
  Future<void> updateBtcPrice() async {
    btcPriceInfo = await CryptoPriceHelper.getPriceInfo("BTCUSDT");
    datasourceStreamSinkAdd();
    Future.delayed(const Duration(seconds: 1), () {
      updateBtcPrice();
    });
  }

  @override
  Future<void> updateTransactionFee() async {
    bitcoinTransactionFee = await CryptoPriceHelper.getBitcoinTransactionFee();
    datasourceStreamSinkAdd();
    Future.delayed(const Duration(seconds: 30), () {
      updateTransactionFee();
    });
  }

  @override
  Future<void> getUserSettings() async {
    if (initialed) {
      userSettings = await proton_api.getUserSettings();
      loadUserSettings();
    }
    Future.delayed(const Duration(seconds: 30), () {
      getUserSettings();
    });
  }

  void loadUserSettings() {
    if (userSettings != null) {
      bitcoinUnitController.text = userSettings!.bitcoinUnit.name.toUpperCase();
      fiatCurrencyNotifier.value = userSettings!.fiatCurrency;
      hideEmptyUsedAddresses = userSettings!.hideEmptyUsedAddresses == 1;
      int twoFactorAmountThreshold =
          userSettings!.twoFactorAmountThreshold ?? 1000;
      twoFactorAmountThresholdController.text =
          twoFactorAmountThreshold.toString();
    }
    datasourceStreamSinkAdd();
  }

  @override
  Future<void> syncWallet() async {
    if (currentWallet != null) {
      String serverWalletID = currentWallet!.serverWalletID;
      if (!isSyncingMap.containsKey(serverWalletID)) {
        isSyncingMap[serverWalletID] = false;
      }
      bool otherIsSyncing = false;
      for (bool isSyncing in isSyncingMap.values) {
        otherIsSyncing = otherIsSyncing | isSyncing;
      }
      var walletBalance = await wallet!.getBalance();
      balance = walletBalance.total;
      datasourceStreamSinkAdd();
      if (otherIsSyncing) {
        Future.delayed(const Duration(seconds: 1), () async {
          await syncWallet();
        });
        return;
      }
      if (initialed &&
          isSyncingMap[serverWalletID]! == false &&
          wallet != null) {
        isSyncingMap[serverWalletID] = true;
        datasourceStreamSinkAdd();
        logger.d("start syncing ${currentWallet!.name} at ${DateTime.now()}");
        await _lib.sync(blockchain!, wallet!);
        var walletBalance = await wallet!.getBalance();
        balance = walletBalance.total;
        var unconfirmedList = await _lib.getUnConfirmedTransactions(wallet!);
        unconfirmed = unconfirmedList.length;

        var confirmedList = await _lib.getConfirmedTransactions(wallet!);
        confirmed = confirmedList.length;
        datasourceStreamSinkAdd();
        isSyncingMap[serverWalletID] = false;
        logger.d("end syncing ${currentWallet!.name} at ${DateTime.now()}");
      }
    }
  }

  @override
  Future<void> saveUserSettings() async {
    if (initialed) {
      hideEmptyUsedAddresses = hideEmptyUsedAddressesController.text == "On";
      int twoFactorAmountThreshold =
          int.parse(twoFactorAmountThresholdController.text);
      CommonBitcoinUnit bitcoinUnit =
          CommonHelper.getBitcoinUnit(bitcoinUnitController.text);
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
  Future<void> updateBitcoinUnit(CommonBitcoinUnit symbol) async {
    if (initialed) {
      userSettings = await proton_api.bitcoinUnit(symbol: symbol);
      datasourceStreamSinkAdd();
    }
  }

  @override
  Future<void> renameAccount(String newName) async {
    if (currentWallet != null) {
      SecretKey? secretKey =
          await WalletManager.getWalletKey(currentWallet!.serverWalletID);
      try {
        WalletAccount _ = await proton_api.updateWalletAccountLabel(
            walletId: currentWallet!.serverWalletID,
            walletAccountId: currentAccount!.serverAccountID,
            newLabel: await WalletKeyHelper.encrypt(secretKey!, newName));
        currentAccount!.label =
            base64Decode(await WalletKeyHelper.encrypt(secretKey, newName));
        currentAccount!.labelDecrypt = newName;
        await DBHelper.accountDao!.update(currentAccount);
        await loadData();
      } catch (e) {
        logger.e(e);
      }
    }
  }

  @override
  Future<void> deleteAccount() async {
    if (initialed) {
      try {
        await proton_api.deleteWalletAccount(
            walletId: currentWallet!.serverWalletID,
            walletAccountId: currentAccount!.serverAccountID);
        await DBHelper.accountDao!.delete(currentAccount!.id!);
        await checkAccounts();
      } catch (e) {
        logger.e(e);
      }
    }
  }

  @override
  Future<void> checkPreference() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (currentWallet != null) {
      String serverWalletID = currentWallet!.serverWalletID;
      hadBackup =
          preferences.getBool("todo_hadBackup_$serverWalletID") ?? false;
      hadSetFiatCurrency =
          preferences.getBool("todo_hadSetFiatCurrency") ?? false;
    }
    if (currentAccount != null) {
      hadSetupEmailIntegration = preferences.getBool(
              "todo_hadSetEmailIntegration_${currentAccount!.serverAccountID}") ??
          false;
    }
    datasourceStreamSinkAdd();
    Future.delayed(const Duration(seconds: 1), () async {
      await checkPreference();
    });
  }

  @override
  void reloadPage() {
    datasourceStreamSinkAdd();
  }

  @override
  Future<void> updateEmailIntegration() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool(
        "todo_hadSetEmailIntegration_${currentAccount!.serverAccountID}", true);
    WalletAccount walletAccount = await proton_api.addEmailAddress(
        walletId: currentWallet!.serverWalletID,
        walletAccountId: currentAccount!.serverAccountID,
        addressId: emailIntegrationNotifier.value.id);

    for (EmailAddress address in walletAccount.addresses) {
      await WalletManager.addEmailAddressToWalletAccount(
          currentAccount!, address);
    }
    await loadIntegratedAddresses();
    hadSetFiatCurrency = true;
    datasourceStreamSinkAdd();
    for (int i = 0; i < 10; i++) {
      addBitcoinAddress();
    }
  }

  @override
  Future<void> checkBitcoinAddress() async {
    List<WalletBitcoinAddress> walletBitcoinAddresses =
        await proton_api.getWalletBitcoinAddress(
            walletId: currentWallet!.serverWalletID,
            walletAccountId: currentAccount!.serverAccountID,
            onlyRequest: 1);
    for (WalletBitcoinAddress walletBitcoinAddress in walletBitcoinAddresses) {
      if (wallet != null && walletBitcoinAddress.bitcoinAddress == null) {
        var addressInfo = await _lib.getAddress(wallet!);
        String address = addressInfo.address;
        BitcoinAddress bitcoinAddress = BitcoinAddress(
            bitcoinAddress: address,
            bitcoinAddressSignature:
                "-----BEGIN PGP SIGNATURE-----\nVersion: ProtonMail\n\nwsBzBAEBCAAnBYJmA55ZCZAEzZ3CX7rlCRYhBFNy3nIbmXFRgnNYHgTNncJf\nuuUJAAAQAgf9EicFZ9NfoTbXc0DInR3fXHgcpQj25Z0uaapvvPMpWwmMSoKp\nm4WrWkWnX/VOizzfwfmSTeLYN8dkGytHACqj1AyEkpSKTbpsYn+BouuNQmat\nYhUnnlT6LLcjDAxv5FU3cDxB6wMmoFZwxu+XsS+zwfldxVp7rq3PNQE/mUzn\no0qf9WcE7vRDtoYu8I26ILwYUEiXgXMvGk5y4mz9P7+UliH7R1/qcFdZoqe4\n4f/cAStdFOMvm8hGk/wIZ/an7lDxE+ggN1do9Vjs2eYVQ8LwwE96Xj5Ny7s5\nFlajisB2YqgTMOC5egrwXE3lxKy2O3TNw1FCROQUR0WaumG8E0foRg==\n=42uQ\n-----END PGP SIGNATURE-----\n",
            bitcoinAddressIndex: 0);
        await proton_api.updateBitcoinAddress(
            walletId: currentWallet!.serverWalletID,
            walletAccountId: currentAccount!.serverAccountID,
            walletAccountBitcoinAddressId: walletBitcoinAddress.id,
            bitcoinAddress: bitcoinAddress);
      }
    }
  }

  @override
  Future<void> addBitcoinAddress() async {
    if (wallet != null) {
      var addressInfo = await _lib.getAddress(wallet!);
      String address = addressInfo.address;
      BitcoinAddress bitcoinAddress = BitcoinAddress(
          bitcoinAddress: address,
          bitcoinAddressSignature:
              "-----BEGIN PGP SIGNATURE-----\nVersion: ProtonMail\n\nwsBzBAEBCAAnBYJmA55ZCZAEzZ3CX7rlCRYhBFNy3nIbmXFRgnNYHgTNncJf\nuuUJAAAQAgf9EicFZ9NfoTbXc0DInR3fXHgcpQj25Z0uaapvvPMpWwmMSoKp\nm4WrWkWnX/VOizzfwfmSTeLYN8dkGytHACqj1AyEkpSKTbpsYn+BouuNQmat\nYhUnnlT6LLcjDAxv5FU3cDxB6wMmoFZwxu+XsS+zwfldxVp7rq3PNQE/mUzn\no0qf9WcE7vRDtoYu8I26ILwYUEiXgXMvGk5y4mz9P7+UliH7R1/qcFdZoqe4\n4f/cAStdFOMvm8hGk/wIZ/an7lDxE+ggN1do9Vjs2eYVQ8LwwE96Xj5Ny7s5\nFlajisB2YqgTMOC5egrwXE3lxKy2O3TNw1FCROQUR0WaumG8E0foRg==\n=42uQ\n-----END PGP SIGNATURE-----\n",
          bitcoinAddressIndex: addressInfo.index);
      var results = await proton_api.addBitcoinAddresses(
          walletId: currentWallet!.serverWalletID,
          walletAccountId: currentAccount!.serverAccountID,
          bitcoinAddresses: [bitcoinAddress]);
      for (var result in results) {
        logger.d(result.bitcoinAddress);
      }
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
    return null;
  }

  @override
  Future<void> removeEmailAddress(String addressID) async {
    WalletAccount walletAccount = await proton_api.removeEmailAddress(
        walletId: currentWallet!.serverWalletID,
        walletAccountId: currentAccount!.serverAccountID,
        addressId: addressID);
    bool deleted = true;
    for (EmailAddress emailAddress in walletAccount.addresses) {
      if (emailAddress.id == addressID) {
        deleted = false;
      }
    }
    if (deleted) {
      WalletManager.deleteAddress(addressID);
    }
    await loadIntegratedAddresses();
  }

  @override
  void logout() {
    UserSessionProvider().logout();
    DBHelper.reset();
    coordinator.logout();
  }

  @override
  void move(NavigationIdentifier to) {
    switch (to) {
      case ViewIdentifiers.wallet:
        coordinator.showWallet(currentWallet?.id ?? 0);
        break;
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
      case ViewIdentifiers.mailList:
        coordinator.showMailList();
        break;
      case ViewIdentifiers.welcome:
        coordinator.logout();
        break;
      case ViewIdentifiers.walletDeletion:
        coordinator.showWalletDeletion(currentWallet?.id ?? 0);
        break;
      case ViewIdentifiers.historyDetails:
        coordinator.showHistoryDetails(
            currentWallet?.id ?? 0, currentAccount?.id ?? 0, selectedTXID);
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
    }
  }
}
