import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet/constants/address.key.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/transaction.detail.from.blockchain.dart';
import 'package:wallet/helper/exchange.rate.service.dart';
import 'package:wallet/helper/user.settings.provider.dart';
import 'package:wallet/managers/manager.dart';
import 'package:wallet/managers/providers/wallet.data.provider.dart';
import 'package:wallet/managers/secure.storage/secure.storage.dart';
import 'package:wallet/managers/secure.storage/secure.storage.manager.dart';
import 'package:wallet/models/bitcoin.address.model.dart';
import 'package:wallet/models/exchangerate.model.dart';
import 'package:wallet/models/transaction.info.model.dart';
import 'package:wallet/constants/app.config.dart';
import 'package:wallet/constants/history.transaction.dart';
import 'package:wallet/helper/bdk/helper.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/helper/walletkey_helper.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/transaction.model.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/rust/bdk/types.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/rust/proton_api/proton_address.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/debug/bdk.test.dart';

// this is wallet manager. all wallet's from one account.

class CachedAccountBitcoinAddressInfo {
  Map<String, int> bitcoinAddressIndexMap =
      {}; // key: bitcoinAddress, value: bitcoinAddressIndex
  int highestUsedIndex = 0;

  void updateHighestUsedIndex(int index) {
    highestUsedIndex = max(highestUsedIndex, index);
  }
}

class ProtonWalletManager implements Manager {
  final SecureStorageManager storage;

  // final WalletsDataProvider walletsDataProvider;

  // wallet key
  // static const String walletKey = "WALLET_KEY";

  WalletModel? currentWallet;
  AccountModel? currentAccount; // show Wallet View when no account pick

  // wallet tree
  List<WalletData>? walletsData;

  List<WalletModel> wallets = [];
  List<AccountModel> accounts = [];

  List<ProtonAddress> protonAddresses = [];
  List<AccountModel> currentAccounts = [];
  List<BitcoinAddressModel> currentBitcoinAddresses = [];
  Map<String, CachedAccountBitcoinAddressInfo>
      serverAccountID2BitcoinAddresses = {};

  List<HistoryTransaction> historyTransactions = [];
  List<HistoryTransaction> historyTransactionsAfterFilter = [];
  Map<String, bool> isWalletSyncing = {};
  Map<String, List<String>> bitcoinAddress2transactionIDs = {};
  final Map<int, bool> _hasPassphrase = {};
  final Map<int, List<String>> _accountID2IntegratedEmailIDs = {};
  int currentBalance = 0;
  final BdkLibrary _lib = BdkLibrary(coinType: appConfig.coinType);
  Blockchain? blockchain;
  String transactionFilter = "";
  List<AddressKey> addressKeys = [];
  FiatCurrency newAccountFiatCurrency = defaultFiatCurrency;

  ProtonWalletManager({required this.storage});

  @override
  Future<void> init() async {
    // get wallet data
    // walletsData = await walletsDataProvider.getWallets();

    blockchain ??= await _lib.initializeBlockchain(false);
    wallets = (await DBHelper.walletDao!.findAll()).cast<WalletModel>();
    accounts = (await DBHelper.accountDao!.findAll()).cast<AccountModel>();

    for (AccountModel accountModel in accounts) {
      accountModel.balance = await WalletManager.getWalletAccountBalance(
          accountModel.walletID, accountModel.id ?? -1);
      // var wallet =
      //     wallets.where((element) => element.id == accountModel.walletID).first;

      // we dont need to predecrypt. we decrypt when use and cache clear text in memory only
      // SecretKey secretKey = await getWalletKey(wallet.serverWalletID);
      // await accountModel.decrypt(secretKey);
    }
    // check if wallet has passphrase
    for (WalletModel walletModel in wallets) {
      await checkPassphrase(walletModel);

      // sync all wallet accounts when init
      for (AccountModel accountModel in accounts) {
        if (accountModel.walletID == walletModel.id!) {
          Wallet? wallet = await WalletManager.loadWalletWithID(
              walletModel.id!, accountModel.id!);
          if (wallet != null) {
            syncWallet(wallet, walletModel, accountModel);
          }
        }
      }
    }
    syncAllWallets();
    logger.i("Start buildCachedBitcoinAddressMap()");
    await buildCachedBitcoinAddressMap();
    logger.i("End buildCachedBitcoinAddressMap()");
  }

  bool isSyncing() {
    if (currentAccount != null) {
      return isWalletSyncing[currentAccount!.serverAccountID] ?? false;
    }
    if (currentWallet != null) {
      // for wallet view
      for (AccountModel accountModel in accounts) {
        if (isWalletSyncing.containsKey(accountModel.serverAccountID)) {
          if (isWalletSyncing[accountModel.serverAccountID] == true) {
            return true;
          }
        }
      }
    }
    return false;
  }

  Future<void> syncWallet(
      Wallet wallet, WalletModel walletModel, AccountModel accountModel) async {
    if (hasPassphrase(walletModel) == false) {
      return;
    }
    try {
      if ((isWalletSyncing[accountModel.serverAccountID] ?? false) == false) {
        isWalletSyncing[accountModel.serverAccountID] = true;
        logger.i("set isWalletSyncing[${accountModel.serverAccountID}] = true");
        var balance = await wallet.getBalance();
        accountModel.balance =
            (balance.trustedPending + balance.confirmed).toDouble();
        logger.d(
            "start syncing ${accountModel.labelDecrypt} at ${DateTime.now()}, currentBalance = $currentBalance");
        await _lib.syncWallet(blockchain!, wallet);
        balance = await wallet.getBalance();
        accountModel.balance =
            (balance.trustedPending + balance.confirmed).toDouble();
        await setBalance();
        logger.d(
            "end syncing ${accountModel.labelDecrypt} at ${DateTime.now()}, currentBalance = $currentBalance");
        await insertOrUpdateWalletAccount(accountModel);
        isWalletSyncing[accountModel.serverAccountID] = false;
        await setCurrentTransactions();
      }
    } catch (e) {
      logger.e(e.toString());
    }
  }

