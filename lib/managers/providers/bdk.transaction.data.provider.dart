// bdk.transaction.data.provider.dart
import 'dart:async';
import 'package:wallet/constants/app.config.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/exceptions.dart';
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
import 'package:wallet/rust/common/errors.dart';

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

class BDKTransactionDataProvider extends DataProvider {
  final AccountDao accountDao;
  StreamController<DataUpdated> dataUpdateController =
      StreamController<DataUpdated>.broadcast();
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
  Map<String, int> lastSyncedTime = {};

  Future<void> init(List<WalletModel> wallets) async {
    bdkTransactionDataList.clear();
    for (WalletModel walletModel in wallets) {
      final accounts = await accountDao.findAllByWalletID(walletModel.walletID);
      for (AccountModel accountModel in accounts) {
        syncWallet(
          walletModel,
          accountModel,
          forceSync: false,
        );
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
    final FrbAccount? account = await WalletManager.loadWalletWithID(
      walletModel.walletID,
      accountModel.accountID,
    );
    List<FrbTransactionDetails> transactions = [];
    if (account != null) {
      transactions = await account.getTransactions();
    }
    return BDKTransactionData(
        accountModel: accountModel, transactions: transactions);
  }

  Future<BDKTransactionData> getBDKTransactionDataByWalletAccount(
      WalletModel walletModel, AccountModel accountModel) async {
    // TODO(fix): use cache to enhance performance
    // for (BDKTransactionData bdkTransactionData in bdkTransactionDataList) {
    //   if (bdkTransactionData.accountModel.serverAccountID ==
    //       accountModel.serverAccountID) {
    //     return bdkTransactionData;
    //   }
    // }
    final BDKTransactionData bdkTransactionData =
        await _getBDKTransactionData(walletModel, accountModel);
    // bdkTransactionDataList.add(bdkTransactionData);
    return bdkTransactionData;
  }

  bool lastSyncTimeCheck(WalletModel walletModel, AccountModel accountModel) {
    final int timeDiff = DateTime.now().millisecondsSinceEpoch -
        (lastSyncedTime[accountModel.accountID] ?? 0);
    if (timeDiff > reSyncTime) {
      return true;
    }
    return false;
  }

  bool isSyncing(WalletModel walletModel, AccountModel accountModel) {
    return isWalletSyncing[accountModel.accountID] ?? false;
  }

  Future<void> syncWallet(
    WalletModel walletModel,
    AccountModel accountModel, {
    required bool forceSync,
  }) async {
    final bool isSyncing = isWalletSyncing.containsKey(accountModel.accountID)
        ? isWalletSyncing[accountModel.accountID]!
        : false;
    bool success = false;
    if (!isSyncing) {
      try {
        isWalletSyncing[accountModel.accountID] = true;
        blockchain ??= await Api.createEsploraBlockchainWithApi();

        final String serverWalletID = walletModel.walletID;
        final String serverAccountID = accountModel.accountID;
        final String syncCheckID =
            "is_wallet_full_synced_${serverWalletID}_$serverAccountID";

        final FrbAccount? account = await WalletManager.loadWalletWithID(
          walletModel.walletID,
          accountModel.accountID,
        );
        if (account != null) {
          final bool isSynced = await shared.read(syncCheckID) ?? false;
          if (!isSynced || forceSync) {
            logger.i("Bdk wallet full sync Started");
            await blockchain?.fullSync(
              account: account,
              stopGap: BigInt.from(appConfig.stopGap),
            );
            await shared.write(syncCheckID, true);
            logger.i("Bdk wallet full sync End");
            success = true;
          } else {
            logger.i("Bdk wallet partial sync check");

            // TODO(fix): check if it's needed
            // if (await blockchain!.shouldSync(account: account)) {
            logger.i("Bdk wallet partial sync Started");
            await blockchain!.partialSync(account: account);
            logger.i("Bdk wallet partial sync End");
            success = true;
            lastSyncedTime[accountModel.accountID] =
                DateTime.now().microsecondsSinceEpoch;
          }
        }
      } on BridgeError catch (e, stacktrace) {
        final errorMessage = parseSampleDisplayError(e);
        logger.e("Bdk wallet full sync error: $e, stacktrace: $stacktrace");
        CommonHelper.showErrorDialog(
          errorMessage,
        );
      } catch (e, stacktrace) {
        final String errorMessage =
            "Bdk wallet full sync error: $e \nstacktrace: $stacktrace";
        logger.e(errorMessage);

        // TODO(fix): remove this debug message
        CommonHelper.showErrorDialog(
          errorMessage,
        );
      } finally {
        isWalletSyncing[accountModel.accountID] = false;
        if (success) {
          dataUpdateController.add(DataUpdated("bdk data updated"));
        }
      }
    }
  }

  @override
  Future<void> clear() async {
    dataUpdateController.close();
  }
}
