import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/helper/bdk/helper.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/crypto.price.helper.dart';
import 'package:wallet/helper/crypto.price.info.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/event_loop_helper.dart';
import 'package:wallet/helper/logger.dart';
import 'package:proton_crypto/proton_crypto.dart' as proton_crypto;
import 'package:wallet/helper/secure_storage_helper.dart';
import 'package:wallet/helper/walletkey_helper.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/rust/api/proton_api.dart' as proton_api;
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/rust/proton_api/wallet.dart';
import 'package:wallet/rust/proton_api/wallet_account.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/debug/bdk.test.dart';
import 'package:wallet/helper/wallet_manager.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';

abstract class HomeViewModel extends ViewModel {
  HomeViewModel(super.coordinator);
  int selectedPage = 0;
  int selectedWalletID = 11;
  double totalBalance = 0.0;
  CryptoPriceInfo btcPriceInfo =
      CryptoPriceInfo(symbol: "BTCUSDT", price: 0.0, priceChange24h: 0.0);
  String selectedAccountDerivationPath = WalletManager.getDerivationPath();

  void updateSelected(int index);

  List userWallets = [];
  bool hasWallet = true;
  bool hasMailIntegration = false;
  bool isFetching = false;
  List accounts = [];
  WalletModel? currentWallet;
  AccountModel? currentAccount;
  ValueNotifier? accountNotifier;
  ValueNotifier fiatCurrencyNotifier = ValueNotifier(ApiFiatCurrency.chf);

  bool initialed = false;
  int unconfirmed = 0;
  int confirmed = 0;
  bool isSyncing = false;
  int exchangeRate = 0;
  int lastExchangeRateTime = 0;

  Future<void> updateExchangeRate();
  void getUserSettings();

  void updateBitcoinUnit(CommonBitcoinUnit symbol);

  void saveUserSettings();

  ApiUserSettings? userSettings;
  late TextEditingController bitcoinUnitController;
  late TextEditingController faitCurrencyController;
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

  void updateFiatCurrency(ApiFiatCurrency fiatCurrency);

  void syncWallet();

  void checkPreference();

  Future<void> renameAccount(String newName);

  Future<void> deleteAccount();

  int balance = 0;

  @override
  bool get keepAlive => true;
  bool forceReloadWallet = false;
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
    bitcoinUnitController = TextEditingController();
    faitCurrencyController = TextEditingController();
    hideEmptyUsedAddressesController = TextEditingController();
    twoFactorAmountThresholdController = TextEditingController();
    getUserSettings();
    checkAccounts();
    updateBtcPrice();
    checkNewWallet();
    checkPreference();
    syncWallet();
    updateExchangeRate();
    await proton_api.initApiService(
        userName: 'ProtonWallet', password: 'alicebob');
    EventLoopHelper.start();
    blockchain ??= await _lib.initializeBlockchain(false);
    hasWallet = await WalletManager.hasAccount();
    await WalletManager.initContacts();
    initialed = true;
    // fetchWallets();
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

  @override
  Future<void> updateExchangeRate() async {
    if (WalletManager.getCurrentTime() > lastExchangeRateTime + exchangeRateRefreshThreshold) {
      lastExchangeRateTime = WalletManager.getCurrentTime();
      exchangeRate = await WalletManager.getExchangeRate(ApiFiatCurrency.eur, time: lastExchangeRateTime);
      datasourceChangedStreamController.add(this);
    }
  }

  @override
  Future<void> checkNewWallet() async {
    await DBHelper.walletDao!.findAll().then((results) async {
      for (WalletModel walletModel in results) {
        walletModel.accountCount =
            await DBHelper.accountDao!.getAccountCount(walletModel.id!);
      }
      if (results.length != userWallets.length || forceReloadWallet) {
        userWallets = results;
        forceReloadWallet = false;
      }
    });
    datasourceChangedStreamController.sink.add(this);
    Future.delayed(const Duration(milliseconds: 1000), () {
      checkNewWallet();
    });
  }

  Future<void> selectAccount(AccountModel accountModel) async {
    currentAccount = accountModel;
    wallet = await WalletManager.loadWalletWithID(
        currentWallet!.id!, currentAccount!.id!);
    datasourceChangedStreamController.sink.add(this);
  }

  @override
  Future<void> selectWallet(int walletID) async {
    selectedWalletID = walletID;
    await checkAccounts();
  }

  @override
  Future<void> checkAccounts() async {
    currentWallet = await DBHelper.walletDao!.findById(selectedWalletID);
    accounts = await DBHelper.accountDao!.findAllByWalletID(selectedWalletID);
    if (accounts.isNotEmpty) {
      selectAccount(accounts.first);
    }
    accountNotifier = ValueNotifier(currentAccount);
    accountNotifier!.addListener(() {
      selectAccount(accountNotifier!.value);
    });
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
  Future<void> getUserSettings() async {
    userSettings = await proton_api.getUserSettings();
    loadUserSettings();
    Future.delayed(const Duration(seconds: 30), () {
      getUserSettings();
    });
  }

  void loadUserSettings() {
    if (userSettings != null) {
      bitcoinUnitController.text = userSettings!.bitcoinUnit.name.toUpperCase();
      faitCurrencyController.text =
          userSettings!.fiatCurrency.name.toUpperCase();
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
    if (initialed && !isSyncing && wallet != null) {
      print("Start syncing");
      isSyncing = true;
      datasourceChangedStreamController.sink.add(this);
      await _lib.sync(blockchain!, wallet!);
      var walletBalance = await wallet!.getBalance();
      balance = walletBalance.total;
      var unconfirmedList = await _lib.getUnConfirmedTransactions(wallet!);
      unconfirmed = unconfirmedList.length;

      var confirmedList = await _lib.getConfirmedTransactions(wallet!);
      confirmed = confirmedList.length;
      isSyncing = false;
      datasourceChangedStreamController.sink.add(this);
      print("End syncing: ($confirmed, $unconfirmed)");
    }
    Future.delayed(const Duration(seconds: 2), () async {
      await syncWallet();
    });
  }



  @override
  Future<void> saveUserSettings() async {
    hideEmptyUsedAddresses = hideEmptyUsedAddressesController.text == "On";
    int twoFactorAmountThreshold =
        int.parse(twoFactorAmountThresholdController.text);
    CommonBitcoinUnit bitcoinUnit =
        CommonHelper.getBitcoinUnit(bitcoinUnitController.text);
    ApiFiatCurrency fiatCurrency =
        CommonHelper.getFiatCurrency(faitCurrencyController.text);

    userSettings = await proton_api.hideEmptyUsedAddresses(
        hideEmptyUsedAddresses: hideEmptyUsedAddresses);
    userSettings =
        await proton_api.twoFaThreshold(amount: twoFactorAmountThreshold);
    userSettings = await proton_api.bitcoinUnit(symbol: bitcoinUnit);
    userSettings = await proton_api.fiatCurrency(symbol: fiatCurrency);

    loadUserSettings();
    await WalletManager.saveUserSetting(userSettings!);
  }

  @override
  Future<void> updateBitcoinUnit(CommonBitcoinUnit symbol) async {
    userSettings = await proton_api.bitcoinUnit(symbol: symbol);
    datasourceChangedStreamController.sink.add(this);
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
  Future<void> updateFiatCurrency(ApiFiatCurrency fiatCurrency) async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool("todo_hadSetFiatCurrency", true);
    hadSetFiatCurrency = true;
    datasourceChangedStreamController.sink.add(this);
  }
}