  bool hasPassphrase(WalletModel walletModel) {
    int id = walletModel.id ?? -1;
    if (_hasPassphrase.containsKey(id)) {
      return _hasPassphrase[id] ?? walletModel.passphrase == 0;
    }
    return false;
  }

  Future<void> checkPassphrase(WalletModel walletModel) async {
    int id = walletModel.id ?? -1;
    if (id == -1) {
      logger.e("ID = -1...");
      return;
    }
    if (walletModel.passphrase != 0) {
      String passphrase = await getPassphrase(walletModel.serverWalletID);
      _hasPassphrase[id] = passphrase.isNotEmpty;
    } else {
      _hasPassphrase[id] = true; // no need passphrase
    }
  }

  ///
  Future<void> setPassphraseWithCheck(
      WalletModel walletModel, String passphrase) async {
    try {
      await setPassphrase(walletModel.serverWalletID, passphrase);
      await checkPassphrase(walletModel);
    } catch (e) {
      logger.e(e.toString());
    }
  }

  Future<void> setPassphrase(String serverWalletID, String passphrase) async {
    try {
      await storage.set(serverWalletID, passphrase);
    } catch (e) {
      logger.e(e.toString());
    }
  }

  Future<String> getPassphrase(String serverWalletID) async {
    return await storage.get(serverWalletID);
  }

  void destroy() {
    clearAll();
  }

  void clearCurrent() {
    currentWallet = null;
    currentAccount = null;
    currentBalance = 0;
    currentAccounts.clear();
    currentBitcoinAddresses.clear();
    serverAccountID2BitcoinAddresses.clear();
    historyTransactionsAfterFilter.clear();
  }

  void clearAll() {
    clearCurrent();
    blockchain = null;
    transactionFilter = "";
    addressKeys.clear();
    wallets.clear();
    accounts.clear();
    isWalletSyncing.clear();
    _hasPassphrase.clear();
    historyTransactions.clear();
    _accountID2IntegratedEmailIDs.clear();
    bitcoinAddress2transactionIDs.clear();
  }

  Future<void> updateCurrentWalletName(String newName) async {
    if (currentWallet != null) {
      currentWallet!.name = newName;
      await insertOrUpdateWallet(currentWallet!);
    }
  }

  Future<void> setWallet(WalletModel walletModel) async {
    try {
      historyTransactions.clear();

      currentWallet = walletModel;
      currentAccount = null;
      await getCurrentWalletAccounts();
      for (AccountModel accountModel in currentAccounts) {
        Wallet? wallet = await WalletManager.loadWalletWithID(
            currentWallet!.id!, accountModel.id!);
        if (wallet != null) {
          syncWallet(wallet, walletModel, accountModel);
        }
        initLocalBitcoinAddresses(walletModel, accountModel);
      }
      currentBitcoinAddresses = await DBHelper.bitcoinAddressDao!
          .findByWallet(currentWallet!.id!, orderBy: "asc");
      await setBalance();
      await setCurrentTransactions();
    } catch (e) {
      logger.e(e.toString());
    }
  }

  Future<void> setBalance() async {
    int newBalance = 0;
    if (currentWallet != null) {
      if (currentAccount == null) {
        for (AccountModel accountModel in currentAccounts) {
          try {
            Wallet? wallet = await WalletManager.loadWalletWithID(
                currentWallet!.id!, accountModel.id!);
            if (wallet == null) {
              continue;
            }
            Balance balance = await wallet.getBalance();
            newBalance += balance.trustedPending + balance.confirmed;
          } catch (e) {
            logger.e(e.toString());
          }
        }
      } else {
        try {
          Wallet? wallet = await WalletManager.loadWalletWithID(
              currentWallet!.id!, currentAccount!.id!);
          if (wallet != null) {
            Balance balance = await wallet.getBalance();
            newBalance += balance.trustedPending + balance.confirmed;
          }
        } catch (e) {
          logger.e(e.toString());
        }
      }
    }
    currentBalance = newBalance;
  }

  Future<void> setWalletAccount(
      WalletModel walletModel, AccountModel accountModel) async {
    try {
      historyTransactions.clear();

      currentWallet = walletModel;
      currentAccount = accountModel;
      await getCurrentWalletAccounts();
      Wallet? wallet = await WalletManager.loadWalletWithID(
          currentWallet!.id!, currentAccount!.id!);
      currentBitcoinAddresses = await DBHelper.bitcoinAddressDao!
          .findByWalletAccount(currentWallet!.id!, currentAccount!.id!,
              orderBy: "asc");
      if (wallet == null) return;
      syncWallet(wallet, walletModel, accountModel);
      initLocalBitcoinAddresses(walletModel, accountModel);
      await setBalance();
      await setCurrentTransactions();
      logger.i("setWalletAccount() finish!");
    } catch (e) {
      logger.e(e.toString());
    }
  }

