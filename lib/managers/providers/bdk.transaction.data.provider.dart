// bdk.transaction.data.provider.dart
import 'dart:async';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/preferences/preferences.manager.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/models/account.dao.impl.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/rust/api/api_service/proton_api_service.dart';
import 'package:wallet/rust/api/bdk_wallet/account.dart';
import 'package:wallet/rust/api/bdk_wallet/blockchain.dart';
import 'package:wallet/rust/api/bdk_wallet/transaction_details.dart';
import 'package:wallet/rust/api/rust_api.dart';
import 'package:wallet/scenes/core/coordinator.dart';

class BDKWalletData {
  final WalletModel walletModel;
  final AccountModel accountModel;
  final FrbAccount account;

  BDKWalletData({
    required this.walletModel,
    required this.accountModel,
    required this.account,
  });
}

class BDKTransactionData {
  final AccountModel accountModel;
  List<FrbTransactionDetails> transactions = [];

  BDKTransactionData({
    required this.accountModel,
    required this.transactions,
  });
}

class BDKDataUpdated extends DataState {
  final String accountID;

  BDKDataUpdated(this.accountID);

  @override
  List<Object?> get props => [accountID];
}

class BDKTransactionDataProvider extends DataProvider {
  final AccountDao accountDao;

  FrbBlockchainClient? blockchain;
  final ProtonApiService apiService;

  final PreferencesManager shared;

  BDKTransactionDataProvider(
    this.accountDao,
    this.apiService,
    this.shared,
  );

  List<BDKTransactionData> bdkTransactionDataList = [];
  Map<String, bool> isWalletSyncing = {};

  Future<void> init(List<WalletModel> wallets) async {
    bdkTransactionDataList.clear();
    for (WalletModel walletModel in wallets) {
      List<AccountModel> accounts =
          (await accountDao.findAllByWalletID(walletModel.id!))
              .cast<AccountModel>();
      for (AccountModel accountModel in accounts) {
        syncWallet(walletModel, accountModel);
        bdkTransactionDataList.add(await _getBDKTransactionData(
          walletModel,
          accountModel,
        ));
      }
    }
  }

  Future<BDKTransactionData> _getBDKTransactionData(
    WalletModel walletModel,
    AccountModel accountModel,
  ) async {
    FrbAccount? account =
        await WalletManager.loadWalletWithID(walletModel.id!, accountModel.id!);
    List<FrbTransactionDetails> transactions = [];
    if (account != null) {
      transactions = await account.getTransactions();
    }
    return BDKTransactionData(
        accountModel: accountModel, transactions: transactions);
  }

  Future<BDKTransactionData> getBDKTransactionDataByWalletAccount(
      WalletModel walletModel, AccountModel accountModel) async {
    /// TODO:: use cache to enhance performance
    // for (BDKTransactionData bdkTransactionData in bdkTransactionDataList) {
    //   if (bdkTransactionData.accountModel.serverAccountID ==
    //       accountModel.serverAccountID) {
    //     return bdkTransactionData;
    //   }
    // }
    BDKTransactionData bdkTransactionData =
        await _getBDKTransactionData(walletModel, accountModel);
    // bdkTransactionDataList.add(bdkTransactionData);
    return bdkTransactionData;
  }

  bool isSyncing(WalletModel walletModel, AccountModel accountModel) {
    return isWalletSyncing[accountModel.serverAccountID] ?? false;
  }

  Future<void> syncWallet(
    WalletModel walletModel,
    AccountModel accountModel, [
    bool forceSync = false,
  ]) async {
    bool isSyncing = isWalletSyncing.containsKey(accountModel.serverAccountID)
        ? isWalletSyncing[accountModel.serverAccountID]!
        : false;
    if (isSyncing == false) {
      try {
        isWalletSyncing[accountModel.serverAccountID] = true;
        blockchain ??= await Api.createEsploraBlockchainWithApi();

        String serverWalletID = walletModel.serverWalletID;
        String serverAccountID = accountModel.serverAccountID;
        String syncCheckID =
            "is_wallet_full_synced_${serverWalletID}_$serverAccountID";

        FrbAccount? account = await WalletManager.loadWalletWithID(
            walletModel.id!, accountModel.id!);
        if (account != null) {
          bool isSynced = await shared.read(syncCheckID) ?? false;
          if (!isSynced || forceSync) {
            logger.i("Bdk wallet full sync Started");
            await blockchain?.fullSync(account: account);
            await shared.write(syncCheckID, true);
            logger.i("Bdk wallet full sync End");
          } else {
            logger.i("Bdk wallet partial sync check");
            if (await blockchain!.shouldSync(account: account)) {
              logger.i("Bdk wallet partial sync Started");
              await blockchain!.partialSync(account: account);
              logger.i("Bdk wallet partial sync End");
            }
          }
        }
        emitState(BDKDataUpdated(serverAccountID));
      } catch (e, stacktrace) {
        String errorMessage =
            "Bdk wallet full sync error: ${e.toString()} \nstacktrace: ${stacktrace.toString()}";
        logger.e(errorMessage);

        /// TODO:: remove this debug message
        CommonHelper.showErrorDialog(
          errorMessage,
        );
      } finally {
        isWalletSyncing[accountModel.serverAccountID] = false;
      }
    }
  }

  @override
  Future<void> clear() async {}
}
