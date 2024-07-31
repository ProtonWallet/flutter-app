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
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/helper/walletkey_helper.dart';
import 'package:wallet/managers/features/wallet.list/wallet.list.dart';
import 'package:wallet/managers/providers/address.keys.provider.dart';
import 'package:wallet/managers/providers/bdk.transaction.data.provider.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/providers/local.bitcoin.address.provider.dart';
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
import 'package:wallet/models/transaction.model.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/rust/api/bdk_wallet/account.dart';
import 'package:wallet/rust/api/bdk_wallet/transaction_details.dart';
import 'package:wallet/rust/api/bdk_wallet/transaction_details_txop.dart';
import 'package:wallet/rust/common/address_info.dart';
import 'package:wallet/rust/common/transaction_time.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/rust/proton_api/wallet.dart';

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
  final bool skipSyncWallet;

  SelectWallet(
    this.walletMenuModel, {
    required this.skipSyncWallet,
  });

  @override
  List<Object> get props => [walletMenuModel, skipSyncWallet];
}

class UpdateWalletSyncCancelled extends WalletTransactionEvent {
  final String accountID;
  UpdateWalletSyncCancelled(this.accountID);
  @override
  List<Object> get props => [accountID];
}

class UpdateWalletError extends WalletTransactionEvent {
  final String errorMessage;
  UpdateWalletError(
    this.errorMessage,
  );

  @override
  List<Object> get props => [errorMessage];
}

class UpdateWalletDone extends WalletTransactionEvent {
  UpdateWalletDone();

  @override
  List<Object> get props => [];
}

class SelectAccount extends WalletTransactionEvent {
  final WalletMenuModel walletMenuModel;
  final AccountMenuModel accountMenuModel;
  final bool skipSyncWallet;

  SelectAccount(
    this.walletMenuModel,
    this.accountMenuModel, {
    required this.skipSyncWallet,
  });

  @override
  List<Object> get props => [walletMenuModel, accountMenuModel, skipSyncWallet];
}

// Define the state
class WalletTransactionState extends Equatable {
  ///
  /// The historyTransaction is build from
  /// 1. ServerTransactionDataProvider, this is used to add additional information, i.e. message to recipients, label of transaction, email name.. etc
  /// 2. BKDTransactionDataProvider, this is main transactionProvider, 1 and 2 are used when bdk not synced (bdk didn't know the transaction yet)
  final List<HistoryTransaction> historyTransaction;
  final List<BitcoinAddressDetail> bitcoinAddresses;
  final bool isSyncing;
  final bool syncedWithError;
  final String errorMessage;

  const WalletTransactionState({
    required this.historyTransaction,
    required this.bitcoinAddresses,
    required this.isSyncing,
    required this.syncedWithError,
    required this.errorMessage,
  });

  @override
  List<Object?> get props => [
        isSyncing,
        historyTransaction,
        bitcoinAddresses,
        syncedWithError,
        errorMessage,
      ];
}