  Future<void> getCurrentWalletAccounts() async {
    currentAccounts.clear();
    if (currentWallet != null) {
      for (AccountModel accountModel in accounts) {
        if (accountModel.walletID == currentWallet!.id!) {
          currentAccounts.add(accountModel);
          await setIntegratedEmailIDs(accountModel);
        }
      }
    }
    logger.i("getCurrentWalletAccounts finish!");
  }

  List<AccountModel> getAccounts(WalletModel walletModel) {
    List<AccountModel> accountsInWallet = [];
    for (AccountModel accountModel in accounts) {
      if (accountModel.walletID == walletModel.id!) {
        accountsInWallet.add(accountModel);
      }
    }
    return accountsInWallet;
  }

  Future<void> setIntegratedEmailIDs(AccountModel accountModel) async {
    int id = accountModel.id!;
    _accountID2IntegratedEmailIDs[id] =
        await WalletManager.getAccountAddressIDs(accountModel.serverAccountID);
  }

  List<String> getIntegratedEmailIDs(AccountModel accountModel) {
    int id = accountModel.id!;
    return _accountID2IntegratedEmailIDs[id] ?? [];
  }

  List<String> getAllIntegratedEmailIDs() {
    List<String> results = [];
    for (List<String> list in _accountID2IntegratedEmailIDs.values) {
      results.addAll(list);
    }
    return results;
  }

  Future<void> insertOrUpdateWallet(WalletModel newWalletModel) async {
    int indexToUpdate = -1;
    for (WalletModel walletModel in wallets) {
      if (newWalletModel.serverWalletID == walletModel.serverWalletID) {
        indexToUpdate = wallets.indexOf(walletModel);
        break;
      }
    }
    if (indexToUpdate > -1) {
      wallets[indexToUpdate] = newWalletModel;
    } else {
      wallets.add(newWalletModel);
    }
    if (newWalletModel.serverWalletID ==
        (currentWallet?.serverWalletID ?? "")) {
      currentWallet = newWalletModel;
    }
    await checkPassphrase(newWalletModel);
  }

  void syncAllWallets() async {
    for (WalletModel walletModel in wallets) {
      for (AccountModel accountModel in accounts) {
        if (accountModel.walletID == walletModel.id!) {
          Wallet? wallet = await WalletManager.loadWalletWithID(
              walletModel.id!, accountModel.id!);
          if (wallet != null) {
            syncWallet(wallet, walletModel, accountModel);
          }
        }
      }
    }
  }

  Future<void> buildCachedBitcoinAddressMap() async {
    for (WalletModel walletModel in wallets) {
      for (AccountModel accountModel in accounts) {
        if (accountModel.walletID == walletModel.id!) {
          if (serverAccountID2BitcoinAddresses
                  .containsKey(accountModel.serverAccountID) ==
              false) {
            serverAccountID2BitcoinAddresses[accountModel.serverAccountID] =
                CachedAccountBitcoinAddressInfo();
            Wallet? wallet = await WalletManager.loadWalletWithID(
                walletModel.id!, accountModel.id!);
            if (wallet == null) continue;
            for (int addressIndex = 0; addressIndex <= 100; addressIndex++) {
              var addressInfo =
                  await _lib.getAddress(wallet, addressIndex: addressIndex);
              String bitcoinAddress = addressInfo.address;
              serverAccountID2BitcoinAddresses[accountModel.serverAccountID]!
                  .bitcoinAddressIndexMap[bitcoinAddress] = addressIndex;
            }
          }
        }
      }
    }
  }

  Future<void> setDefaultWallet() async {
    WalletModel? walletModel =
        await DBHelper.walletDao!.getFirstPriorityWallet();
    if (walletModel != null) {
      if (hasPassphrase(walletModel) == false) {
        clearCurrent();
        logger.i("no passphrase for default wallet");
      } else {
        await setWallet(walletModel);
      }
    } else {
      // clear all data since there is no wallet in local tables
      destroy();
    }
  }

  Future<void> deleteWallet(WalletModel deletedWalletModel) async {
    int indexToDelete = -1;
    for (WalletModel walletModel in wallets) {
      if (deletedWalletModel.serverWalletID == walletModel.serverWalletID) {
        indexToDelete = wallets.indexOf(walletModel);
        break;
      }
    }
    if (indexToDelete >= 0) {
      wallets.removeAt(indexToDelete);
    }
    if ((currentWallet?.serverWalletID ?? "") ==
        deletedWalletModel.serverWalletID) {
      await setDefaultWallet();
    }
    for (AccountModel accountModel in accounts) {
      if (accountModel.walletID == deletedWalletModel.id) {
        deleteWalletAccount(accountModel, rootWalletDeleted: true);
      }
    }
  }

  Future<void> insertOrUpdateWalletAccount(AccountModel newAccountModel) async {
    int indexToUpdate = -1;
    newAccountModel.balance = await WalletManager.getWalletAccountBalance(
        newAccountModel.walletID, newAccountModel.id ?? -1);
    for (AccountModel accountModel in accounts) {
      if (newAccountModel.serverAccountID == accountModel.serverAccountID) {
        indexToUpdate = accounts.indexOf(accountModel);
        break;
      }
    }
    var wallet = wallets
        .where((element) => element.id == newAccountModel.walletID)
        .first;
    SecretKey secretKey =
        await WalletManager.getWalletKey(wallet.serverWalletID);
    await newAccountModel.decrypt(secretKey);
    if (indexToUpdate > -1) {
      accounts[indexToUpdate] = newAccountModel;
    } else {
      accounts.add(newAccountModel);
    }
    if (newAccountModel.serverAccountID ==
        (currentAccount?.serverAccountID ?? "")) {
      currentAccount = newAccountModel;
    }
    await setIntegratedEmailIDs(newAccountModel);
    await buildCachedBitcoinAddressMap();
    await getCurrentWalletAccounts();
  }

