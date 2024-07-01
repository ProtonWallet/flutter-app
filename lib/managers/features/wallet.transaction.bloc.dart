import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:wallet/constants/address.key.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/history.transaction.dart';
import 'package:wallet/constants/transaction.detail.from.blockchain.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/helper/user.settings.provider.dart';
import 'package:wallet/helper/walletkey_helper.dart';
import 'package:wallet/managers/features/models/wallet.list.dart';
import 'package:wallet/managers/providers/address.keys.provider.dart';
import 'package:wallet/managers/providers/bdk.transaction.data.provider.dart';
import 'package:wallet/managers/providers/local.bitcoin.address.provider.dart';
import 'package:wallet/managers/providers/local.transaction.data.provider.dart';
import 'package:wallet/managers/providers/server.transaction.data.provider.dart';
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
import 'package:proton_crypto/proton_crypto.dart' as proton_crypto;
import 'package:wallet/rust/api/bdk_wallet/account.dart';
import 'package:wallet/rust/api/bdk_wallet/transaction_details.dart';
import 'package:wallet/rust/api/bdk_wallet/transaction_details_txop.dart';
import 'package:wallet/rust/common/address_info.dart';
import 'package:wallet/rust/common/transaction_time.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/scenes/core/coordinator.dart';

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
    this.walletMenuModel,
    this.triggerByDataProviderUpdate,
  );

  @override
  List<Object> get props => [walletMenuModel];
}

class SelectAccount extends WalletTransactionEvent {
  final WalletMenuModel walletMenuModel;
  final AccountMenuModel accountMenuModel;
  final bool triggerByDataProviderUpdate;

  SelectAccount(
    this.walletMenuModel,
    this.accountMenuModel,
    this.triggerByDataProviderUpdate,
  );

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
  final List<BitcoinAddressModel> bitcoinAddresses;
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
    List<BitcoinAddressModel>? bitcoinAddresses,
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

  StreamSubscription? serverTransactionDataSubscription;
  StreamSubscription? localTransactionDataSubscription;
  StreamSubscription? bdkTransactionDataSubscription;
  StreamSubscription? walletsDataSubscription;

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

    walletsDataSubscription =
        walletsDataProvider.dataUpdateController.stream.listen((onData) {
      add(StartLoading());
    });

    bdkTransactionDataSubscription =
        bdkTransactionDataProvider.stream.listen((state) {
      //TODO:: improve me. only update the balance
      if (state is BDKDataUpdated) {
        handleTransactionDataProviderUpdate();
      }
    });

    serverTransactionDataSubscription = serverTransactionDataProvider
        .dataUpdateController.stream
        .listen((onData) {
      handleTransactionDataProviderUpdate();
      syncWallet(true);

      /// syncWallet so that balance can get update
    });

    localTransactionDataSubscription = localTransactionDataProvider
        .dataUpdateController.stream
        .listen((onData) {
      handleTransactionDataProviderUpdate();
      syncWallet(true);
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
      logger.i("WalletTransactionBloc selectWallet() start");
      if (currentWalletModel?.serverWalletID !=
              event.walletMenuModel.walletModel.serverWalletID ||
          currentAccountModel != null) {
        emit(state.copyWith(
          isSyncing: false,
          historyTransaction: [],
          bitcoinAddresses: [],
        ));
      }
      currentWalletModel = event.walletMenuModel.walletModel;
      currentAccountModel = null;
      lastEvent = event;
      if (event.triggerByDataProviderUpdate == false) {
        syncWallet();
      }

      List<BitcoinAddressModel> bitcoinAddresses = [];
      WalletModel walletModel = event.walletMenuModel.walletModel;
      SecretKey? secretKey =
          await getSecretKey(event.walletMenuModel.walletModel);

      List<HistoryTransaction> newHistoryTransactions = [];

      bool isSyncing = false;
      for (AccountMenuModel accountMenuModel
          in event.walletMenuModel.accounts) {
        List<HistoryTransaction> historyTransactionsInAccount =
            await getHistoryTransactions(
                walletModel, accountMenuModel, secretKey);

        newHistoryTransactions += historyTransactionsInAccount;
        isSyncing = isSyncing ||
            bdkTransactionDataProvider.isSyncing(
              walletModel,
              accountMenuModel.accountModel,
            );

        LocalBitcoinAddressData localBitcoinAddressData =
            await localBitcoinAddressDataProvider.getDataByWalletAccount(
          walletModel,
          accountMenuModel.accountModel,
        );
        bitcoinAddresses += localBitcoinAddressData.bitcoinAddresses;
        if (currentAccountModel != null ||
            currentWalletModel!.serverWalletID != walletModel.serverWalletID) {
          /// skip process if user change to other wallet or wallet account
          return;
        }
      }
      newHistoryTransactions = sortHistoryTransaction(newHistoryTransactions);

      /// TODO:: get filter and keyWord from home VM
      String filter = "";
      String keyWord = "";
      List<HistoryTransaction> historyTransaction =
          applyHistoryTransactionFilterAndKeyword(
              filter, keyWord, newHistoryTransactions);
      if (currentAccountModel != null ||
          currentWalletModel!.serverWalletID != walletModel.serverWalletID) {
        /// skip process if user change to other wallet or wallet account
        return;
      }
      emit(state.copyWith(
        isSyncing: isSyncing,
        historyTransaction: historyTransaction,
        bitcoinAddresses: bitcoinAddresses,
      ));

      logger.i("WalletTransactionBloc selectWallet() end");
    });

