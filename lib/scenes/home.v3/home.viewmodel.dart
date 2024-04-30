import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet/constants/address.key.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/env.dart';
import 'package:wallet/constants/history.transaction.dart';
import 'package:wallet/constants/script_type.dart';
import 'package:wallet/helper/bdk/helper.dart';
import 'package:wallet/helper/crypto.price.helper.dart';
import 'package:wallet/helper/crypto.price.info.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/event_loop_helper.dart';
import 'package:wallet/helper/exchange.rate.service.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/helper/secure_storage_helper.dart';
import 'package:wallet/helper/user.session.dart';
import 'package:wallet/helper/user.settings.provider.dart';
import 'package:wallet/helper/walletkey_helper.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/transaction.model.dart';
import 'package:wallet/rust/api/proton_api.dart' as proton_api;
import 'package:wallet/rust/bdk/types.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/rust/proton_api/proton_address.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/rust/proton_api/wallet.dart';
import 'package:wallet/rust/proton_api/wallet_account.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/debug/bdk.test.dart';
import 'package:wallet/helper/wallet_manager.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/discover/discover.viewmodel.dart';
import 'package:wallet/scenes/home.v3/home.coordinator.dart';
import 'package:proton_crypto/proton_crypto.dart' as proton_crypto;
import 'package:xml/xml.dart' as xml;
import 'package:http/http.dart' as http;

enum WalletDrawerStatus {
  close,
  openSetting,
  openWalletPreference,
}

abstract class HomeViewModel extends ViewModel<HomeCoordinator> {
  HomeViewModel(super.coordinator, this.apiEnv);

  ApiEnv apiEnv;

  int selectedPage = 0;
  int selectedWalletID = -1;
  double totalBalance = 0.0;
  int currentHistoryPage = 0;
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

  void showMoreTransactionHistory();

  late UserSettingProvider userSettingProvider;
  List userWallets = [];
  bool hasWallet = true;
  bool hasMailIntegration = false;
  bool isFetching = false;
  bool isShowingNoInternet = false;
  Map<int, List<AccountModel>> walletID2Accounts = {};
  Map<int, List<String>> accountID2IntegratedEmailIDs = {};
  List<ProtonAddress> protonAddresses = [];
  WalletModel? currentWallet;
  WalletModel? walletForPreference;
  List userAccountsForPreference = [];

  AccountModel? currentAccount;
  ValueNotifier<FiatCurrency> fiatCurrencyNotifier =
      ValueNotifier(FiatCurrency.chf);
  ValueNotifier<BitcoinUnit> bitcoinUnitNotifier =
      ValueNotifier(BitcoinUnit.btc);
  late ValueNotifier<ProtonAddress> emailIntegrationNotifier;
  bool emailIntegrationEnable = false;
  String transactionFilter = "";

  late ValueNotifier accountValueNotifierForPreference;

  TextEditingController transactionSearchController =
      TextEditingController(text: "");
  TextEditingController walletPreferenceTextEditingController =
      TextEditingController(text: "");

  bool initialed = false;
  bool protonApiSessionError = false;
  String protonApiSessionErrorString = "";
  int unconfirmed = 0;
  int confirmed = 0;
  Map<String, bool> isSyncingMap = {};

  void getUserSettings();

  void searchHistoryTransaction();

  void updateTransactionFilter(String filter);

  void updateBitcoinUnit(BitcoinUnit symbol);

  void saveUserSettings();

  void setSearchHistoryTextField(bool show);

  ApiUserSettings? userSettings;
  late TextEditingController hideEmptyUsedAddressesController;
  late TextEditingController twoFactorAmountThresholdController;

  bool hideEmptyUsedAddresses = false;
  bool hadBackup = false;
  bool hadBackupProtonAccount = false;
  bool hadSetup2FA = false;
  bool hadSetupEmailIntegration = false;
  bool hadSetFiatCurrency = false;
  bool showSearchHistoryTextField = false;

  void setOnBoard(BuildContext context);

  void checkNewWallet();

  void selectWallet(int walletID);

  void selectAccount(AccountModel accountModel);

  void updateBtcPrice();

  void updateTransactionFee();

  void updateFiatCurrency(FiatCurrency fiatCurrency);

  Future<void> updateEmailIntegration();

  Future<void> addWalletAccount(
      int walletID, ScriptType scriptType, String label);

  void syncWallet();

  void checkPreference();

  void updateDrawerStatus(WalletDrawerStatus walletDrawerStatus);

