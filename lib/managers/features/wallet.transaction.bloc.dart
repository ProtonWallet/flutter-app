import 'dart:async';
import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proton_crypto/proton_crypto.dart' as proton_crypto;
import 'package:wallet/constants/address.key.dart';
import 'package:wallet/constants/app.config.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/history.transaction.dart';
import 'package:wallet/constants/transaction.detail.from.blockchain.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/helper/walletkey_helper.dart';
import 'package:wallet/managers/features/models/wallet.list.dart';
import 'package:wallet/managers/providers/address.keys.provider.dart';
import 'package:wallet/managers/providers/bdk.transaction.data.provider.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/providers/local.bitcoin.address.provider.dart';
import 'package:wallet/managers/providers/local.transaction.data.provider.dart';
import 'package:wallet/managers/providers/server.transaction.data.provider.dart';
import 'package:wallet/managers/providers/user.settings.data.provider.dart';
import 'package:wallet/managers/providers/wallet.data.provider.dart';
import 'package:wallet/managers/providers/wallet.keys.provider.dart';
import 'package:wallet/managers/services/exchange.rate.service.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/bitcoin.address.model.dart';
import 'package:wallet/models/exchangerate.model.dart';
import 'package:wallet/models/transaction.info.model.dart';
import 'package:wallet/models/transaction.model.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/rust/api/bdk_wallet/account.dart';
import 'package:wallet/rust/api/bdk_wallet/transaction_details.dart';
import 'package:wallet/rust/api/bdk_wallet/transaction_details_txop.dart';
import 'package:wallet/rust/common/address_info.dart';
import 'package:wallet/rust/common/transaction_time.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';

// Define the events
abstract class WalletTransactionEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class StartLoading extends WalletTransactionEvent {
  StartLoading();

  @override
  List<Object> get props => [];
}

class SyncWallet extends WalletTransactionEvent {
  SyncWallet();

  @override
  List<Object> get props => [];
}

class SelectWallet extends WalletTransactionEvent {
  final WalletMenuModel walletMenuModel;
  final bool triggerByDataProviderUpdate;

  SelectWallet(
    this.walletMenuModel, {
    // TODO(fix): change to a shorter name
    required this.triggerByDataProviderUpdate,
  });

  @override
  List<Object> get props => [walletMenuModel];
}

class SelectAccount extends WalletTransactionEvent {
  final WalletMenuModel walletMenuModel;
  final AccountMenuModel accountMenuModel;
  final bool triggerByDataProviderUpdate;

  SelectAccount(
    this.walletMenuModel,
    this.accountMenuModel, {
    required this.triggerByDataProviderUpdate,
  });

  @override
  List<Object> get props => [walletMenuModel, accountMenuModel];
}

// Define the state
class WalletTransactionState extends Equatable {
  ///
  /// The historyTransaction is build from
  /// 1. ServerTransactionDataProvider, this is used to add additional information, i.e. message to recipients, label of transaction, email name.. etc
  /// 2. LocalTransactionDataProvider, this is used to show sender side's info, how much to which recipient..etc, only used when bdk didn't synced for the transaction yet
  /// 3. BKDTransactionDataProvider, this is main transactionProvider, 1 and 2 are used when bdk not synced (bdk didn't know the transaction yet)
  final List<HistoryTransaction> historyTransaction;
  final List<BitcoinAddressDetail> bitcoinAddresses;
  final bool isSyncing;

  const WalletTransactionState({
    required this.historyTransaction,
    required this.bitcoinAddresses,
    required this.isSyncing,
  });

  @override
  List<Object?> get props => [
        isSyncing,
        historyTransaction,
        bitcoinAddresses,
      ];
}

extension WalletTransactionStateCopyWith on WalletTransactionState {
  WalletTransactionState copyWith({
    bool isSyncing = false,
    List<HistoryTransaction>? historyTransaction,
    List<BitcoinAddressDetail>? bitcoinAddresses,
  }) {
    return WalletTransactionState(
      isSyncing: isSyncing,
      bitcoinAddresses: bitcoinAddresses ?? this.bitcoinAddresses,
      historyTransaction: historyTransaction ?? this.historyTransaction,
    );
  }
}