extension WalletTransactionStateCopyWith on WalletTransactionState {
  WalletTransactionState copyWith({
    bool isSyncing = false,
    bool? syncedWithError,
    List<HistoryTransaction>? historyTransaction,
    List<BitcoinAddressDetail>? bitcoinAddresses,
    String? errorMessage,
  }) {
    return WalletTransactionState(
      isSyncing: isSyncing,
      bitcoinAddresses: bitcoinAddresses ?? this.bitcoinAddresses,
      historyTransaction: historyTransaction ?? this.historyTransaction,
      syncedWithError: syncedWithError ?? this.syncedWithError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Define the Bloc
class WalletTransactionBloc
    extends Bloc<WalletTransactionEvent, WalletTransactionState> {
  final UserManager userManager;
  final BDKTransactionDataProvider bdkTransactionDataProvider;
  final ServerTransactionDataProvider serverTransactionDataProvider;
  final AddressKeyProvider addressKeyProvider;
  final WalletKeysProvider walletKeysProvider;
  final LocalBitcoinAddressDataProvider localBitcoinAddressDataProvider;
  final WalletsDataProvider walletsDataProvider;
  final UserSettingsDataProvider userSettingsDataProvider;

  StreamSubscription? serverTransactionDataSubscription;
  StreamSubscription? bdkTransactionDataSubscription;
  StreamSubscription? walletsDataSubscription;
  StreamSubscription? fiatCurrencySettingSubscription;

  WalletTransactionEvent? lastEvent;

  WalletTransactionBloc(
    this.userManager,
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
          syncedWithError: false,
          errorMessage: "",
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
              skipSyncWallet: false, // need to sync wallet
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
                  skipSyncWallet: false, // need to sync wallet
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
        bdkTransactionDataProvider.stream.listen((state) {
      if (state is BDKSyncUpdated) {
        handleTransactionDataProviderUpdate();
        if (this.state.errorMessage.isNotEmpty) {
          add(UpdateWalletDone());
        }
      } else if (state is BDKSyncError) {
        add(UpdateWalletError(state.updatedData));
        handleTransactionDataProviderUpdate();
      } else if (state is BDKSyncCancelled) {
        if (this.state.isSyncing) {
          handleTransactionDataProviderUpdate();
        }
      }
    });

    serverTransactionDataSubscription = serverTransactionDataProvider
        .dataUpdateController.stream
        .listen((onData) {
      handleTransactionDataProviderUpdate();

      if (onData.updatedData == UpdateType.inserted) {
        Future.delayed(const Duration(seconds: 10), () {
          /// wait 10 second so transaction can update first
          /// since bdk account will be locked when it's syncing
          syncWallet(forceSync: true, heightChanged: false);
        });
      }

      /// syncWallet so that balance can get update
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
      for (AccountMenuModel accountMenuModel
          in event.walletMenuModel.accounts) {
        if (!event.skipSyncWallet) {
          bdkTransactionDataProvider.syncWallet(
            event.walletMenuModel.walletModel,
            accountMenuModel.accountModel,
            forceSync: false,
            heightChanged: false,
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

      List<BitcoinAddressDetail> bitcoinAddresses = [];
      final WalletModel walletModel = event.walletMenuModel.walletModel;
      final SecretKey? secretKey = await getSecretKey(
        event.walletMenuModel.walletModel,
      );

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
      if (!event.skipSyncWallet) {
        bdkTransactionDataProvider.syncWallet(
          event.walletMenuModel.walletModel,
          event.accountMenuModel.accountModel,
          forceSync: false,
          heightChanged: false,
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

    on<UpdateWalletError>((event, emit) async {
      emit(state.copyWith(
        syncedWithError: true,
        errorMessage: event.errorMessage,
      ));
    });

    on<UpdateWalletDone>((event, emit) async {
      emit(state.copyWith(
        syncedWithError: false,
        errorMessage: "",
      ));
    });
  }

  void handleTransactionDataProviderUpdate() {
    if (lastEvent != null) {
      if (lastEvent is SelectWallet) {
        final SelectWallet selectWallet = (lastEvent! as SelectWallet);
        add(SelectWallet(
          selectWallet.walletMenuModel,
          skipSyncWallet: true,
        ));
      } else if (lastEvent is SelectAccount) {
        final SelectAccount selectAccount = (lastEvent! as SelectAccount);
        add(SelectAccount(
          selectAccount.walletMenuModel,
          selectAccount.accountMenuModel,
          skipSyncWallet: true,
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

  String tryDecryptWithKeys(List<dynamic> keys, String encryptedString) {
    String result = "";
    for (final key in keys) {
      try {
        if (encryptedString.isNotEmpty) {
          result = key.decrypt(encryptedString);
        }
      } catch (e) {
        logger.e(e.toString());
      }
      if (result.isNotEmpty) {
        break;
      }
    }
    if (result.isEmpty) {
      for (final key in keys) {
        try {
          if (encryptedString.isNotEmpty) {
            result = key.decryptBinary(encryptedString);
          }
        } catch (e) {
          logger.e(e.toString());
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
      serverScriptType: accountMenuModel.accountModel.scriptType,
    );

    final Map<String, FrbAddressInfo> selfBitcoinAddressInfo =
        await localBitcoinAddressDataProvider.getBitcoinAddress(
      walletModel,
      accountMenuModel.accountModel,
      account,
      maxAddressIndex: accountModel.lastUsedIndex + appConfig.stopGap,
    );

    final userKeys = await userManager.getUserKeys();
    for (final transactionModel in serverTransactionData.transactions) {
      String txid = "";
      for (final uKey in userKeys) {
        try {
          txid = proton_crypto.decrypt(
            uKey.privateKey,
            uKey.passphrase,
            transactionModel.transactionID,
          );
          break;
        } catch (e, stacktrace) {
          logger.i(
            "getHistoryTransactions error: $e stacktrace: $stacktrace",
          );
        }
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
      bool isInternalTransaction = false;

      if (transactionModel != null) {
        final String encryptedToList = transactionModel.tolist ?? "";
        final String encryptedSender = transactionModel.sender ?? "";
        final String encryptedBody = transactionModel.body ?? "";

        toList = tryDecryptWithKeys(userKeys, encryptedToList);
        sender = tryDecryptWithKeys(userKeys, encryptedSender);
        body = tryDecryptWithKeys(userKeys, encryptedBody);
        if (toList.isEmpty) {
          toList = tryDecryptWithKeys(addressKeys, encryptedToList);
        }
        if (sender.isEmpty) {
          sender = tryDecryptWithKeys(addressKeys, encryptedSender);
        }
        if (body.isEmpty) {
          body = tryDecryptWithKeys(addressKeys, encryptedBody);
        }
        isInternalTransaction = (transactionModel.type ==
                TransactionType.protonToProtonSend.index ||
            transactionModel.type ==
                TransactionType.protonToProtonReceive.index);
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
          time = confirmationTime.toInt();
          lastSeenTime = confirmationTime.toInt();
        },
        unconfirmed: (lastSeen) {
          lastSeenTime = lastSeen.toInt();
        },
      );

      newHistoryTransactionsMap[key] = HistoryTransaction(
        txID: txID,
        createTimestamp: time,
        updateTimestamp: lastSeenTime,
        amountInSATS: amountInSATS,
        sender: sender.isNotEmpty
            ? sender
            : isInternalTransaction
                ? "Anonymous sender"
                : "Unknown",
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
    return newHistoryTransactionsMap.values.toList();
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

  Future<SecretKey?> getSecretKey(WalletModel walletModel) async {
    /// restore walletKey, it will be use to decrypt transaction txid from server, and transaction user label from server
    final walletKey = await walletKeysProvider.getWalletKey(
      walletModel.walletID,
    );
    SecretKey? secretKey;
    if (walletKey != null) {
      final userKey = await userManager.getUserKey(walletKey.userKeyId);
      secretKey = WalletKeyHelper.decryptWalletKey(userKey, walletKey);
    }
    return secretKey;
  }

  void init() {
    add(StartLoading());
  }

  void selectWallet(WalletMenuModel walletMenuModel) {
    add(SelectWallet(
      walletMenuModel,
      skipSyncWallet: false,
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
      skipSyncWallet: false,
    ));
  }

  void syncWallet({required bool forceSync, required bool heightChanged}) {
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
              heightChanged: heightChanged,
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
            heightChanged: heightChanged,
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
    bdkTransactionDataSubscription?.cancel();
    walletsDataSubscription?.cancel();
    fiatCurrencySettingSubscription?.cancel();
    return super.close();
  }
}