  void openWalletPreference(int walletID);

  void checkProtonAddresses();

  Future<void> renameAccount(AccountModel accountModel, String newName);

  Future<void> deleteAccount(String serverWalletID, String serverAccountID);

  Future<void> addBitcoinAddress();

  Future<void> addEmailAddressToWalletAccount(
      String serverWalletID, String serverAccountID, String serverAddressID);

  Future<void> removeEmailAddress(
      String serverWalletID, String serverAccountID, String serverAddressID);

  ProtonAddress? getProtonAddressByID(String addressID);

  Future<void> loadTransactionHistory();

  void reloadPage();

  List<HistoryTransaction> getHistoryTransactionWithFilter();

  int balance = 0;
  int totalTodoSteps = 5;
  int currentTodoStep = 0;
  WalletDrawerStatus walletDrawerStatus = WalletDrawerStatus.close;

  String selectedTXID = "";
  List<HistoryTransaction> historyTransactions = [];
  List<HistoryTransaction> _historyTransactions = [];

  late FocusNode newAccountNameFocusNode;
  late FocusNode walletNameFocusNode;
  List<ProtonFeedItem> protonFeedItems = [];

  @override
  bool get keepAlive => true;

  Future<void> logout();
}

class HomeViewModelImpl extends HomeViewModel {
  HomeViewModelImpl(super.coordinator, super.apiEnv);

  final datasourceChangedStreamController =
      StreamController<HomeViewModel>.broadcast();
  final selectedSectionChangedController = StreamController<int>.broadcast();
  Wallet? wallet;
  final BdkLibrary _lib = BdkLibrary();
  Blockchain? blockchain;
  bool isLoadingTransactionHistory = false;

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
    hideEmptyUsedAddressesController = TextEditingController();
    twoFactorAmountThresholdController = TextEditingController(text: "3");
    newAccountNameFocusNode = FocusNode();
    walletNameFocusNode = FocusNode();
    blockchain ??= await _lib.initializeBlockchain(false);
    userSettingProvider = Provider.of<UserSettingProvider>(
        Coordinator.navigatorKey.currentContext!,
        listen: false);
    try {
      await Future.delayed(const Duration(
          seconds:
              1)); // TODO:: replace this workaround, we need to wait some time for rust to init api service

      hasWallet = await WalletManager.hasWallet();
      if (hasWallet == false) {
        await WalletManager.fetchWalletsFromServer();
        hasWallet = await WalletManager.hasWallet();
      }
      WalletManager.initContacts();
      EventLoopHelper.start();
    } catch (e) {
      protonApiSessionError = true;
      protonApiSessionErrorString = e.toString();
    }
    getUserSettings();
    updateBtcPrice();
    updateTransactionFee();
    checkNewWallet();
    checkPreference(); // no effect
    checkNetwork(); // no effect
    loadDiscoverContents();
    checkProtonAddresses();
    fiatCurrencyNotifier.addListener(() async {
      updateFiatCurrencyInUserSettingProvider(fiatCurrencyNotifier.value);
    });
    bitcoinUnitNotifier.addListener(() async {
      updateBitcoinUnit(bitcoinUnitNotifier.value);
      userSettingProvider.updateBitcoinUnit(bitcoinUnitNotifier.value);
    });
    transactionSearchController.addListener(() {
      searchTransactions();
    });
    try {
      EasyLoading.dismiss();
    } catch (e) {
      logger.d(e.toString());
    }
    initialed = true;
    syncWalletService();
    loadTransactionHistoryService();
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

  Future<void> loadDiscoverContents() async {
    List discoverJsonContents = await ProtonFeedItem.loadJsonFromAsset();
    for (Map<String, dynamic> discoverJsonContent in discoverJsonContents) {
      protonFeedItems.add(ProtonFeedItem.fromJson(discoverJsonContent));
    }
  }

