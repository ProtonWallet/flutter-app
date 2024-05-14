import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:wallet/constants/address.key.dart';
import 'package:wallet/constants/transaction.detail.from.blockchain.dart';
import 'package:wallet/models/bitcoin.address.model.dart';
import 'package:wallet/models/transaction.info.model.dart';
import 'package:wallet/rust/api/proton_api.dart' as proton_api;
import 'package:wallet/constants/app.config.dart';
import 'package:wallet/constants/history.transaction.dart';
import 'package:wallet/helper/bdk/helper.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/helper/secure_storage_helper.dart';
import 'package:wallet/helper/wallet_manager.dart';
import 'package:wallet/helper/walletkey_helper.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/transaction.model.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/rust/bdk/types.dart';
import 'package:wallet/rust/proton_api/proton_address.dart';
import 'package:wallet/scenes/debug/bdk.test.dart';

class ProtonWallet {
  WalletModel? currentWallet;
  AccountModel? currentAccount; // show Wallet View when no account pick
  List<WalletModel> wallets = [];
  List<AccountModel> accounts = [];
  List<AccountModel> currentAccounts = [];
  List<HistoryTransaction> historyTransactions = [];
  List<HistoryTransaction> historyTransactionsAfterFilter = [];
  Map<String, bool> isWalletSyncing = {};
  final Map<int, bool> _hasPassphrase = {};
  final Map<int, List<String>> _accountID2IntegratedEmailIDs = {};
  int currentBalance = 0;
  final BdkLibrary _lib = BdkLibrary(coinType: appConfig.coinType);
  Blockchain? blockchain;
  String transactionFilter = "";