  Future<void> deleteWalletAccount(AccountModel deletedAccountModel,
      {bool rootWalletDeleted = false}) async {
    int indexToDelete = -1;
    for (AccountModel accountModel in accounts) {
      if (deletedAccountModel.serverAccountID == accountModel.serverAccountID) {
        indexToDelete = accounts.indexOf(accountModel);
        break;
      }
    }
    if (indexToDelete >= 0) {
      accounts.removeAt(indexToDelete);
    }
    _accountID2IntegratedEmailIDs.remove(deletedAccountModel.id!);

    if (rootWalletDeleted == false) {
      await getCurrentWalletAccounts();
      if (deletedAccountModel.serverAccountID ==
          (currentAccount?.serverAccountID ?? "")) {
        if (currentAccounts.isNotEmpty && currentWallet != null) {
          await setWalletAccount(currentWallet!, currentAccounts.first);
        } else {
          await setDefaultWallet();
        }
      }
    }
  }

  Future<void> initLocalBitcoinAddresses(
      WalletModel walletModel, AccountModel accountModel) async {
    await WalletManager.syncBitcoinAddressIndex(
        walletModel.serverWalletID, accountModel.serverAccountID);

    Wallet? wallet =
        await WalletManager.loadWalletWithID(walletModel.id!, accountModel.id!);
    //TODO:: double check this could be null if wallet is not loaded
    if (wallet == null) return;
    BitcoinAddressModel? bitcoinAddressModel = await DBHelper.bitcoinAddressDao!
        .findLatestUnusedLocalBitcoinAddress(
            walletModel.id!, accountModel.id ?? 0);
    int maxAddressIndex = 0;
    if (bitcoinAddressModel != null && bitcoinAddressModel.used == 0) {
      maxAddressIndex = bitcoinAddressModel.bitcoinAddressIndex;
    } else {
      maxAddressIndex = await WalletManager.getBitcoinAddressIndex(
          walletModel.serverWalletID, accountModel.serverAccountID);
    }

    maxAddressIndex = max(
        maxAddressIndex,
        serverAccountID2BitcoinAddresses[accountModel.serverAccountID]!
                .highestUsedIndex +
            1);
    // TODO:: update local one in sharepreference so that receive bitcoin address can be the correct one

    for (int addressIndex = 0;
        addressIndex <= maxAddressIndex;
        addressIndex++) {
      var addressInfo =
          await _lib.getAddress(wallet, addressIndex: addressIndex);
      String bitcoinAddress = addressInfo.address;
      bitcoinAddressModel = await DBHelper.bitcoinAddressDao!
          .findBitcoinAddressInAccount(bitcoinAddress, accountModel.id!);
      if (bitcoinAddressModel == null) {
        // only insert bitcoinAddress if it's not in db
        await DBHelper.bitcoinAddressDao!.insertOrUpdate(
            walletID: walletModel.id!,
            accountID: accountModel.id!,
            bitcoinAddress: bitcoinAddress,
            bitcoinAddressIndex: addressIndex,
            inEmailIntegrationPool: 0,
            used: 0);
      }
    }
  }

