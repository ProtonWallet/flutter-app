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
import 'package:wallet/helper/local_toast.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/helper/secure_storage_helper.dart';
import 'package:wallet/helper/walletkey_helper.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/transaction.model.dart';
import 'package:wallet/rust/api/proton_api.dart' as proton_api;
import 'package:wallet/rust/bdk/types.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/rust/proton_api/wallet_account.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/debug/bdk.test.dart';
import 'package:wallet/helper/wallet_manager.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/home.v3/home.coordinator.dart';

abstract class HomeViewModel extends ViewModel {
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
  List<ApiFiatCurrency> fiatCurrencies = [
    ApiFiatCurrency.usd,
    ApiFiatCurrency.eur,
    ApiFiatCurrency.chf
  ];
  WalletModel? currentWallet;
  AccountModel? currentAccount;
  ValueNotifier? accountNotifier;
  ValueNotifier fiatCurrencyNotifier = ValueNotifier(ApiFiatCurrency.chf);

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

  void checkAccounts();

  void updateBtcPrice();

  void updateTransactionFee();

  void updateFiatCurrency(ApiFiatCurrency fiatCurrency);

  void syncWallet();

  void checkPreference();

  Future<void> renameAccount(String newName);

  Future<void> deleteAccount();

  int balance = 0;

  String selectedTXID = "";

  List<TransactionDetails> history = [];
  List<String> userLabels = [];

  int getAmount(int index);

  @override
  bool get keepAlive => true;
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

  @override
  Future<void> loadData() async {
    EasyLoading.show(
        status: "connecting to proton..", maskType: EasyLoadingMaskType.black);
    bitcoinUnitController = TextEditingController();
    hideEmptyUsedAddressesController = TextEditingController();
    twoFactorAmountThresholdController = TextEditingController(text: "3");
    blockchain ??= await _lib.initializeBlockchain(false);
    try {
      await Future.delayed(const Duration(seconds: 3));
      // await proton_api.initApiService(
      //     userName: 'ProtonWallet', password: 'alicebob');
      String scopes = await SecureStorageHelper.get("scopes");
      String uid = await SecureStorageHelper.get("sessionId");
      String accessToken = await SecureStorageHelper.get("accessToken");
      String refreshToken = await SecureStorageHelper.get("refreshToken");
      String appVersion = "Other";
      String userAgent = "None";
      if (Platform.isWindows) {
        uid = "xbpj3o7lkjobuzh25jogc4dsadcu4psw";
        accessToken = "w7s5ag3drgzlnkotndhgp5ayc27canfx";
        refreshToken = "57hzf2ui5xhhjnuylbii7xzj4vrvotwu";
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
    try {
      EasyLoading.dismiss();
    } catch (e) {}
    datasourceChangedStreamController.sink.add(this);
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  @override
  void updateSelected(int index) {
    selectedPage = index;
    datasourceChangedStreamController.sink.add(this);
  }

  Future<void> checkNetwork() async{
    List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) {
      if (isShowingNoInternet == false) {
        isShowingNoInternet = true;
        EasyLoading.show(
            status: "waiting for connection..",
            maskType: EasyLoadingMaskType.black);
      }
    } else{
      if (isShowingNoInternet) {
        isShowingNoInternet = false;
        EasyLoading.dismiss();
      }
    }
    Future.delayed(const Duration(seconds: 1), (){
      checkNetwork();
    });
  }

  @override
  Future<void> updateExchangeRate() async {
    if (WalletManager.getCurrentTime() >
        lastExchangeRateTime + exchangeRateRefreshThreshold) {
      lastExchangeRateTime = WalletManager.getCurrentTime();
      exchangeRate = await WalletManager.getExchangeRate(ApiFiatCurrency.eur,
          time: lastExchangeRateTime);
      datasourceChangedStreamController.add(this);
    }
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
    datasourceChangedStreamController.sink.add(this);
    Future.delayed(const Duration(milliseconds: 1000), () async {
      await checkNewWallet();
    });
  }

  Future<void> selectAccount(AccountModel accountModel) async {
    List<String> newUserLabels = [];
    currentAccount = accountModel;
    wallet = await WalletManager.loadWalletWithID(
        currentWallet!.id!, currentAccount!.id!);
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
    datasourceChangedStreamController.sink.add(this);
    syncWallet();
    datasourceChangedStreamController.sink.add(this);
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
    datasourceChangedStreamController.sink.add(this);
  }

  @override
  void setOnBoard(BuildContext context) {
    hasWallet = true;
    Future.delayed(const Duration(milliseconds: 100), () {
      coordinator.move(ViewIdentifiers.setupOnboard, context);
      datasourceChangedStreamController.sink.add(this);
    });
  }

  @override
  Future<void> updateBtcPrice() async {
    btcPriceInfo = await CryptoPriceHelper.getPriceInfo("BTCUSDT");
    datasourceChangedStreamController.sink.add(this);
    Future.delayed(const Duration(seconds: 1), () {
      updateBtcPrice();
    });
  }

  @override
  Future<void> updateTransactionFee() async {
    bitcoinTransactionFee = await CryptoPriceHelper.getBitcoinTransactionFee();
    datasourceChangedStreamController.sink.add(this);
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
    datasourceChangedStreamController.sink.add(this);
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
      datasourceChangedStreamController.sink.add(this);
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
        datasourceChangedStreamController.sink.add(this);
        print("start syncing ${currentWallet!.name} at ${DateTime.now()}");
        await _lib.sync(blockchain!, wallet!);
        var walletBalance = await wallet!.getBalance();
        balance = walletBalance.total;
        var unconfirmedList = await _lib.getUnConfirmedTransactions(wallet!);
        unconfirmed = unconfirmedList.length;

        var confirmedList = await _lib.getConfirmedTransactions(wallet!);
        confirmed = confirmedList.length;
        datasourceChangedStreamController.sink.add(this);
        isSyncingMap[serverWalletID] = false;
        print("end syncing ${currentWallet!.name} at ${DateTime.now()}");
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
      ApiFiatCurrency fiatCurrency = fiatCurrencyNotifier.value;

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
      datasourceChangedStreamController.sink.add(this);
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
    if (currentWallet != null) {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String serverWalletID = currentWallet!.serverWalletID;
      hadBackup =
          preferences.getBool("todo_hadBackup_$serverWalletID") ?? false;
      hadSetFiatCurrency =
          preferences.getBool("todo_hadSetFiatCurrency") ?? false;
      hadSetupEmailIntegration =
          preferences.getBool("todo_hadSetupEmailIntegration") ?? false;
    }
    datasourceChangedStreamController.sink.add(this);
    Future.delayed(const Duration(seconds: 1), () async {
      await checkPreference();
    });
  }

  @override
  Future<void> updateFiatCurrency(ApiFiatCurrency fiatCurrency) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool("todo_hadSetFiatCurrency", true);
    hadSetFiatCurrency = true;
    datasourceChangedStreamController.sink.add(this);
  }
}