  Future<void> init() async {
    blockchain ??= await _lib.initializeBlockchain(false);
    wallets = (await DBHelper.walletDao!.findAll()).cast<WalletModel>();
    accounts = (await DBHelper.accountDao!.findAll()).cast<AccountModel>();
    for (AccountModel accountModel in accounts) {
      accountModel.balance = await WalletManager.getWalletAccountBalance(
          accountModel.walletID, accountModel.id ?? -1);
      await accountModel.decrypt();
    }
    // check if wallet has passphrase
    for (WalletModel walletModel in wallets) {
      await checkPassphrase(walletModel);
    }
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

  Future<void> syncWallet(Wallet? wallet, AccountModel? accountModel) async {
    wallet ??= await WalletManager.loadWalletWithID(
        currentWallet!.id!, currentAccount!.id!);
    if (hasPassphrase(currentWallet!) == false) {
      return;
    }
    try {
      if (accountModel != null) {
        if ((isWalletSyncing[accountModel.serverAccountID] ?? false) == false) {
          isWalletSyncing[accountModel.serverAccountID] = true;
          logger
              .i("set isWalletSyncing[${accountModel.serverAccountID}] = true");
          var walletBalance = await wallet.getBalance();
          accountModel.balance = (walletBalance.total).toDouble();
          logger.d(
              "start syncing ${accountModel.labelDecrypt} at ${DateTime.now()}, currentBalance = $currentBalance");
          await _lib.syncWallet(blockchain!, wallet);
          walletBalance = await wallet.getBalance();
          accountModel.balance = (walletBalance.total).toDouble();
          setBalance();
          logger.d(
              "end syncing ${accountModel.labelDecrypt} at ${DateTime.now()}, currentBalance = $currentBalance");
          await insertOrUpdateWalletAccount(accountModel);
          isWalletSyncing[accountModel.serverAccountID] = false;
        }
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
      String passphrase =
          await SecureStorageHelper.instance.get(walletModel.serverWalletID);
      _hasPassphrase[id] = passphrase.isNotEmpty;
    } else {
      _hasPassphrase[id] = true; // no need passphrase
    }
  }

  Future<void> setPassphrase(WalletModel walletModel, String passphrase) async {
    try {
      await SecureStorageHelper.instance
          .set(walletModel.serverWalletID, passphrase);
      await checkPassphrase(walletModel);
    } catch (e) {
      logger.e(e.toString());
    }
  }

  void destroy() {
    clearAll();
  }

  void clearCurrent() {
    currentWallet = null;
    currentAccount = null;
    currentBalance = 0;
    currentAccounts.clear();
    historyTransactionsAfterFilter.clear();
  }

  void clearAll() {
    clearCurrent();
    wallets.clear();
    accounts.clear();
    isWalletSyncing.clear();
    _hasPassphrase.clear();
    historyTransactions.clear();
    _accountID2IntegratedEmailIDs.clear();
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
        Wallet wallet = await WalletManager.loadWalletWithID(
            currentWallet!.id!, accountModel.id!);
        syncWallet(wallet, accountModel);
      }
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
          Wallet wallet = await WalletManager.loadWalletWithID(
              currentWallet!.id!, accountModel.id!);
          newBalance += (await wallet.getBalance()).total;
        }
      } else {
        Wallet wallet = await WalletManager.loadWalletWithID(
            currentWallet!.id!, currentAccount!.id!);
        newBalance += (await wallet.getBalance()).total;
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
      Wallet wallet = await WalletManager.loadWalletWithID(
          currentWallet!.id!, currentAccount!.id!);
      syncWallet(wallet, accountModel);
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

  Future<void> setDefaultWalletAccount() async {
    WalletModel? walletModel =
        await DBHelper.walletDao!.getFirstPriorityWallet();
    if (walletModel != null) {
      if (hasPassphrase(walletModel) == false) {
        clearCurrent();
        logger.i("no passphrase for default wallet");
      } else {
        List<AccountModel> accountModels =
            (await DBHelper.accountDao!.findAllByWalletID(walletModel.id!))
                .cast<AccountModel>();
        AccountModel? accountModel = accountModels.firstOrNull;
        if (accountModel != null) {
          await setWalletAccount(walletModel, accountModel);
        }
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
      await setDefaultWalletAccount();
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
    await getCurrentWalletAccounts();
  }

  Future<void> deleteWalletAccount(AccountModel deletedAccountModel) async {
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
    await getCurrentWalletAccounts();
    if (deletedAccountModel.serverAccountID ==
        (currentAccount?.serverAccountID ?? "")) {
      if (currentAccounts.isNotEmpty && currentWallet != null) {
        await setWalletAccount(currentWallet!, currentAccounts.first);
      } else {
        await setDefaultWalletAccount();
      }
    }
  }

  Future<void> setCurrentTransactions() async {
    bool bdkSynced = false;
    Wallet wallet;
    List<AccountModel> accountsToCheckTransaction = [];
    WalletModel? oldWalletModel = currentWallet;
    AccountModel? oldAccountModel = currentAccount;
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
      Map<String, HistoryTransaction> newHistoryTransactionsMap = {};

      List<ProtonAddress> addresses = await proton_api.getProtonAddress();
      addresses = addresses.where((element) => element.status == 1).toList();

      List<AddressKey> addressKeys = await WalletManager.getAddressKeys();

      wallet = await WalletManager.loadWalletWithID(
          oldWalletModel!.id!, accountModel.id!);

      // get transactions from bdk
      List<TransactionDetails> transactionHistoryFromBDK =
          await _lib.getAllTransactions(wallet);
      bdkSynced =
          bdkSynced | transactionHistoryFromBDK.isNotEmpty; // for wallet view
      SecretKey? secretKey =
          await WalletManager.getWalletKey(oldWalletModel.serverWalletID);

      for (TransactionDetails transactionDetail in transactionHistoryFromBDK) {
        String txID = transactionDetail.txid;
        TransactionModel? transactionModel = await DBHelper.transactionDao!
            .find(utf8.encode(txID), oldWalletModel.serverWalletID,
                accountModel.serverAccountID);
        String userLabel = transactionModel != null
            ? await WalletKeyHelper.decrypt(
                secretKey!, utf8.decode(transactionModel.label))
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
        String key = "$txID-${accountModel.serverAccountID}";
        newHistoryTransactionsMap[key] = HistoryTransaction(
          txID: txID,
          createTimestamp: transactionDetail.confirmationTime?.timestamp,
          updateTimestamp: transactionDetail.confirmationTime?.timestamp,
          amountInSATS: amountInSATS,
          sender: sender.isNotEmpty ? sender : txID,
          toList: toList.isNotEmpty ? toList : txID,
          feeInSATS: transactionDetail.fee ?? 0,
          label: userLabel,
          inProgress: transactionDetail.confirmationTime == null,
          accountModel: accountModel,
          body: body.isNotEmpty ? body : null,
        );
        updateBitcoinAddressUsed(
            txID); // update local bitcoin address to set used, TODO:: fix performance here
      }

      // get transactions from local db (transactions in progress, and not in synced bdk transactions)
      List<TransactionModel> transactionModels = await DBHelper.transactionDao!
          .findAllByServerAccountID(accountModel.serverAccountID);
      for (TransactionModel transactionModel in transactionModels) {
        String userLabel = await WalletKeyHelper.decrypt(
            secretKey!, utf8.decode(transactionModel.label));

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
        TransactionInfoModel? transactionInfoModel;
        try {
          transactionInfoModel = await DBHelper.transactionInfoDao!.find(
              utf8.encode(txID),
              oldWalletModel.serverWalletID,
              accountModel.serverAccountID,
              WalletManager.getBitcoinAddressFromWalletTransaction(toList));
        } catch (e) {
          logger.e(e.toString());
        }
        if (transactionInfoModel != null) {
          // get transaction info locally, for sender
          newHistoryTransactionsMap[key] = HistoryTransaction(
            txID: txID,
            amountInSATS: transactionInfoModel.isSend == 1
                ? -transactionInfoModel.amountInSATS -
                    transactionInfoModel.feeInSATS
                : transactionInfoModel.amountInSATS,
            sender: sender.isNotEmpty ? sender : txID,
            toList: toList.isNotEmpty ? toList : txID,
            feeInSATS: transactionInfoModel.feeInSATS,
            label: userLabel,
            inProgress: true,
            accountModel: accountModel,
            body: body.isNotEmpty ? body : null,
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
                    .findByBitcoinAddress(recipient.bitcoinAddress);
                if (bitcoinAddressModel != null) {
                  bitcoinAddressModel.used = 1;
                  await DBHelper.bitcoinAddressDao!.update(bitcoinAddressModel);
                  me = recipient;
                  break;
                }
              }
              if (me != null) {
                newHistoryTransactionsMap[key] = HistoryTransaction(
                  txID: txID,
                  amountInSATS: me.amountInSATS,
                  sender: sender.isNotEmpty ? sender : txID,
                  toList: toList.isNotEmpty ? toList : txID,
                  feeInSATS: transactionDetailFromBlockChain.feeInSATS,
                  label: userLabel,
                  inProgress: true,
                  accountModel: accountModel,
                  body: body.isNotEmpty ? body : null,
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

  Future<void> updateBitcoinAddressUsed(String txID) async {
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
        BitcoinAddressModel? bitcoinAddressModel = await DBHelper
            .bitcoinAddressDao!
            .findByBitcoinAddress(recipient.bitcoinAddress);
        if (bitcoinAddressModel != null) {
          bitcoinAddressModel.used = 1;
          await DBHelper.bitcoinAddressDao!.update(bitcoinAddressModel);
          break;
        }
      }
    }
  }
}

class ProtonWalletProvider with ChangeNotifier {
  final ProtonWallet protonWallet = ProtonWallet();

  Future<void> init() async {
    try {
      await protonWallet.init();
    } catch (e) {
      logger.e(e.toString());
    }
  }

  void destroy() {
    protonWallet.destroy();
  }

  Future<void> updateCurrentWalletName(String newName) async {
    await protonWallet.updateCurrentWalletName(newName);
    notifyListeners();
  }

  Future<void> setWallet(WalletModel walletModel) async {
    await protonWallet.setWallet(walletModel);
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
    if (walletModel != null && protonWallet.currentAccount != null) {
      // wallet account view
      accountsToCheckTransaction.add(protonWallet.currentAccount!);
    } else if (walletModel != null) {
      // wallet view
      await protonWallet.getCurrentWalletAccounts();
      accountsToCheckTransaction = protonWallet.currentAccounts;
    }
    for (AccountModel accountModel in accountsToCheckTransaction) {
      Wallet wallet = await WalletManager.loadWalletWithID(
          walletModel!.id!, accountModel.id!);
      protonWallet.syncWallet(wallet, accountModel);
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
    await protonWallet.setPassphrase(walletModel, passphrase);
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

  Future<void> setDefaultWalletAccount() async {
    await protonWallet.setDefaultWalletAccount();
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