  Future<void> setCurrentTransactions() async {
    if (!validState) return;
    bool bdkSynced = false;
    Wallet? wallet;
    List<AccountModel> accountsToCheckTransaction = [];
    WalletModel? oldWalletModel = currentWallet;
    AccountModel? oldAccountModel = currentAccount;
    if (addressKeys.isEmpty) {
      addressKeys = await WalletManager.getAddressKeys();
    }
    if (protonAddresses.isEmpty) {
      List<ProtonAddress> addresses = await WalletManager.getProtonAddress();
      protonAddresses =
          addresses.where((element) => element.status == 1).toList();
    }
    if (oldWalletModel != null && currentAccount != null) {
      // wallet account view
      accountsToCheckTransaction.add(currentAccount!);
    } else if (oldWalletModel != null) {
      // wallet view
      await getCurrentWalletAccounts();
      accountsToCheckTransaction = currentAccounts;
    }
    List<HistoryTransaction> newHistoryTransactions = [];
    for (AccountModel accountModel in accountsToCheckTransaction) {
      if (!validState) return;
      Map<String, HistoryTransaction> newHistoryTransactionsMap = {};
      try {
        wallet = await WalletManager.loadWalletWithID(
          oldWalletModel!.id!,
          accountModel.id!,
        );
      } catch (e) {
        logger.e(e.toString());
        continue;
      }
      if (wallet == null) {
        continue;
      }
      // get transactions from bdk
      List<TransactionDetails> transactionHistoryFromBDK =
          await _lib.getAllTransactions(wallet);
      bdkSynced =
          bdkSynced | transactionHistoryFromBDK.isNotEmpty; // for wallet view
      SecretKey? secretKey =
          await WalletManager.getWalletKey(oldWalletModel.serverWalletID);

      for (TransactionDetails transactionDetail in transactionHistoryFromBDK) {
        if (!validState) return;
        String txID = transactionDetail.txid;
        List<TxOut> output = await transactionDetail.transaction!.output();
        List<String> recipientBitcoinAddresses = [];
        for (TxOut txOut in output) {
          if (!validState) return;
          Address recipientAddress =
              await _lib.addressFromScript(txOut.scriptPubkey);
          String bitcoinAddress = recipientAddress.toString();
          BitcoinAddressModel? bitcoinAddressModel = await DBHelper
              .bitcoinAddressDao!
              .findBitcoinAddressInAccount(bitcoinAddress, accountModel.id!);
          if (bitcoinAddressModel != null) {
            bitcoinAddressModel.used = 1;
            await DBHelper.bitcoinAddressDao!.update(bitcoinAddressModel);

            if (bitcoinAddress2transactionIDs.containsKey(bitcoinAddress) ==
                false) {
              bitcoinAddress2transactionIDs[bitcoinAddress] = [txID];
            } else {
              if (bitcoinAddress2transactionIDs[bitcoinAddress]!
                      .contains(txID) ==
                  false) {
                bitcoinAddress2transactionIDs[bitcoinAddress]!.add(txID);
              }
            }
          } else {
            if (serverAccountID2BitcoinAddresses
                .containsKey(accountModel.serverAccountID)) {
              if (serverAccountID2BitcoinAddresses[
                          accountModel.serverAccountID]!
                      .bitcoinAddressIndexMap
                      .containsKey(bitcoinAddress) ==
                  false) {
                // not self bitcoin address, so it's recipients' address
                recipientBitcoinAddresses.add(bitcoinAddress);
              } else {
                serverAccountID2BitcoinAddresses[accountModel.serverAccountID]!
                    .updateHighestUsedIndex(serverAccountID2BitcoinAddresses[
                                accountModel.serverAccountID]!
                            .bitcoinAddressIndexMap[bitcoinAddress] ??
                        0);
              }
            }
          }
        }

        TransactionModel? transactionModel = await DBHelper.transactionDao!
            .find(utf8.encode(txID), oldWalletModel.serverWalletID,
                accountModel.serverAccountID);
        String userLabel = transactionModel != null
            ? await WalletKeyHelper.decrypt(
                secretKey, utf8.decode(transactionModel.label))
            : "";
        String toList = "";
        String sender = "";
        String body = "";
        if (transactionModel != null) {
          String encryptedToList = transactionModel.tolist ?? "";
          String encryptedSender = transactionModel.sender ?? "";
          String encryptedBody = transactionModel.body ?? "";
          for (AddressKey addressKey in addressKeys) {
            try {
              if (encryptedToList.isNotEmpty) {
                toList = addressKey.decrypt(encryptedToList);
              }
            } catch (e) {
              // logger.e(e.toString());
            }
            try {
              if (encryptedSender.isNotEmpty) {
                sender = addressKey.decrypt(encryptedSender);
              }
            } catch (e) {
              // logger.e(e.toString());
            }
            try {
              if (encryptedBody.isNotEmpty) {
                body = addressKey.decrypt(encryptedBody);
              }
            } catch (e) {
              // logger.e(e.toString());
            }
            if (sender.isNotEmpty || toList.isNotEmpty) {
              break;
            }
            try {
              if (encryptedToList.isNotEmpty) {
                toList = addressKey.decryptBinary(encryptedToList);
              }
            } catch (e) {
              // logger.e(e.toString());
            }
            try {
              if (encryptedSender.isNotEmpty) {
                sender = addressKey.decryptBinary(encryptedSender);
              }
            } catch (e) {
              // logger.e(e.toString());
            }
            if (sender.isNotEmpty || toList.isNotEmpty) {
              break;
            }
          }
        }
        if (sender == "null") {
          sender = "";
        }
        if (toList == "null") {
          toList = "";
        }
        int amountInSATS = transactionDetail.received - transactionDetail.sent;
        if (amountInSATS < 0) {
          // bdk sent include fee, so need add back to make display send amount without fee
          amountInSATS += transactionDetail.fee ?? 0;
        }
        String key = "$txID-${accountModel.serverAccountID}";

        ProtonExchangeRate exchangeRate =
            await getExchangeRateFromTransactionModel(transactionModel);

        newHistoryTransactionsMap[key] = HistoryTransaction(
          txID: txID,
          createTimestamp: transactionDetail.confirmationTime?.timestamp,
          updateTimestamp: transactionDetail.confirmationTime?.timestamp,
          amountInSATS: amountInSATS,
          sender: sender.isNotEmpty ? sender : "Unknown",
          toList:
              toList.isNotEmpty ? toList : recipientBitcoinAddresses.join(", "),
          feeInSATS: transactionDetail.fee ?? 0,
          label: userLabel,
          inProgress: transactionDetail.confirmationTime == null,
          accountModel: accountModel,
          body: body.isNotEmpty ? body : null,
          exchangeRate: exchangeRate,
        );
        updateBitcoinAddressUsed(txID,
            accountModel); // update local bitcoin address to set used, TODO:: fix performance here
      }

      // get transactions from local db (transactions in progress, and not in synced bdk transactions)
      List<TransactionModel> transactionModels = await DBHelper.transactionDao!
          .findAllByServerAccountID(accountModel.serverAccountID);
      for (TransactionModel transactionModel in transactionModels) {
        if (!validState) return;
        String userLabel = await WalletKeyHelper.decrypt(
            secretKey, utf8.decode(transactionModel.label));

        String txID = utf8.decode(transactionModel.externalTransactionID);
        String key = "$txID-${accountModel.serverAccountID}";
        if (txID.isEmpty) {
          continue;
        }
        if (newHistoryTransactionsMap.containsKey(key)) {
          continue;
        }
        String toList = "";
        String sender = "";
        String body = "";
        String encryptedToList = transactionModel.tolist ?? "";
        String encryptedSender = transactionModel.sender ?? "";
        String encryptedBody = transactionModel.body ?? "";
        for (AddressKey addressKey in addressKeys) {
          if (!validState) return;
          try {
            if (encryptedToList.isNotEmpty) {
              toList = addressKey.decrypt(encryptedToList);
            }
          } catch (e) {
            // logger.e(e.toString());
          }
          try {
            if (encryptedSender.isNotEmpty) {
              sender = addressKey.decrypt(encryptedSender);
            }
          } catch (e) {
            // logger.e(e.toString());
          }
          try {
            if (encryptedBody.isNotEmpty) {
              body = addressKey.decrypt(encryptedBody);
            }
          } catch (e) {
            // logger.e(e.toString());
          }
          if (sender.isNotEmpty || toList.isNotEmpty) {
            break;
          }
          try {
            if (encryptedToList.isNotEmpty) {
              toList = addressKey.decryptBinary(encryptedToList);
            }
          } catch (e) {
            // logger.e(e.toString());
          }
          try {
            if (encryptedSender.isNotEmpty) {
              sender = addressKey.decryptBinary(encryptedSender);
            }
          } catch (e) {
            // logger.e(e.toString());
          }
          if (sender.isNotEmpty || toList.isNotEmpty) {
            break;
          }
        }
        if (sender == "null") {
          sender = "";
        }
        if (toList == "null") {
          toList = "";
        }
        List<TransactionInfoModel> transactionInfoModels = [];
        try {
          transactionInfoModels = await DBHelper.transactionInfoDao!
              .findAllRecipients(utf8.encode(txID),
                  oldWalletModel.serverWalletID, accountModel.serverAccountID);
        } catch (e) {
          logger.e(e.toString());
        }
        if (transactionInfoModels.isNotEmpty) {
          // get transaction info locally, for sender
          int amountInSATS = 0;
          int feeInSATS = 0;
          for (TransactionInfoModel transactionInfoModel
              in transactionInfoModels) {
            if (!validState) return;
            amountInSATS += transactionInfoModel.isSend == 1
                ? -transactionInfoModel.amountInSATS
                : transactionInfoModel.amountInSATS;
            feeInSATS = transactionInfoModel
                .feeInSATS; // all recipients have same fee since its same transaction
          }

          ProtonExchangeRate exchangeRate =
              await getExchangeRateFromTransactionModel(transactionModel);

          newHistoryTransactionsMap[key] = HistoryTransaction(
            txID: txID,
            amountInSATS: amountInSATS,
            sender: sender.isNotEmpty ? sender : "Unknown",
            toList: toList.isNotEmpty ? toList : "Unknown",
            feeInSATS: feeInSATS,
            label: userLabel,
            inProgress: true,
            accountModel: accountModel,
            body: body.isNotEmpty ? body : null,
            exchangeRate: exchangeRate,
          );
        } else {
          // get transaction info from blockstream or esplora, for recipients
          try {
            TransactionDetailFromBlockChain? transactionDetailFromBlockChain;
            for (int i = 0; i < 5; i++) {
              transactionDetailFromBlockChain =
                  await WalletManager.getTransactionDetailsFromBlockStream(
                      txID);
              try {
                if (transactionDetailFromBlockChain != null) {
                  break;
                }
              } catch (e) {
                logger.e(e.toString());
              }
              await Future.delayed(const Duration(seconds: 1));
            }
            if (transactionDetailFromBlockChain != null) {
              Recipient? me;
              for (Recipient recipient
                  in transactionDetailFromBlockChain.recipients) {
                BitcoinAddressModel? bitcoinAddressModel = await DBHelper
                    .bitcoinAddressDao!
                    .findBitcoinAddressInAccount(
                        recipient.bitcoinAddress, accountModel.id!);
                if (bitcoinAddressModel != null) {
                  bitcoinAddressModel.used = 1;
                  await DBHelper.bitcoinAddressDao!.update(bitcoinAddressModel);
                  me = recipient;

                  if (bitcoinAddress2transactionIDs
                          .containsKey(recipient.bitcoinAddress) ==
                      false) {
                    bitcoinAddress2transactionIDs[recipient.bitcoinAddress] = [
                      txID
                    ];
                  } else {
                    if (bitcoinAddress2transactionIDs[recipient.bitcoinAddress]!
                            .contains(txID) ==
                        false) {
                      bitcoinAddress2transactionIDs[recipient.bitcoinAddress]!
                          .add(txID);
                    }
                  }
                  break;
                }
              }
              if (me != null) {
                ProtonExchangeRate exchangeRate =
                    await getExchangeRateFromTransactionModel(transactionModel);
                newHistoryTransactionsMap[key] = HistoryTransaction(
                  txID: txID,
                  amountInSATS: me.amountInSATS,
                  sender: sender.isNotEmpty ? sender : "Unknown",
                  toList: toList.isNotEmpty ? toList : "Unknown",
                  feeInSATS: transactionDetailFromBlockChain.feeInSATS,
                  label: userLabel,
                  inProgress: true,
                  accountModel: accountModel,
                  body: body.isNotEmpty ? body : null,
                  exchangeRate: exchangeRate,
                );
              } else {
                // logger.i("Cannot find this tx, $txID");
              }
            }
          } catch (e) {
            logger.e(e.toString());
          }
        }
      }
      newHistoryTransactions += newHistoryTransactionsMap.values.toList();
      initLocalBitcoinAddresses(oldWalletModel, accountModel);
    }
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
    if (bdkSynced &&
        (oldWalletModel?.serverWalletID ?? "") ==
            (currentWallet?.serverWalletID ?? "") &&
        (oldAccountModel?.serverAccountID ?? "") ==
            (currentAccount?.serverAccountID ?? "")) {
      historyTransactions = newHistoryTransactions;
      applyHistoryTransactionFilterAndKeyword(transactionFilter, "");
      logger.i("setCurrentTransactions finish()!");
    }
    // });
  }