/// Define the Bloc
class WalletTransactionBloc
    extends Bloc<WalletTransactionEvent, WalletTransactionState> {
  final UserManager userManager;
  final LocalTransactionDataProvider localTransactionDataProvider;
  final BDKTransactionDataProvider bdkTransactionDataProvider;
  final ServerTransactionDataProvider serverTransactionDataProvider;
  final AddressKeyProvider addressKeyProvider;
  final WalletKeysProvider walletKeysProvider;
  final LocalBitcoinAddressDataProvider localBitcoinAddressDataProvider;
  final WalletsDataProvider walletsDataProvider;
  final UserSettingsDataProvider userSettingsDataProvider;

  StreamSubscription? serverTransactionDataSubscription;
  StreamSubscription? localTransactionDataSubscription;
  StreamSubscription? bdkTransactionDataSubscription;
  StreamSubscription? walletsDataSubscription;
  StreamSubscription? fiatCurrencySettingSubscription;

  Map<String, int> accountID2lastSyncTime = {};

  // final BdkLibrary _lib = BdkLibrary(coinType: appConfig.coinType);

  WalletTransactionEvent? lastEvent;

  WalletTransactionBloc(
    this.userManager,
    this.localTransactionDataProvider,
    this.bdkTransactionDataProvider,
    this.serverTransactionDataProvider,
    this.addressKeyProvider,
    this.walletKeysProvider,
    this.localBitcoinAddressDataProvider,
    this.walletsDataProvider,
    this.userSettingsDataProvider,
  ) : super(const WalletTransactionState(
          isSyncing: false,
          historyTransaction: [],
          bitcoinAddresses: [],
        )) {
    /// currentWalletModel and currentAccountModel are used to identify if the process need to be continue or not
    /// for example, if user select Wallet A, then it will start generating transactions for wallet A
    /// if user change to Wallet B immediately, then we need to stop the process that generating transactions for wallet A
    /// we will compare the event.walletModel is equal to currentWalletModel or not
    WalletModel? currentWalletModel;
    AccountModel? currentAccountModel;

    walletsDataSubscription = walletsDataProvider
        .selectedWalletUpdateController.stream
        .listen((onData) async {
      final WalletData? walletData =
          await walletsDataProvider.getWalletByServerWalletID(
              walletsDataProvider.selectedServerWalletID);
      if (walletData != null) {
        final WalletMenuModel walletMenuModel =
            WalletMenuModel(walletData.wallet);
        walletMenuModel.accounts =
            walletData.accounts.map(AccountMenuModel.new).toList();
        if (walletsDataProvider.selectedServerWalletAccountID.isEmpty) {
          /// wallet view
          if (currentWalletModel?.walletID !=
                  walletsDataProvider.selectedServerWalletID ||
              currentAccountModel?.accountID !=
                  walletsDataProvider.selectedServerWalletAccountID) {
            add(SelectWallet(
              walletMenuModel,
              triggerByDataProviderUpdate: false, // need to sync wallet
            ));
          }
        } else {
          /// wallet account view
          if (currentWalletModel?.walletID !=
                  walletsDataProvider.selectedServerWalletID ||
              currentAccountModel?.accountID !=
                  walletsDataProvider.selectedServerWalletAccountID) {
            for (AccountMenuModel accountMenuModel
                in walletMenuModel.accounts) {
              if (accountMenuModel.accountModel.accountID ==
                  walletsDataProvider.selectedServerWalletAccountID) {
                add(SelectAccount(
                  walletMenuModel,
                  accountMenuModel,
                  triggerByDataProviderUpdate: false, // need to sync wallet
                ));
                break;
              }
            }
          }
        }
      } else {
        /// no wallets
        /// clear all
        add(StartLoading());
      }
    });
    fiatCurrencySettingSubscription = userSettingsDataProvider
        .fiatCurrencyUpdateController.stream
        .listen((_) {
      handleTransactionDataProviderUpdate();
    });

    bdkTransactionDataSubscription =
        bdkTransactionDataProvider.dataUpdateController.stream.listen((state) {
      handleTransactionDataProviderUpdate();
    });

    serverTransactionDataSubscription = serverTransactionDataProvider
        .dataUpdateController.stream
        .listen((onData) {
      handleTransactionDataProviderUpdate();

      if (onData.updatedData == UpdateType.inserted) {
        Future.delayed(const Duration(seconds: 10), () {
          /// wait 10 second so transaction can update first
          /// since bdk account will be locked when it's syncing
          syncWallet(forceSync: true);
        });
      }

      /// syncWallet so that balance can get update
    });

    localTransactionDataSubscription = localTransactionDataProvider
        .dataUpdateController.stream
        .listen((onData) {
      // handleTransactionDataProviderUpdate();
      // syncWallet(true);
    });
    on<StartLoading>((event, emit) async {
      emit(state.copyWith(historyTransaction: []));
    });

    on<SyncWallet>((event, emit) async {
      emit(state.copyWith(
        isSyncing: true,
        historyTransaction: state.historyTransaction,
        bitcoinAddresses: state.bitcoinAddresses,
      ));
    });

    on<SelectWallet>((event, emit) async {
      final int currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      for (AccountMenuModel accountMenuModel in event.walletMenuModel.accounts) {
        final int lastSyncTime =
            accountID2lastSyncTime[accountMenuModel.accountModel.accountID] ?? 0;
        final int timeDiffSeconds = currentTimestamp - lastSyncTime;
        if (timeDiffSeconds > reSyncTime) {
          accountID2lastSyncTime[accountMenuModel.accountModel.accountID] =
              currentTimestamp;
          bdkTransactionDataProvider.syncWallet(
            event.walletMenuModel.walletModel,
            accountMenuModel.accountModel,
            forceSync: false,
          );
        }
      }
      if (currentWalletModel?.walletID !=
              event.walletMenuModel.walletModel.walletID ||
          currentAccountModel != null) {
        emit(state.copyWith(
          historyTransaction: [],
          bitcoinAddresses: [],
          isSyncing: true,
        ));
      }
      currentWalletModel = event.walletMenuModel.walletModel;
      currentAccountModel = null;
      lastEvent = event;
      if (!event.triggerByDataProviderUpdate) {
        // syncWallet(forceSync: false);
      }

      List<BitcoinAddressDetail> bitcoinAddresses = [];
      final WalletModel walletModel = event.walletMenuModel.walletModel;
      final SecretKey? secretKey =
          await getSecretKey(event.walletMenuModel.walletModel);

      List<HistoryTransaction> newHistoryTransactions = [];

      bool isSyncing = false;
      for (AccountMenuModel accountMenuModel
          in event.walletMenuModel.accounts) {
        final List<HistoryTransaction> historyTransactionsInAccount =
            await getHistoryTransactions(
                walletModel, accountMenuModel, secretKey);

        newHistoryTransactions += historyTransactionsInAccount;
        isSyncing = isSyncing ||
            bdkTransactionDataProvider.isSyncing(
              walletModel,
              accountMenuModel.accountModel,
            );

        final LocalBitcoinAddressData localBitcoinAddressData =
            await localBitcoinAddressDataProvider.getDataByWalletAccount(
          walletModel,
          accountMenuModel.accountModel,
        );

        /// check every bitcoinAddress if it exists in transactions
        final Map<String, List<String>> bitcoinAddress2TXIDMap = {};
        for (HistoryTransaction historyTransaction
            in historyTransactionsInAccount) {
          for (String addr in historyTransaction.bitcoinAddresses) {
            if (!bitcoinAddress2TXIDMap.containsKey(addr)) {
              bitcoinAddress2TXIDMap[addr] = [];
            }
            bitcoinAddress2TXIDMap[addr]?.add(historyTransaction.txID);
          }
        }

        for (BitcoinAddressDetail bitcoinAddressDetail
            in localBitcoinAddressData.bitcoinAddresses) {
          bitcoinAddressDetail.txIDs = bitcoinAddress2TXIDMap[
                  bitcoinAddressDetail.bitcoinAddressModel.bitcoinAddress] ??
              [];
        }

        bitcoinAddresses += localBitcoinAddressData.bitcoinAddresses;
        if (currentAccountModel != null ||
            currentWalletModel!.walletID != walletModel.walletID) {
          /// skip process if user change to other wallet or wallet account
          return;
        }
      }
      newHistoryTransactions = sortHistoryTransaction(newHistoryTransactions);

      // TODO(fix): get filter and keyWord from home VM
      const String filter = "";
      const String keyWord = "";
      final List<HistoryTransaction> historyTransaction =
          applyHistoryTransactionFilterAndKeyword(
              filter, keyWord, newHistoryTransactions);
      if (currentAccountModel != null ||
          currentWalletModel!.walletID != walletModel.walletID) {
        /// skip process if user change to other wallet or wallet account
        return;
      }
      emit(state.copyWith(
        isSyncing: isSyncing,
        historyTransaction: historyTransaction,
        bitcoinAddresses: bitcoinAddresses,
      ));
    });

    on<SelectAccount>((event, emit) async {
      final int currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final int lastSyncTime =
          accountID2lastSyncTime[event.accountMenuModel.accountModel.accountID] ?? 0;
      final int timeDiffSeconds = currentTimestamp - lastSyncTime;

      if (timeDiffSeconds > reSyncTime) {
        accountID2lastSyncTime[event.accountMenuModel.accountModel.accountID] =
            currentTimestamp;
        bdkTransactionDataProvider.syncWallet(
          event.walletMenuModel.walletModel,
          event.accountMenuModel.accountModel,
          forceSync: false,
        );
      }
      if (currentWalletModel?.walletID !=
              event.walletMenuModel.walletModel.walletID ||
          currentAccountModel?.accountID !=
              event.accountMenuModel.accountModel.accountID) {
        emit(state.copyWith(
          historyTransaction: [],
          bitcoinAddresses: [],
          isSyncing: true,
        ));
      }
      currentWalletModel = event.walletMenuModel.walletModel;
      currentAccountModel = event.accountMenuModel.accountModel;
      lastEvent = event;
      if (!event.triggerByDataProviderUpdate) {
        // syncWallet(forceSync: false);
      }

      final WalletModel walletModel = event.walletMenuModel.walletModel;
      final SecretKey? secretKey =
          await getSecretKey(event.walletMenuModel.walletModel);

      List<HistoryTransaction> newHistoryTransactions = [];

      final List<HistoryTransaction> historyTransactionsInAccount =
          await getHistoryTransactions(
              walletModel, event.accountMenuModel, secretKey);
      newHistoryTransactions += historyTransactionsInAccount;

      newHistoryTransactions = sortHistoryTransaction(newHistoryTransactions);
      final bool isSyncing = bdkTransactionDataProvider.isSyncing(
          walletModel, event.accountMenuModel.accountModel);

      // TODO(fix): get filter and keyWord from home VM
      const String filter = "";
      const String keyWord = "";
      final List<HistoryTransaction> historyTransaction =
          applyHistoryTransactionFilterAndKeyword(
              filter, keyWord, newHistoryTransactions);

      final LocalBitcoinAddressData localBitcoinAddressData =
          await localBitcoinAddressDataProvider.getDataByWalletAccount(
        walletModel,
        event.accountMenuModel.accountModel,
      );

      /// check every bitcoinAddress if it exists in transactions
      final Map<String, List<String>> bitcoinAddress2TXIDMap = {};
      for (HistoryTransaction historyTransaction
          in historyTransactionsInAccount) {
        for (String addr in historyTransaction.bitcoinAddresses) {
          if (!bitcoinAddress2TXIDMap.containsKey(addr)) {
            bitcoinAddress2TXIDMap[addr] = [];
          }
          bitcoinAddress2TXIDMap[addr]?.add(historyTransaction.txID);
        }
      }

      for (BitcoinAddressDetail bitcoinAddressDetail
          in localBitcoinAddressData.bitcoinAddresses) {
        bitcoinAddressDetail.txIDs = bitcoinAddress2TXIDMap[
                bitcoinAddressDetail.bitcoinAddressModel.bitcoinAddress] ??
            [];
      }
      if (currentAccountModel != null) {
        if (currentAccountModel!.accountID !=
            event.accountMenuModel.accountModel.accountID) {
          /// skip process if user change to other wallet or wallet account
          return;
        }
      }
      emit(state.copyWith(
        isSyncing: isSyncing,
        historyTransaction: historyTransaction,
        bitcoinAddresses: localBitcoinAddressData.bitcoinAddresses,
      ));
    });
  }

  void handleTransactionDataProviderUpdate() {
    if (lastEvent != null) {
      if (lastEvent is SelectWallet) {
        final SelectWallet selectWallet = (lastEvent! as SelectWallet);
        add(SelectWallet(
          selectWallet.walletMenuModel,
          triggerByDataProviderUpdate: true,
        ));
      } else if (lastEvent is SelectAccount) {
        final SelectAccount selectAccount = (lastEvent! as SelectAccount);
        add(SelectAccount(
          selectAccount.walletMenuModel,
          selectAccount.accountMenuModel,
          triggerByDataProviderUpdate: true,
        ));
      }
    }
  }

  TransactionModel? findServerTransactionByTXID(
      List<TransactionModel> transactions, String txid) {
    for (TransactionModel transactionModel in transactions) {
      final String transactionTXID =
          utf8.decode(transactionModel.externalTransactionID);
      if (transactionTXID == txid) {
        return transactionModel;
      }
    }
    return null;
  }

  List<HistoryTransaction> sortHistoryTransaction(
      List<HistoryTransaction> historyTransactions) {
    historyTransactions.sort((a, b) {
      if (a.updateTimestamp == null && b.updateTimestamp == null) {
        return -1;
      }
      if (a.updateTimestamp == null) {
        return -1;
      }
      if (b.updateTimestamp == null) {
        return 1;
      }
      return a.updateTimestamp! > b.updateTimestamp! ? -1 : 1;
    });
    return historyTransactions;
  }

  List<HistoryTransaction> applyHistoryTransactionFilterAndKeyword(
      String filter,
      String keyword,
      List<HistoryTransaction> historyTransactions) {
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
    return newHistoryTransactions;
  }

  String tryDecryptWithAddressKeys(
      List<AddressKey> addressKeys, String encryptedString) {
    String result = "";
    for (AddressKey addressKey in addressKeys) {
      try {
        if (encryptedString.isNotEmpty) {
          result = addressKey.decrypt(encryptedString);
        }
      } catch (e) {
        // logger.e(e.toString());
      }
      if (result.isNotEmpty) {
        break;
      }
    }
    if (result.isEmpty) {
      for (AddressKey addressKey in addressKeys) {
        try {
          if (encryptedString.isNotEmpty) {
            result = addressKey.decryptBinary(encryptedString);
          }
        } catch (e) {
          // logger.e(e.toString());
        }
        if (result.isNotEmpty) {
          break;
        }
      }
    }
    if (result == "null") {
      result = "";
    }
    return result;
  }

  Future<List<HistoryTransaction>> getHistoryTransactions(
      WalletModel walletModel,
      AccountMenuModel accountMenuModel,
      SecretKey? secretKey) async {
    final List<AddressKey> addressKeys =
        await addressKeyProvider.getAddressKeys();
    final Map<String, HistoryTransaction> newHistoryTransactionsMap = {};
    final AccountModel accountModel = accountMenuModel.accountModel;
    final BDKTransactionData bdkTransactionData =
        await bdkTransactionDataProvider.getBDKTransactionDataByWalletAccount(
      walletModel,
      accountModel,
    );
    final LocalTransactionData localTransactionData =
        await localTransactionDataProvider
            .getLocalTransactionDataByWalletAccount(
      walletModel,
      accountModel,
    );
    final ServerTransactionData serverTransactionData =
        await serverTransactionDataProvider
            .getServerTransactionDataByWalletAccount(
      walletModel,
      accountModel,
    );

    // TODO(fix): replace it
    final FrbAccount? account = await WalletManager.loadWalletWithID(
      walletModel.walletID,
      accountMenuModel.accountModel.accountID,
    );

    final Map<String, FrbAddressInfo> selfBitcoinAddressInfo =
        await localBitcoinAddressDataProvider.getBitcoinAddress(
      walletModel,
      accountMenuModel.accountModel,
      account,
      maxAddressIndex: accountModel.lastUsedIndex + appConfig.stopGap,
    );

    final firstUserkey = await userManager.getFirstKey();
    final userPrivateKey = firstUserkey.privateKey;
    final userPassphrase = firstUserkey.passphrase;

    for (TransactionModel transactionModel
        in serverTransactionData.transactions) {
      String txid = "";
      try {
        txid = proton_crypto.decrypt(
            userPrivateKey, userPassphrase, transactionModel.transactionID);
      } catch (e, stacktrace) {
        logger.i(
          "getHistoryTransactions error: $e stacktrace: $stacktrace",
        );
      }
      if (txid.isEmpty) {
        for (AddressKey addressKey in addressKeys) {
          try {
            txid = addressKey.decrypt(transactionModel.transactionID);
          } catch (e, stacktrace) {
            logger.e(
              "getHistoryTransactions error: $e stacktrace: $stacktrace",
            );
          }
          if (txid.isNotEmpty) {
            break;
          }
        }
      }
      transactionModel.externalTransactionID = utf8.encode(txid);
    }

    /// checking transactions from bdk
    for (FrbTransactionDetails transactionDetail
        in bdkTransactionData.transactions) {
      final List<String> bitcoinAddressesInTransaction = [];
      final String txID = transactionDetail.txid;
      final List<FrbDetailledTxOutput> output = transactionDetail.outputs;
      final List<String> recipientBitcoinAddresses = [];
      for (FrbDetailledTxOutput txOut in output) {
        final String bitcoinAddress = txOut.address;
        bitcoinAddressesInTransaction.add(bitcoinAddress);
        BitcoinAddressModel? bitcoinAddressModel =
            await localBitcoinAddressDataProvider.findBitcoinAddressInAccount(
                bitcoinAddress, accountModel.accountID);

        if (bitcoinAddressModel != null) {
          bitcoinAddressModel.used = 1;
          await localBitcoinAddressDataProvider
              .insertOrUpdate(bitcoinAddressModel);
          localBitcoinAddressDataProvider
              .updateBitcoinAddress2TransactionDataMap(bitcoinAddress, txID);
        } else if (selfBitcoinAddressInfo.containsKey(bitcoinAddress)) {
          bitcoinAddressModel = BitcoinAddressModel(
            id: null,
            walletID: 0,
            // deprecated
            accountID: 0,
            // deprecated
            serverWalletID: walletModel.walletID,
            serverAccountID: accountModel.accountID,
            bitcoinAddress: bitcoinAddress,
            bitcoinAddressIndex: selfBitcoinAddressInfo[bitcoinAddress]!.index,
            inEmailIntegrationPool: 0,
            used: 1,
          );
          await localBitcoinAddressDataProvider
              .insertOrUpdate(bitcoinAddressModel);
          localBitcoinAddressDataProvider
              .updateBitcoinAddress2TransactionDataMap(bitcoinAddress, txID);
        } else {
          recipientBitcoinAddresses.add(bitcoinAddress);
        }
      }

      final TransactionModel? transactionModel = findServerTransactionByTXID(
          serverTransactionData.transactions, transactionDetail.txid);
      String userLabel = "";
      if (secretKey != null) {
        userLabel = transactionModel != null
            ? await WalletKeyHelper.decrypt(
                secretKey, utf8.decode(transactionModel.label))
            : "";
      }
      String toList = "";
      String sender = "";
      String body = "";
      if (transactionModel != null) {
        final String encryptedToList = transactionModel.tolist ?? "";
        final String encryptedSender = transactionModel.sender ?? "";
        final String encryptedBody = transactionModel.body ?? "";

        toList = tryDecryptWithAddressKeys(addressKeys, encryptedToList);
        sender = tryDecryptWithAddressKeys(addressKeys, encryptedSender);
        body = tryDecryptWithAddressKeys(addressKeys, encryptedBody);
      }

      int amountInSATS =
          (transactionDetail.received - transactionDetail.sent).toInt();
      if (amountInSATS < 0) {
        // bdk sent include fee, so need add back to make display send amount without fee
        amountInSATS += (transactionDetail.fees ?? BigInt.zero).toInt();
      }
      final String key = "$txID-${accountModel.accountID}";

      final ProtonExchangeRate exchangeRate =
          await getExchangeRateFromTransactionModel(transactionModel);

      final TransactionTime transactionTime = transactionDetail.time;
      int? time;
      int? lastSeenTime;
      transactionTime.when(
        confirmed: (confirmationTime) {
          logger.d('Confirmed transaction time: $confirmationTime');
          time = confirmationTime.toInt();
          lastSeenTime = confirmationTime.toInt();
        },
        unconfirmed: (lastSeen) {
          logger.d('Unconfirmed transaction last seen: $lastSeen');
          lastSeenTime = lastSeen.toInt();
        },
      );

      newHistoryTransactionsMap[key] = HistoryTransaction(
        txID: txID,
        createTimestamp: time,
        updateTimestamp: lastSeenTime,
        amountInSATS: amountInSATS,
        sender: sender.isNotEmpty ? sender : "Unknown",
        toList:
            toList.isNotEmpty ? toList : recipientBitcoinAddresses.join(", "),
        feeInSATS: (transactionDetail.fees ?? BigInt.zero).toInt(),
        label: userLabel,
        inProgress: time == null,
        //transactionDetail.confirmationTime == null,
        accountModel: accountModel,
        body: body.isNotEmpty ? body : null,
        exchangeRate: exchangeRate,
        bitcoinAddresses: bitcoinAddressesInTransaction,
      );
    }

    /// check server transactions with local transaction data
    /// since user will have server transactions after broadcast (server will create for sender, recipients if use email integration)
    /// these data is used only when bdk not finish synced after broadcast
    for (TransactionModel transactionModel
        in serverTransactionData.transactions) {
      String userLabel = "";
      if (secretKey != null) {
        userLabel = await WalletKeyHelper.decrypt(
            secretKey, utf8.decode(transactionModel.label));
      }
      final String txID = utf8.decode(transactionModel.externalTransactionID);
      final String key = "$txID-${accountModel.accountID}";
      if (txID.isEmpty) {
        continue;
      }
      if (newHistoryTransactionsMap.containsKey(key)) {
        // skip if we already has this info (i.e. bdk had synced for this record)
        continue;
      }
      String toList = "";
      String sender = "";
      String body = "";
      final String encryptedToList = transactionModel.tolist ?? "";
      final String encryptedSender = transactionModel.sender ?? "";
      final String encryptedBody = transactionModel.body ?? "";

      toList = tryDecryptWithAddressKeys(addressKeys, encryptedToList);
      sender = tryDecryptWithAddressKeys(addressKeys, encryptedSender);
      body = tryDecryptWithAddressKeys(addressKeys, encryptedBody);

      final List<TransactionInfoModel> transactionInfoModels =
          getLocalTransactionsByTXID(localTransactionData.transactions, txID);
      if (transactionInfoModels.isNotEmpty) {
        /// if we have transactionInfoModels found, it means it's sender side
        /// we will fill transaction info with local transaction data
        /// (recipients cannot have local transaction data since they didn't broadcast transaction)
        int amountInSATS = 0;
        int feeInSATS = 0;
        for (TransactionInfoModel transactionInfoModel
            in transactionInfoModels) {
          amountInSATS += transactionInfoModel.isSend == 1
              ? -transactionInfoModel.amountInSATS
              : transactionInfoModel.amountInSATS;
          feeInSATS = transactionInfoModel
              .feeInSATS; // all recipients have same fee since its same transaction
        }

        final ProtonExchangeRate exchangeRate =
            await getExchangeRateFromTransactionModel(transactionModel);

        newHistoryTransactionsMap[key] = HistoryTransaction(
          txID: txID,
          updateTimestamp: transactionInfoModels.first.transactionTime,
          amountInSATS: amountInSATS,
          sender: sender.isNotEmpty ? sender : "Unknown",
          toList: toList.isNotEmpty ? toList : "Unknown",
          feeInSATS: feeInSATS,
          label: userLabel,
          inProgress: true,
          accountModel: accountModel,
          body: body.isNotEmpty ? body : null,
          exchangeRate: exchangeRate,
          bitcoinAddresses: [],
        );
      } else {
        /// no transactionInfoModels found, means it's recipient side
        /// going to get transaction info from proton esplora server
        // TODO(fix): fix me since it take too long time
        try {
          TransactionDetailFromBlockChain? transactionDetailFromBlockChain;
          transactionDetailFromBlockChain =
              await WalletManager.getTransactionDetailsFromBlockStream(txID);
          try {
            if (transactionDetailFromBlockChain != null) {
              break;
            }
          } catch (e) {
            logger.e(e.toString());
          }
          if (transactionDetailFromBlockChain != null) {
            Recipient? me;
            final List<String> bitcoinAddressesInTransaction = [];
            for (Recipient recipient
                in transactionDetailFromBlockChain.recipients) {
              final String bitcoinAddress = recipient.bitcoinAddress;
              bitcoinAddressesInTransaction.add(bitcoinAddress);
              BitcoinAddressModel? bitcoinAddressModel =
                  await localBitcoinAddressDataProvider
                      .findBitcoinAddressInAccount(
                bitcoinAddress,
                accountModel.accountID,
              );
              if (bitcoinAddressModel != null) {
                bitcoinAddressModel.used = 1;
                await localBitcoinAddressDataProvider.insertOrUpdate(
                  bitcoinAddressModel,
                );
                me = recipient;
                localBitcoinAddressDataProvider
                    .updateBitcoinAddress2TransactionDataMap(
                  bitcoinAddressModel.bitcoinAddress,
                  txID,
                );
                break;
              } else if (selfBitcoinAddressInfo.containsKey(bitcoinAddress)) {
                bitcoinAddressModel = BitcoinAddressModel(
                  id: null,
                  walletID: 0,
                  // deprecated
                  accountID: 0,
                  // deprecated
                  serverWalletID: walletModel.walletID,
                  serverAccountID: accountModel.accountID,
                  bitcoinAddress: recipient.bitcoinAddress,
                  bitcoinAddressIndex:
                      selfBitcoinAddressInfo[bitcoinAddress]!.index,
                  inEmailIntegrationPool: 0,
                  used: 1,
                );
                await localBitcoinAddressDataProvider
                    .insertOrUpdate(bitcoinAddressModel);
                localBitcoinAddressDataProvider
                    .updateBitcoinAddress2TransactionDataMap(
                        bitcoinAddress, txID);
              }
            }
            if (me != null) {
              final ProtonExchangeRate exchangeRate =
                  await getExchangeRateFromTransactionModel(transactionModel);
              newHistoryTransactionsMap[key] = HistoryTransaction(
                txID: txID,
                updateTimestamp: transactionDetailFromBlockChain.timestamp,
                amountInSATS: me.amountInSATS,
                sender: sender.isNotEmpty ? sender : "Unknown",
                toList: toList.isNotEmpty ? toList : "Unknown",
                feeInSATS: transactionDetailFromBlockChain.feeInSATS,
                label: userLabel,
                inProgress: true,
                accountModel: accountModel,
                body: body.isNotEmpty ? body : null,
                exchangeRate: exchangeRate,
                bitcoinAddresses: bitcoinAddressesInTransaction,
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
    return newHistoryTransactionsMap.values.toList();
  }

  List<TransactionInfoModel> getLocalTransactionsByTXID(
      List<TransactionInfoModel> localTransactions, String txid) {
    return localTransactions
        .where((e) => utf8.decode(e.externalTransactionID) == txid)
        .toList();
  }

  Future<ProtonExchangeRate> getExchangeRateFromTransactionModel(
      TransactionModel? transactionModel) async {
    ProtonExchangeRate? exchangeRate;
    if (transactionModel != null &&
        transactionModel.exchangeRateID.isNotEmpty) {
      final ExchangeRateModel? exchangeRateModel = await DBHelper
          .exchangeRateDao!
          .findByServerID(transactionModel.exchangeRateID);
      if (exchangeRateModel != null) {
        final BitcoinUnit bitcoinUnit = BitcoinUnit.values.firstWhere(
            (v) =>
                v.name.toUpperCase() ==
                exchangeRateModel.bitcoinUnit.toUpperCase(),
            orElse: () => defaultBitcoinUnit);
        final FiatCurrency fiatCurrency = FiatCurrency.values.firstWhere(
            (v) =>
                v.name.toUpperCase() ==
                exchangeRateModel.fiatCurrency.toUpperCase(),
            orElse: () => defaultFiatCurrency);
        exchangeRate = ProtonExchangeRate(
          id: exchangeRateModel.serverID,
          bitcoinUnit: bitcoinUnit,
          fiatCurrency: fiatCurrency,
          exchangeRateTime: exchangeRateModel.exchangeRateTime,
          exchangeRate: BigInt.from(exchangeRateModel.exchangeRate),
          cents: BigInt.from(exchangeRateModel.cents),
        );
      }
    }

    // TODO(fix): replace with exchangeRateProvider
    exchangeRate ??= await ExchangeRateService.getExchangeRate(
        userSettingsDataProvider.exchangeRate.fiatCurrency,
        time: transactionModel?.transactionTime != null
            ? int.parse(transactionModel?.transactionTime ?? "0")
            : null);
    return exchangeRate;
  }

  /// Don't need this since bdk can extract outputs to get recipients' bitcoinAddresses
  // Future<void> updateBitcoinAddressUsed(
  //     String txID, AccountModel accountModel) async {
  //   TransactionDetailFromBlockChain? transactionDetailFromBlockChain;
  //   for (int i = 0; i < 5; i++) {
  //     transactionDetailFromBlockChain =
  //         await WalletManager.getTransactionDetailsFromBlockStream(txID);
  //     try {
  //       if (transactionDetailFromBlockChain != null) {
  //         break;
  //       }
  //     } catch (e) {
  //       logger.e(e.toString());
  //     }
  //     await Future.delayed(const Duration(seconds: 1));
  //   }
  //   if (transactionDetailFromBlockChain != null) {
  //     for (Recipient recipient in transactionDetailFromBlockChain.recipients) {
  //       BitcoinAddressModel? bitcoinAddressModel =
  //           await DBHelper.bitcoinAddressDao!.findBitcoinAddressInAccount(
  //               recipient.bitcoinAddress, accountModel.serverAccountID);
  //       if (bitcoinAddressModel != null) {
  //         bitcoinAddressModel.used = 1;
  //         await localBitcoinAddressDataProvider.insertOrUpdate(bitcoinAddressModel);
  //         localBitcoinAddressDataProvider.updateBitcoinAddress2TransactionDataMap(bitcoinAddressModel.bitcoinAddress, txID);
  //         break;
  //       }
  //     }
  //   }
  // }

  Future<SecretKey?> getSecretKey(WalletModel walletModel) async {
    /// get user key
    final firstUserKey = await userManager.getFirstKey();

    /// restore walletKey, it will be use to decrypt transaction txid from server, and transaction user label from server
    final walletKey = await walletKeysProvider.getWalletKey(
      walletModel.walletID,
    );
    SecretKey? secretKey;
    if (walletKey != null) {
      secretKey = WalletKeyHelper.decryptWalletKey(firstUserKey, walletKey);
    }
    return secretKey;
  }

  void init() {
    add(StartLoading());
  }

  void selectWallet(WalletMenuModel walletMenuModel) {
    add(SelectWallet(
      walletMenuModel,
      triggerByDataProviderUpdate: false,
    ));
  }

  void selectAccount(
    WalletMenuModel walletMenuModel,
    AccountMenuModel accountMenuModel,
  ) {
    // select wallet first. unblock account
    add(SelectAccount(
      walletMenuModel,
      accountMenuModel,
      triggerByDataProviderUpdate: false,
    ));
  }

  void syncWallet({required bool forceSync}) {
    if (lastEvent != null) {
      if (lastEvent is SelectWallet) {
        final WalletMenuModel walletMenuModel =
            (lastEvent! as SelectWallet).walletMenuModel;
        bool hadTriggerSync = false;
        for (AccountMenuModel accountMenuModel in walletMenuModel.accounts) {
          final bool isAccountSyncing = bdkTransactionDataProvider.isSyncing(
            walletMenuModel.walletModel,
            accountMenuModel.accountModel,
          );
          if (!isAccountSyncing) {
            bdkTransactionDataProvider.syncWallet(
              walletMenuModel.walletModel,
              accountMenuModel.accountModel,
              forceSync: forceSync,
            );
            hadTriggerSync = true;
          }
        }
        if (hadTriggerSync) {
          add(SyncWallet());
        }
      } else if (lastEvent is SelectAccount) {
        final WalletMenuModel walletMenuModel =
            (lastEvent! as SelectAccount).walletMenuModel;
        final AccountMenuModel accountMenuModel =
            (lastEvent! as SelectAccount).accountMenuModel;
        bool hadTriggerSync = false;
        final bool isAccountSyncing = bdkTransactionDataProvider.isSyncing(
          walletMenuModel.walletModel,
          accountMenuModel.accountModel,
        );
        if (!isAccountSyncing) {
          bdkTransactionDataProvider.syncWallet(
            walletMenuModel.walletModel,
            accountMenuModel.accountModel,
            forceSync: forceSync,
          );
          hadTriggerSync = true;
        }
        if (hadTriggerSync) {
          add(SyncWallet());
        }
      }
    }
  }

  @override
  Future<void> close() {
    serverTransactionDataSubscription?.cancel();
    localTransactionDataSubscription?.cancel();
    bdkTransactionDataSubscription?.cancel();
    walletsDataSubscription?.cancel();
    fiatCurrencySettingSubscription?.cancel();
    accountID2lastSyncTime.clear();
    return super.close();
  }
}
