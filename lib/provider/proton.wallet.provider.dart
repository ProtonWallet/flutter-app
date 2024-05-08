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
  AccountModel? currentAccount;
  List<WalletModel> wallets = [];
  List<AccountModel> accounts = [];
  List<AccountModel> currentAccounts = [];
  List<HistoryTransaction> historyTransactions = [];
  List<HistoryTransaction> historyTransactionsAfterFilter = [];
  Map<String, bool> isWalletSyncing = {};
  final Map<int, bool> _hasPassphrase = {};
  final Map<int, List<String>> _accountID2IntegratedEmailIDs = {};
  Wallet? wallet;
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
    return false;
  }

  Future<void> syncWallet() async {
    AccountModel? accountModel = currentAccount;
    if (wallet != null && accountModel != null) {
      if ((isWalletSyncing[accountModel.serverAccountID] ?? false) == false) {
        isWalletSyncing[accountModel.serverAccountID] = true;
        var walletBalance = await wallet!.getBalance();
        accountModel.balance = (walletBalance.total).toDouble();
        logger.d(
            "start syncing ${accountModel.labelDecrypt} at ${DateTime.now()}, currentBalance = $currentBalance");
        await _lib.syncWallet(blockchain!, wallet!);
        walletBalance = await wallet!.getBalance();
        accountModel.balance = (walletBalance.total).toDouble();
        if (accountModel.serverAccountID == accountModel.serverAccountID) {
          currentBalance = walletBalance.total;
        }
        logger.d(
            "end syncing ${accountModel.labelDecrypt} at ${DateTime.now()}, currentBalance = $currentBalance");
        await insertOrUpdateWalletAccount(accountModel);
        isWalletSyncing[accountModel.serverAccountID] = false;
        await setCurrentTransactions(accountModel);
      }
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
    await SecureStorageHelper.instance
        .set(walletModel.serverWalletID, passphrase);
    await checkPassphrase(walletModel);
  }

  void destroy() {
    clearAll();
  }

  void clearCurrent() {
    currentWallet = null;
    currentAccount = null;
    wallet = null;
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

  Future<void> setWalletAccount(
      WalletModel walletModel, AccountModel accountModel) async {
    historyTransactions.clear();

    currentWallet = walletModel;
    currentAccount = accountModel;
    await getCurrentWalletAccounts();
    wallet = await WalletManager.loadWalletWithID(
        currentWallet!.id!, currentAccount!.id!);
    currentBalance = 0;
    if (wallet != null) {
      currentBalance = (await wallet!.getBalance()).total;
    }
    await setCurrentTransactions(accountModel);
    syncWallet();
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
    if (currentAccount != null) {
      await setCurrentTransactions(currentAccount!);
    }
  }

  Future<void> setCurrentTransactions(AccountModel accountModel) async {
    bool bdkSynced = false;
    if (accountModel.serverAccountID ==
        (currentAccount?.serverAccountID ?? "")) {
      Map<String, HistoryTransaction> newHistoryTransactionsMap = {};

      List<ProtonAddress> addresses = await proton_api.getProtonAddress();
      addresses = addresses.where((element) => element.status == 1).toList();

      List<AddressKey> addressKeys = await WalletManager.getAddressKeys();

      // get transactions from bdk
      if (wallet != null) {
        List<TransactionDetails> transactionHistoryFromBDK =
            await _lib.getAllTransactions(wallet!);
        bdkSynced = transactionHistoryFromBDK.isNotEmpty;
        SecretKey? secretKey =
            await WalletManager.getWalletKey(currentWallet!.serverWalletID);

        for (TransactionDetails transactionDetail
            in transactionHistoryFromBDK) {
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
                  toList = addressKey.decrypt(encryptedToList);
                }
              } catch (e) {
                logger.e(e.toString());
              }
              try {
                if (encryptedSender.isNotEmpty) {
                  sender = addressKey.decrypt(encryptedSender);
                }
              } catch (e) {
                logger.e(e.toString());
              }
              if (sender.isNotEmpty || toList.isNotEmpty) {
                break;
              }
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
          int amountInSATS =
              transactionDetail.received - transactionDetail.sent;
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

        // get transactions from local db (transactions in progress, and not in synced bdk transactions)
        List<TransactionModel> transactionModels = await DBHelper
            .transactionDao!
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
                toList = addressKey.decrypt(encryptedToList);
              }
            } catch (e) {
              logger.e(e.toString());
            }
            try {
              if (encryptedSender.isNotEmpty) {
                sender = addressKey.decrypt(encryptedSender);
              }
            } catch (e) {
              logger.e(e.toString());
            }
            if (sender.isNotEmpty || toList.isNotEmpty) {
              break;
            }
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
          TransactionInfoModel? transactionInfoModel;
          try {
            transactionInfoModel = await DBHelper.transactionInfoDao!
                .findByExternalTransactionID(utf8.encode(txID));
          } catch (e) {
            logger.e(e.toString());
          }
          if (transactionInfoModel != null) {
            // get transaction info locally, for sender
            newHistoryTransactionsMap[txID] = HistoryTransaction(
                txID: txID,
                amountInSATS: transactionInfoModel.isSend == 1
                    ? -transactionInfoModel.amountInSATS -
                        transactionInfoModel.feeInSATS
                    : transactionInfoModel.amountInSATS,
                sender: sender.isNotEmpty ? sender : txID,
                toList: toList.isNotEmpty ? toList : txID,
                feeInSATS: transactionInfoModel.feeInSATS,
                label: userLabel,
                inProgress: true);
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
                    me = recipient;
                    break;
                  }
                }
                if (me != null) {
                  newHistoryTransactionsMap[txID] = HistoryTransaction(
                      txID: txID,
                      amountInSATS: me.amountInSATS,
                      sender: sender.isNotEmpty ? sender : txID,
                      toList: toList.isNotEmpty ? toList : txID,
                      feeInSATS: transactionDetailFromBlockChain.feeInSATS,
                      label: userLabel,
                      inProgress: true);
                } else {
                  logger.i("Cannot find this tx, $txID");
                }
              }
            } catch (e) {
              logger.e(e.toString());
            }
          }
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
      if (bdkSynced) {
        historyTransactions = newHistoryTransactions;
      } else {
        historyTransactions.clear();
      }
    }
    applyHistoryTransactionFilterAndKeyword(transactionFilter, "");
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
}

class ProtonWalletProvider with ChangeNotifier {
  final ProtonWallet protonWallet = ProtonWallet();

  Future<void> init() async {
    await protonWallet.init();
  }

  void destroy() {
    protonWallet.destroy();
  }

  Future<void> updateCurrentWalletName(String newName) async {
    await protonWallet.updateCurrentWalletName(newName);
    notifyListeners();
  }

  Future<void> setWalletAccount(
      WalletModel walletModel, AccountModel accountModel) async {
    await protonWallet.setWalletAccount(walletModel, accountModel);
    await setCurrentTransactions(accountModel);
    syncWallet();
    notifyListeners();
  }

  Future<void> syncWallet() async {
    await protonWallet.syncWallet();
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

  Future<void> setCurrentTransactions(AccountModel accountModel) async {
    await protonWallet.setCurrentTransactions(accountModel);
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
}