  Future<ProtonExchangeRate> getExchangeRateFromTransactionModel(
      TransactionModel? transactionModel) async {
    ProtonExchangeRate? exchangeRate;
    if (transactionModel != null &&
        transactionModel.exchangeRateID.isNotEmpty) {
      ExchangeRateModel? exchangeRateModel = await DBHelper.exchangeRateDao!
          .findByServerID(transactionModel.exchangeRateID);
      if (exchangeRateModel != null) {
        BitcoinUnit bitcoinUnit = BitcoinUnit.values.firstWhere(
            (v) =>
                v.name.toUpperCase() ==
                exchangeRateModel.bitcoinUnit.toUpperCase(),
            orElse: () => defaultBitcoinUnit);
        FiatCurrency fiatCurrency = FiatCurrency.values.firstWhere(
            (v) =>
                v.name.toUpperCase() ==
                exchangeRateModel.fiatCurrency.toUpperCase(),
            orElse: () => defaultFiatCurrency);
        exchangeRate = ProtonExchangeRate(
          id: exchangeRateModel.serverID,
          bitcoinUnit: bitcoinUnit,
          fiatCurrency: fiatCurrency,
          exchangeRateTime: exchangeRateModel.exchangeRateTime,
          exchangeRate: exchangeRateModel.exchangeRate,
          cents: exchangeRateModel.cents,
        );
      }
    }
    exchangeRate ??= await ExchangeRateService.getExchangeRate(
        Provider.of<UserSettingProvider>(
                Coordinator.rootNavigatorKey.currentContext!,
                listen: false)
            .walletUserSetting
            .fiatCurrency,
        time: transactionModel?.transactionTime != null
            ? int.parse(transactionModel?.transactionTime ?? "0")
            : null);
    return exchangeRate;
  }