    on<SelectAccount>((event, emit) async {
      logger.i("WalletTransactionBloc SelectAccount() start");
      if (currentWalletModel?.serverWalletID !=
              event.walletMenuModel.walletModel.serverWalletID ||
          currentAccountModel?.serverAccountID !=
              event.accountMenuModel.accountModel.serverAccountID) {
        emit(state.copyWith(
          isSyncing: false,
          historyTransaction: [],
          bitcoinAddresses: [],
        ));
      }
      currentWalletModel = event.walletMenuModel.walletModel;
      currentAccountModel = event.accountMenuModel.accountModel;
      lastEvent = event;
      if (event.triggerByDataProviderUpdate == false) {
        syncWallet();
      }

      logger.i("WalletTransactionBloc SelectAccount() 1");

      WalletModel walletModel = event.walletMenuModel.walletModel;
      SecretKey? secretKey =
          await getSecretKey(event.walletMenuModel.walletModel);
      logger.i("WalletTransactionBloc SelectAccount() 2");

      List<HistoryTransaction> newHistoryTransactions = [];

      List<HistoryTransaction> historyTransactionsInAccount =
          await getHistoryTransactions(
              walletModel, event.accountMenuModel, secretKey);
      newHistoryTransactions += historyTransactionsInAccount;
      logger.i("WalletTransactionBloc SelectAccount() 3");

      newHistoryTransactions = sortHistoryTransaction(newHistoryTransactions);
      bool isSyncing = bdkTransactionDataProvider.isSyncing(
          walletModel, event.accountMenuModel.accountModel);

      /// TODO:: get filter and keyWord from home VM
      String filter = "";
      String keyWord = "";
      List<HistoryTransaction> historyTransaction =
          applyHistoryTransactionFilterAndKeyword(
              filter, keyWord, newHistoryTransactions);
      logger.i("WalletTransactionBloc SelectAccount() 4");

      LocalBitcoinAddressData localBitcoinAddressData =
          await localBitcoinAddressDataProvider.getDataByWalletAccount(
        walletModel,
        event.accountMenuModel.accountModel,
      );
      logger.i("WalletTransactionBloc SelectAccount() 6");
      if (currentAccountModel!.serverAccountID !=
          event.accountMenuModel.accountModel.serverAccountID) {
        /// skip process if user change to other wallet or wallet account
        return;
      }
      emit(state.copyWith(
        isSyncing: isSyncing,
        historyTransaction: historyTransaction,
        bitcoinAddresses: localBitcoinAddressData.bitcoinAddresses,
      ));
      logger.i("WalletTransactionBloc SelectAccount() end");
    });
  }

  void handleTransactionDataProviderUpdate() {
    if (lastEvent != null) {
      if (lastEvent is SelectWallet) {
        SelectWallet selectWallet = (lastEvent as SelectWallet);
        add(SelectWallet(
          selectWallet.walletMenuModel,
          true,
        ));
      } else if (lastEvent is SelectAccount) {
        SelectAccount selectAccount = (lastEvent as SelectAccount);
        add(SelectAccount(
          selectAccount.walletMenuModel,
          selectAccount.accountMenuModel,
          true,
        ));
      }
    }
  }

  TransactionModel? findServerTransactionByTXID(
      List<TransactionModel> transactions, String txid) {
    for (TransactionModel transactionModel in transactions) {
      String transactionTXID =
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
    List<AddressKey> addressKeys = await addressKeyProvider.getAddressKeys();
    Map<String, HistoryTransaction> newHistoryTransactionsMap = {};
    AccountModel accountModel = accountMenuModel.accountModel;
    BDKTransactionData bdkTransactionData =
        await bdkTransactionDataProvider.getBDKTransactionDataByWalletAccount(
      walletModel,
      accountModel,
    );
    LocalTransactionData localTransactionData =
        await localTransactionDataProvider
            .getLocalTransactionDataByWalletAccount(
      walletModel,
      accountModel,
    );
    ServerTransactionData serverTransactionData =
        await serverTransactionDataProvider
            .getServerTransactionDataByWalletAccount(
      walletModel,
      accountModel,
    );

    /// TODO:: replace it
    FrbAccount? account = await WalletManager.loadWalletWithID(
        walletModel.id!, accountMenuModel.accountModel.id!);

    Map<String, FrbAddressInfo> selfBitcoinAddressInfo =
        await localBitcoinAddressDataProvider.getBitcoinAddress(
            walletModel, accountMenuModel.accountModel, account);

    var firstUserkey = await userManager.getFirstKey();
    var userPrivateKey = firstUserkey.privateKey;
    var userPassphrase = firstUserkey.passphrase;

    for (TransactionModel transactionModel
        in serverTransactionData.transactions) {
      String txid = proton_crypto.decrypt(
          userPrivateKey, userPassphrase, transactionModel.transactionID);
      if (txid.isEmpty) {
        for (AddressKey addressKey in addressKeys) {
          try {
            txid = addressKey.decrypt(transactionModel.transactionID);
          } catch (e) {
            // logger.e(e.toString());
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
      String txID = transactionDetail.txid;
      List<FrbDetailledTxOutput> output = transactionDetail.outputs;
      List<String> recipientBitcoinAddresses = [];
      for (FrbDetailledTxOutput txOut in output) {
        String bitcoinAddress = txOut.address;

        BitcoinAddressModel? bitcoinAddressModel =
            await localBitcoinAddressDataProvider.findBitcoinAddressInAccount(
                bitcoinAddress, accountModel.serverAccountID);

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
            serverWalletID: walletModel.serverWalletID,
            serverAccountID: accountModel.serverAccountID,
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

      TransactionModel? transactionModel = findServerTransactionByTXID(
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
        String encryptedToList = transactionModel.tolist ?? "";
        String encryptedSender = transactionModel.sender ?? "";
        String encryptedBody = transactionModel.body ?? "";

        toList = tryDecryptWithAddressKeys(addressKeys, encryptedToList);
        sender = tryDecryptWithAddressKeys(addressKeys, encryptedSender);
        body = tryDecryptWithAddressKeys(addressKeys, encryptedBody);
      }

      int amountInSATS = transactionDetail.received - transactionDetail.sent;
      if (amountInSATS < 0) {
        // bdk sent include fee, so need add back to make display send amount without fee
        amountInSATS += transactionDetail.fees ?? 0;
      }
      String key = "$txID-${accountModel.serverAccountID}";

      ProtonExchangeRate exchangeRate =
          await getExchangeRateFromTransactionModel(transactionModel);

      TransactionTime transactionTime = transactionDetail.time;
      int? time;
      transactionTime.when(
        confirmed: (confirmationTime) {
          logger.d('Confirmed transaction time: $confirmationTime');
          time = confirmationTime;
        },
        unconfirmed: (lastSeen) {
          logger.d('Unconfirmed transaction last seen: $lastSeen');
          // needs to show in progress if it's not confirmed
          // time = lastSeen;
        },
      );

      newHistoryTransactionsMap[key] = HistoryTransaction(
        txID: txID,
        createTimestamp: time,
        updateTimestamp: time,
        amountInSATS: amountInSATS,
        sender: sender.isNotEmpty ? sender : "Unknown",
        toList:
            toList.isNotEmpty ? toList : recipientBitcoinAddresses.join(", "),
        feeInSATS: transactionDetail.fees ?? 0,
        label: userLabel,
        inProgress: time == null,
        //transactionDetail.confirmationTime == null,
        accountModel: accountModel,
        body: body.isNotEmpty ? body : null,
        exchangeRate: exchangeRate,
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
      String txID = utf8.decode(transactionModel.externalTransactionID);
      String key = "$txID-${accountModel.serverAccountID}";
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
      String encryptedToList = transactionModel.tolist ?? "";
      String encryptedSender = transactionModel.sender ?? "";
      String encryptedBody = transactionModel.body ?? "";

      toList = tryDecryptWithAddressKeys(addressKeys, encryptedToList);
      sender = tryDecryptWithAddressKeys(addressKeys, encryptedSender);
      body = tryDecryptWithAddressKeys(addressKeys, encryptedBody);

      List<TransactionInfoModel> transactionInfoModels =
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
        /// no transactionInfoModels found, means it's recipient side
        /// going to get transaction info from proton esplora server
        try {
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
            Recipient? me;
            for (Recipient recipient
                in transactionDetailFromBlockChain.recipients) {
              String bitcoinAddress = recipient.bitcoinAddress;
              BitcoinAddressModel? bitcoinAddressModel =
                  await localBitcoinAddressDataProvider
                      .findBitcoinAddressInAccount(
                bitcoinAddress,
                accountModel.serverAccountID,
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
                  serverWalletID: walletModel.serverWalletID,
                  serverAccountID: accountModel.serverAccountID,
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

    /// TODO:: replace with exchangeRateProvider
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
    var firstUserKey = await userManager.getFirstKey();
    var userPrivateKey = firstUserKey.privateKey;
    var userPassphrase = firstUserKey.passphrase;

    /// restore walletKey, it will be use to decrypt transaction txid from server, and transaction user label from server
    var walletKey = await walletKeysProvider.getWalletKey(
      walletModel.serverWalletID,
    );
    Uint8List? entropy;
    SecretKey? secretKey;
    if (walletKey != null) {
      var pgpEncryptedWalletKey = walletKey.walletKey;

      /// decrypt walletKey
      entropy = proton_crypto.decryptBinaryPGP(
        userPrivateKey,
        userPassphrase,
        pgpEncryptedWalletKey,
      );
      secretKey = WalletKeyHelper.restoreSecretKeyFromEntropy(entropy);
    }
    return secretKey;
  }

  void init() {
    add(StartLoading());
  }

  void selectWallet(WalletMenuModel walletMenuModel) {
    add(SelectWallet(
      walletMenuModel,
      false,
    ));
    for (AccountMenuModel accountMenuModel in walletMenuModel.accounts) {
      bdkTransactionDataProvider.syncWallet(
          walletMenuModel.walletModel, accountMenuModel.accountModel);
    }
  }

  void selectAccount(
    WalletMenuModel walletMenuModel,
    AccountMenuModel accountMenuModel,
  ) {
    // select wallet first. unblock account
    add(SelectAccount(
      walletMenuModel,
      accountMenuModel,
      false,
    ));
    bdkTransactionDataProvider.syncWallet(
      walletMenuModel.walletModel,
      accountMenuModel.accountModel,
    );
  }

  void syncWallet([bool forceSync = false]) {
    if (lastEvent != null) {
      if (lastEvent is SelectWallet) {
        WalletMenuModel walletMenuModel =
            (lastEvent as SelectWallet).walletMenuModel;
        for (AccountMenuModel accountMenuModel in walletMenuModel.accounts) {
          bdkTransactionDataProvider.syncWallet(
            walletMenuModel.walletModel,
            accountMenuModel.accountModel,
            forceSync,
          );
        }
        add(SyncWallet());
      } else if (lastEvent is SelectAccount) {
        WalletMenuModel walletMenuModel =
            (lastEvent as SelectAccount).walletMenuModel;
        AccountMenuModel accountMenuModel =
            (lastEvent as SelectAccount).accountMenuModel;
        bdkTransactionDataProvider.syncWallet(
          walletMenuModel.walletModel,
          accountMenuModel.accountModel,
          forceSync,
        );
        add(SyncWallet());
      }
    }
  }

  @override
  Future<void> close() {
    serverTransactionDataSubscription?.cancel();
    localTransactionDataSubscription?.cancel();
    bdkTransactionDataSubscription?.cancel();
    walletsDataSubscription?.cancel();
    return super.close();
  }
}