  String _findElementOrDefault(
      xml.XmlElement item, String tagName, String defaultValue) {
    try {
      var element = item.findElements(tagName).single;
      return element.innerText.trim().isEmpty
          ? defaultValue
          : element.innerText;
    } catch (e) {
      logger.e(e.toString());
      return defaultValue;
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

  Future<void> refreshWalletID2Accounts(String serverWalletID) async {
    WalletModel? walletModel =
        await DBHelper.walletDao!.getWalletByServerWalletID(serverWalletID);
    if (walletModel != null) {
      int walletID = walletModel.id!;
      List accounts = await DBHelper.accountDao!.findAllByWalletID(walletID);
      for (AccountModel accountModel in accounts) {
        accountModel.balance = await WalletManager.getWalletAccountBalance(
            walletID, accountModel.id!);
        accountID2IntegratedEmailIDs[accountModel.id!] =
            await WalletManager.getAccountAddressIDs(
                accountModel.serverAccountID);
      }
      walletID2Accounts[walletID] = accounts.cast<AccountModel>();
      datasourceStreamSinkAdd();
    }
  }

  @override
  Future<void> checkNewWallet() async {
    bool currentWalletExist = false;
    await DBHelper.walletDao!.findAll().then((results) async {
      Map<int, List<AccountModel>> newWalletID2Accounts = {};
      for (WalletModel walletModel in results) {
        walletModel.accountCount =
            await DBHelper.accountDao!.getAccountCount(walletModel.id!);
        walletModel.balance =
            await WalletManager.getWalletBalance(walletModel.id!);
        if (currentWallet != null && currentWallet!.id! == walletModel.id!) {
          currentWalletExist = true;
        }
        List accounts =
            await DBHelper.accountDao!.findAllByWalletID(walletModel.id!);
        for (AccountModel accountModel in accounts) {
          accountModel.balance = await WalletManager.getWalletAccountBalance(
              walletModel.id!, accountModel.id!);
          accountID2IntegratedEmailIDs[accountModel.id!] =
              await WalletManager.getAccountAddressIDs(
                  accountModel.serverAccountID);
        }
        newWalletID2Accounts[walletModel.id!] = accounts.cast<AccountModel>();
      }
      userWallets = results;
      walletID2Accounts = newWalletID2Accounts;
    });
    if (currentWalletExist == false) {
      currentWallet = null;
      balance = 0;
    }
    if (selectedWalletID == -1) {
      if (userWallets.isNotEmpty) {
        int walletID = userWallets.cast<WalletModel>().first.id!;
        List defaultAccounts =
            await DBHelper.accountDao!.findAllByWalletID(walletID);
        if (defaultAccounts.isNotEmpty) {
          await selectAccount(defaultAccounts.first);
        }
      }
    }
    datasourceStreamSinkAdd();
    Future.delayed(const Duration(milliseconds: 1000), () async {
      await checkNewWallet();
    });
  }

  @override
  Future<void> selectAccount(AccountModel accountModel) async {
    await selectWallet(accountModel.walletID);
    if (currentAccount != null &&
        currentAccount!.serverAccountID != accountModel.serverAccountID) {
      currentHistoryPage = 0;
      confirmed = 0;
      unconfirmed = 0;
    }
    currentAccount = accountModel;
    wallet = await WalletManager.loadWalletWithID(
        currentWallet!.id!, currentAccount!.id!);
    await loadIntegratedAddresses();
    await loadTransactionHistory();
    checkPreference(runOnce: true);
    syncWallet();
    datasourceStreamSinkAdd();
  }

  @override
  Future<void> loadTransactionHistory() async {
    if (isLoadingTransactionHistory == true) {
      return;
    }
    isLoadingTransactionHistory = true;

    String userPrivateKey =
        await SecureStorageHelper.instance.get("userPrivateKey");
    String userPassphrase =
        await SecureStorageHelper.instance.get("userPassphrase");

    List<ProtonAddress> addresses = await proton_api.getProtonAddress();
    addresses = addresses.where((element) => element.status == 1).toList();

    List<AddressKey> addressKeys = [];
    for (ProtonAddress address in addresses) {
      for (ProtonAddressKey addressKey in address.keys ?? []) {
        String addressKeyPrivateKey = addressKey.privateKey ?? "";
        String addressKeyToken = addressKey.token ?? "";
        try {
          String addressKeyPassphrase = proton_crypto.decrypt(
              userPrivateKey, userPassphrase, addressKeyToken);
          addressKeys.add(AddressKey(
              privateKey: addressKeyPrivateKey,
              passphrase: addressKeyPassphrase));
        } catch (e) {
          logger.e(e.toString());
        }
      }
    }
    Map<String, HistoryTransaction> newHistoryTransactionsMap = {};
    int newConfirmed = 0;
    int newUnconfirmed = 0;
    if (wallet != null) {
      List<TransactionDetails> transactionHistoryFromBDK =
          await _lib.getAllTransactions(wallet!);
      newConfirmed = transactionHistoryFromBDK.length;
      SecretKey? secretKey =
          await WalletManager.getWalletKey(currentWallet!.serverWalletID);

      for (TransactionDetails transactionDetail in transactionHistoryFromBDK) {
        String txID = transactionDetail.txid;
        TransactionModel? transactionModel = await DBHelper.transactionDao!
            .findByExternalTransactionID(utf8.encode(txID));
        String userLabel = transactionModel != null
            ? await WalletKeyHelper.decrypt(
                secretKey!, utf8.decode(transactionModel.label))
            : "";
        String toList = "";
        String sender = "";
        if (transactionModel != null) {
          String encryptedToList = transactionModel.tolist ?? "";
          String encryptedSender = transactionModel.sender ?? "";
          for (AddressKey addressKey in addressKeys) {
            try {
              if (encryptedToList.isNotEmpty) {
                toList = addressKey.decryptBinary(encryptedToList);
              }
            } catch (e) {
              logger.e(e.toString());
            }
            try {
              if (encryptedSender.isNotEmpty) {
                sender = addressKey.decryptBinary(encryptedSender);
              }
            } catch (e) {
              logger.e(e.toString());
            }
            if (sender.isNotEmpty || toList.isNotEmpty) {
              break;
            }
          }
        }
        int amountInSATS = transactionDetail.received - transactionDetail.sent;
        newHistoryTransactionsMap[txID] = HistoryTransaction(
            txID: txID,
            createTimestamp: transactionDetail.confirmationTime?.timestamp,
            updateTimestamp: transactionDetail.confirmationTime?.timestamp,
            amountInSATS: amountInSATS,
            sender: sender.isNotEmpty ? sender : txID,
            toList: toList.isNotEmpty ? toList : txID,
            feeInSATS: transactionDetail.fee ?? 0,
            label: userLabel,
            inProgress: transactionDetail.confirmationTime == null);
      }
      List<TransactionModel> transactionModels = await DBHelper.transactionDao!
          .findAllByServerAccountID(currentAccount!.serverAccountID);
      for (TransactionModel transactionModel in transactionModels) {
        String userLabel = await WalletKeyHelper.decrypt(
            secretKey!, utf8.decode(transactionModel.label));

        String txID = utf8.decode(transactionModel.externalTransactionID);
        if (txID.isEmpty) {
          continue;
        }
        if (newHistoryTransactionsMap.containsKey(txID)) {
          continue;
        }
        String toList = "";
        String sender = "";
        String encryptedToList = transactionModel.tolist ?? "";
        String encryptedSender = transactionModel.sender ?? "";
        for (AddressKey addressKey in addressKeys) {
          try {
            if (encryptedToList.isNotEmpty) {
              toList = addressKey.decryptBinary(encryptedToList);
            }
          } catch (e) {
            logger.e(e.toString());
          }
          try {
            if (encryptedSender.isNotEmpty) {
              sender = addressKey.decryptBinary(encryptedSender);
            }
          } catch (e) {
            logger.e(e.toString());
          }
          if (sender.isNotEmpty || toList.isNotEmpty) {
            break;
          }
        }
        bool isSent = true;
        String user = WalletManager.getEmailFromWalletTransaction(toList);
        for (ProtonAddress protonAddress in protonAddresses) {
          if (user == protonAddress.email) {
            isSent = false;
            break;
          }
        }
        int amountInSATS = 0;
        int feeInSATS = 0;
        for (int i = 0; i < 5; i++) {
          Map<String, dynamic> transactionDetail =
              await WalletManager.getTransactionDetailsFromBlockStream(txID);
          try {
            amountInSATS = transactionDetail['outputs'][0]['value'];
            feeInSATS = transactionDetail['fees'];
            break;
          } catch (e) {
            logger.i(txID);
            logger.i(transactionDetail);
            logger.e(e.toString());
          }
          await Future.delayed(const Duration(seconds: 1));
        }
        if (isSent) {
          amountInSATS = -amountInSATS;
        }
        newUnconfirmed++;
        newHistoryTransactionsMap[txID] = HistoryTransaction(
            txID: txID,
            amountInSATS: amountInSATS,
            sender: sender.isNotEmpty ? sender : txID,
            toList: toList.isNotEmpty ? toList : txID,
            feeInSATS: feeInSATS,
            label: userLabel,
            inProgress: true);
      }
    }
    List<HistoryTransaction> newHistoryTransactions =
        newHistoryTransactionsMap.values.toList();
    newHistoryTransactions.sort((a, b) {
      if (a.createTimestamp == null && b.createTimestamp == null) {
        return -1;
      }
      if (a.createTimestamp == null) {
        return -1;
      }
      if (b.createTimestamp == null) {
        return 1;
      }
      return a.createTimestamp! > b.createTimestamp! ? -1 : 1;
    });
    if (_historyTransactions.length != newHistoryTransactions.length ||
        newUnconfirmed != unconfirmed ||
        newConfirmed != confirmed) {
      _historyTransactions = newHistoryTransactions;
      confirmed = newConfirmed;
      unconfirmed = newUnconfirmed;
      searchTransactions();
    }
    datasourceStreamSinkAdd();
    isLoadingTransactionHistory = false;
  }

  Future<void> loadIntegratedAddresses() async {
    List<String> integratedEmailIDs =
        accountID2IntegratedEmailIDs[currentAccount!.id]!;
    emailIntegrationEnable = integratedEmailIDs.isNotEmpty;
    datasourceStreamSinkAdd();
  }

  @override
  Future<void> selectWallet(int walletID) async {
    selectedWalletID = walletID;
    currentWallet = await DBHelper.walletDao!.findById(selectedWalletID);
    balance = 0;
  }

  @override
  void setOnBoard(BuildContext context) async{
    hasWallet = true;
    EasyLoading.show(
        status: "creating default wallet..", maskType: EasyLoadingMaskType.black);
    await WalletManager.autoCreateWallet();
    EasyLoading.dismiss();
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
    // Future.delayed(const Duration(seconds: 30), () {
    //   getUserSettings();
    // });
  }

  Future<void> updateFiatCurrencyInUserSettingProvider(
      FiatCurrency fiatCurrency) async {
    userSettingProvider.updateFiatCurrency(fiatCurrency);
    ProtonExchangeRate exchangeRate =
        await ExchangeRateService.getExchangeRate(fiatCurrency);
    userSettingProvider.updateExchangeRate(exchangeRate);
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

  Future<void> loadTransactionHistoryService() async {
    await Future.delayed(const Duration(seconds: 1), () async {
      await loadTransactionHistory();
    });
    loadTransactionHistoryService();
  }

  Future<void> syncWalletService() async {
    await Future.delayed(const Duration(seconds: 60), () async {
      await syncWallet();
    });
    syncWalletService();
  }

  @override
  Future<void> syncWallet() async {
    if (currentAccount != null) {
      String serverAccountID = currentAccount!.serverAccountID;
      if (!isSyncingMap.containsKey(serverAccountID)) {
        isSyncingMap[serverAccountID] = false;
      }
      bool otherIsSyncing = false;
      for (bool isSyncing in isSyncingMap.values) {
        otherIsSyncing = otherIsSyncing | isSyncing;
      }
      var walletBalance = await wallet!.getBalance();
      balance = walletBalance.total;
      datasourceStreamSinkAdd();
      if (otherIsSyncing) {
        await Future.delayed(const Duration(seconds: 5), () async {
          syncWallet();
        });
        return;
      }
      if (initialed &&
          isSyncingMap[serverAccountID]! == false &&
          wallet != null) {
        isSyncingMap[serverAccountID] = true;
        datasourceStreamSinkAdd();
        logger.d(
            "start syncing ${currentAccount!.labelDecrypt} at ${DateTime.now()}");
        await _lib.syncWallet(blockchain!, wallet!);
        var walletBalance = await wallet!.getBalance();
        balance = walletBalance.total;
        datasourceStreamSinkAdd();
        isSyncingMap[serverAccountID] = false;
        logger.d(
            "end syncing ${currentAccount!.labelDecrypt} at ${DateTime.now()}");
        await loadTransactionHistory();
      }
    }
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
    if (currentWallet != null) {
      try {
        SecretKey? secretKey =
            await WalletManager.getWalletKey(currentWallet!.serverWalletID);
        WalletAccount walletAccount = await proton_api.updateWalletAccountLabel(
            walletId: currentWallet!.serverWalletID,
            walletAccountId: accountModel.serverAccountID,
            newLabel: await WalletKeyHelper.encrypt(secretKey!, newName));
        accountModel.label = base64Decode(walletAccount.label);
        accountModel.labelDecrypt = newName;
        await DBHelper.accountDao!.update(accountModel);
        await refreshWalletID2Accounts(currentWallet!.serverWalletID);
      } catch (e) {
        logger.e(e);
      }
    }
  }

  @override
  Future<void> deleteAccount(
      String serverWalletID, String serverAccountID) async {
    if (initialed) {
      try {
        await proton_api.deleteWalletAccount(
            walletId: serverWalletID, walletAccountId: serverAccountID);
        await DBHelper.accountDao!.deleteByServerAccountID(serverAccountID);
        await refreshWalletID2Accounts(serverWalletID);
      } catch (e) {
        logger.e(e);
      }
    }
    datasourceStreamSinkAdd();
  }

  @override
  Future<void> checkPreference({bool runOnce = false}) async {
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
  void reloadPage() {
    datasourceStreamSinkAdd();
  }

  @override
  Future<void> updateEmailIntegration() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool(
        "todo_hadSetEmailIntegration_${currentAccount!.serverAccountID}", true);

    await loadIntegratedAddresses();
    datasourceStreamSinkAdd();
    for (int i = 0; i < defaultBitcoinAddressCountForOneEmail; i++) {
      addBitcoinAddress();
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
        WalletManager.deleteAddress(serverAddressID);
      }
    } catch (e) {
      logger.e(e.toString());
    }
    AccountModel accountModel =
        await DBHelper.accountDao!.findByServerAccountID(serverAccountID);
    accountID2IntegratedEmailIDs[accountModel.id!] =
        await WalletManager.getAccountAddressIDs(accountModel.serverAccountID);
    await loadIntegratedAddresses();
    datasourceStreamSinkAdd();
  }

  @override
  Future<void> logout() async {
    await UserSessionProvider().logout();
    await DBHelper.reset();
    coordinator.logout();
  }

  @override
  void move(NavigationIdentifier to) {
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
  void updateTransactionFilter(String filter) {
    transactionFilter = filter;
    datasourceStreamSinkAdd();
  }

  @override
  List<HistoryTransaction> getHistoryTransactionWithFilter() {
    List<HistoryTransaction> newHistoryTransactions = _historyTransactions;
    if (transactionFilter.contains("send")) {
      newHistoryTransactions = newHistoryTransactions
          .where((historyTransaction) => historyTransaction.amountInSATS < 0)
          .toList();
    }
    if (transactionFilter.contains("receive")) {
      newHistoryTransactions = newHistoryTransactions
          .where((historyTransaction) => historyTransaction.amountInSATS > 0)
          .toList();
    }
    return newHistoryTransactions;
  }

  void searchTransactions() {
    List<HistoryTransaction> newHistoryTransactions =
        getHistoryTransactionWithFilter();
    String searchKeyword = transactionSearchController.text.toLowerCase();
    if (searchKeyword.isNotEmpty) {
      newHistoryTransactions =
          newHistoryTransactions.where((historyTransaction) {
        return (historyTransaction.label ?? "")
                .toLowerCase()
                .contains(searchKeyword) ||
            historyTransaction.sender.toLowerCase().contains(searchKeyword) ||
            historyTransaction.toList.toLowerCase().contains(searchKeyword);
      }).toList();
    }
    historyTransactions = newHistoryTransactions;
  }

  @override
  Future<void> addWalletAccount(
      int walletID, ScriptType scriptType, String label) async {
    await WalletManager.addWalletAccount(walletID, scriptType, label);
    await Future.delayed(const Duration(
        milliseconds: 1000)); // wait for drawer refresh, it check every second
  }

  @override
  Future<void> addEmailAddressToWalletAccount(String serverWalletID,
      String serverAccountID, String serverAddressID) async {
    try {
      WalletAccount walletAccount = await proton_api.addEmailAddress(
          walletId: serverWalletID,
          walletAccountId: serverAccountID,
          addressId: serverAddressID);
      AccountModel accountModel =
          await DBHelper.accountDao!.findByServerAccountID(serverAccountID);
      for (EmailAddress address in walletAccount.addresses) {
        await WalletManager.addEmailAddressToWalletAccount(
            accountModel, address);
      }
      accountID2IntegratedEmailIDs[accountModel.id!] =
          await WalletManager.getAccountAddressIDs(
              accountModel.serverAccountID);
    } catch (e) {
      logger.e(e.toString());
    }
    datasourceStreamSinkAdd();
  }

  @override
  void showMoreTransactionHistory() {
    currentHistoryPage++;
    datasourceStreamSinkAdd();
  }

  @override
  void searchHistoryTransaction() {}

  @override
  void setSearchHistoryTextField(bool show) {
    showSearchHistoryTextField = show;
    datasourceStreamSinkAdd();
  }
}