  int getAccountCounts(WalletModel walletModel) {
    int count = 0;
    for (AccountModel accountModel in accounts) {
      if (accountModel.walletID == (walletModel.id ?? -1)) {
        count++;
      }
    }
    return count;
  }

  void applyHistoryTransactionFilterAndKeyword(String filter, String keyword) {
    transactionFilter = filter;
    List<HistoryTransaction> newHistoryTransactions = [];
    if (filter.isNotEmpty) {
      if (filter == "receive") {
        newHistoryTransactions =
            historyTransactions.where((t) => t.amountInSATS >= 0).toList();
      } else if (filter == "send") {
        newHistoryTransactions =
            historyTransactions.where((t) => t.amountInSATS < 0).toList();
      }
    } else {
      newHistoryTransactions = historyTransactions;
    }

    if (keyword.isNotEmpty) {
      newHistoryTransactions = newHistoryTransactions.where((t) {
        if ((t.label ?? "").toLowerCase().contains(keyword)) {
          return true;
        }
        if (t.sender.toLowerCase().contains(keyword)) {
          return true;
        }
        if (t.toList.toLowerCase().contains(keyword)) {
          return true;
        }
        return false;
      }).toList();
    }
    historyTransactionsAfterFilter = newHistoryTransactions;
  }

  Future<void> updateBitcoinAddressUsed(
      String txID, AccountModel accountModel) async {
    TransactionDetailFromBlockChain? transactionDetailFromBlockChain;
    for (int i = 0; i < 5; i++) {
      transactionDetailFromBlockChain =
          await WalletManager.getTransactionDetailsFromBlockStream(txID);
      try {
        if (transactionDetailFromBlockChain != null) {
          break;
        }
      } catch (e) {
        logger.e(e.toString());
      }
      await Future.delayed(const Duration(seconds: 1));
    }
    if (transactionDetailFromBlockChain != null) {
      for (Recipient recipient in transactionDetailFromBlockChain.recipients) {
        if (!validState) return;

        BitcoinAddressModel? bitcoinAddressModel =
            await DBHelper.bitcoinAddressDao!.findBitcoinAddressInAccount(
                recipient.bitcoinAddress, accountModel.id!);
        if (bitcoinAddressModel != null) {
          bitcoinAddressModel.used = 1;

          if (bitcoinAddress2transactionIDs
                  .containsKey(recipient.bitcoinAddress) ==
              false) {
            bitcoinAddress2transactionIDs[recipient.bitcoinAddress] = [txID];
          } else {
            if (bitcoinAddress2transactionIDs[recipient.bitcoinAddress]!
                    .contains(txID) ==
                false) {
              bitcoinAddress2transactionIDs[recipient.bitcoinAddress]!
                  .add(txID);
            }
          }
          await DBHelper.bitcoinAddressDao!.update(bitcoinAddressModel);
          break;
        }
      }
    }
  }

  List<String> getTransactionIDsByBitcoinAddress(String bitcoinAddress) {
    return bitcoinAddress2transactionIDs[bitcoinAddress] ?? [];
  }

  String getAccountName(int accountID) {
    for (AccountModel accountModel in accounts) {
      if (accountID == accountModel.id) {
        return accountModel.labelDecrypt;
      }
    }
    return "Unknown Account";
  }

  @override
  Future<void> dispose() async {}

  bool validState = true;

  @override
  Future<void> logout() async {
    // validState = false;
  }

  @override
  Future<void> login(String userID) async {
    validState = true;
  }
}

class ProtonWalletProvider with ChangeNotifier {
  late ProtonWalletManager protonWallet;
  UserSettingProvider? userSettingProvider;

  ProtonWalletProvider() {
    var storage = SecureStorageManager(storage: SecureStorage()); // TODO: temp
    protonWallet = ProtonWalletManager(storage: storage);
  }

  Future<void> init() async {
    try {
      userSettingProvider = Provider.of<UserSettingProvider>(
          Coordinator.rootNavigatorKey.currentContext!,
          listen: false);
      await protonWallet.init();
      await setDefaultWallet();
    } catch (e) {
      logger.e(e.toString());
    }
  }

  void destroy() {
    protonWallet.destroy();
  }

  Future<void> updateFiatCurrencyInUserSettingProvider(
      FiatCurrency fiatCurrency) async {
    if (userSettingProvider != null) {
      userSettingProvider!.updateFiatCurrency(fiatCurrency);
      ProtonExchangeRate exchangeRate =
          await ExchangeRateService.getExchangeRate(fiatCurrency);
      userSettingProvider!.updateExchangeRate(exchangeRate);
      await setCurrentTransactions();
    }
  }

  Future<void> updateCurrentWalletName(String newName) async {
    await protonWallet.updateCurrentWalletName(newName);
    notifyListeners();
  }

  Future<void> setWallet(WalletModel walletModel) async {
    await protonWallet.setWallet(walletModel);
    FiatCurrency fiatCurrency =
        await WalletManager.getDefaultAccountFiatCurrency(
            protonWallet.currentWallet);
    await updateFiatCurrencyInUserSettingProvider(fiatCurrency);
    await setCurrentTransactions();
    syncWallet();
    await Future.delayed(const Duration(
        milliseconds: 100)); // wait for wallet sync refresh button
    logger.i("going to notifyListeners in setWallet();");
    notifyListeners();
  }

  Future<void> setWalletAccount(
      WalletModel walletModel, AccountModel accountModel) async {
    await protonWallet.setWalletAccount(walletModel, accountModel);
    FiatCurrency fiatCurrency =
        WalletManager.getAccountFiatCurrency(protonWallet.currentAccount);
    await updateFiatCurrencyInUserSettingProvider(fiatCurrency);
    await setCurrentTransactions();
    syncWallet();
    await Future.delayed(const Duration(
        milliseconds: 100)); // wait for wallet sync refresh button
    logger.i("going to notifyListeners in setWalletAccount();");
    notifyListeners();
  }

  Future<void> syncWallet() async {
    List<AccountModel> accountsToCheckTransaction = [];
    WalletModel? walletModel = protonWallet.currentWallet;
    if (protonWallet.currentAccount != null) {
      // wallet account view
      accountsToCheckTransaction.add(protonWallet.currentAccount!);
    } else {
      // wallet view
      await protonWallet.getCurrentWalletAccounts();
    }
    accountsToCheckTransaction = protonWallet.currentAccounts;

    for (AccountModel accountModel in accountsToCheckTransaction) {
      try {
        Wallet? wallet = await WalletManager.loadWalletWithID(
            walletModel!.id!, accountModel.id!);
        if (wallet != null) {
          protonWallet.syncWallet(wallet, walletModel, accountModel);
        }
      } catch (e) {
        logger.e(e.toString());
      }
    }
    notifyListeners();
  }

  Future<void> insertOrUpdateWallet(WalletModel walletModel) async {
    await protonWallet.insertOrUpdateWallet(walletModel);
    notifyListeners();
  }

  Future<void> deleteWallet(WalletModel deletedWalletModel) async {
    await protonWallet.deleteWallet(deletedWalletModel);
    notifyListeners();
  }

  Future<void> insertOrUpdateWalletAccount(AccountModel newAccountModel) async {
    await protonWallet.insertOrUpdateWalletAccount(newAccountModel);
    notifyListeners();
  }

  Future<void> deleteWalletAccount(AccountModel deletedAccountModel) async {
    await protonWallet.deleteWalletAccount(deletedAccountModel);
    notifyListeners();
  }

  Future<void> setCurrentTransactions() async {
    await protonWallet.setCurrentTransactions();
    notifyListeners();
  }

  Future<void> setPassphrase(WalletModel walletModel, String passphrase) async {
    await protonWallet.setPassphraseWithCheck(walletModel, passphrase);
    notifyListeners();
  }

  void applyHistoryTransactionFilterAndKeyword(String filter, String keyword) {
    protonWallet.applyHistoryTransactionFilterAndKeyword(filter, keyword);
    notifyListeners();
  }

  Future<void> setIntegratedEmailIDs(AccountModel accountModel) async {
    protonWallet.setIntegratedEmailIDs(accountModel);
    notifyListeners();
  }

  Future<void> setDefaultWallet() async {
    await protonWallet.setDefaultWallet();
    FiatCurrency fiatCurrency =
        await WalletManager.getDefaultAccountFiatCurrency(
            protonWallet.currentWallet);
    await updateFiatCurrencyInUserSettingProvider(fiatCurrency);
    notifyListeners();
  }

  String? getDisplayName() {
    String? name;
    if (protonWallet.currentWallet != null) {
      if (protonWallet.currentAccounts.length > 1 &&
          protonWallet.currentAccount != null) {
        return "${protonWallet.currentWallet!.name} - ${protonWallet.currentAccount!.labelDecrypt}";
      } else {
        return protonWallet.currentWallet!.name;
      }
    }
    return name;
  }
}
