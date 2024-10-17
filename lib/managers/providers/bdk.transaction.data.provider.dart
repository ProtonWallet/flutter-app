// bdk.transaction.data.provider.dart
import 'dart:async';
import 'dart:math';
import 'package:sentry/sentry.dart';
import 'package:wallet/constants/app.config.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/exceptions.dart';
import 'package:wallet/helper/extension/datetime.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/preferences/preferences.keys.dart';
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

class BDKSyncUpdated extends DataUpdated<String> {
  BDKSyncUpdated(super.updatedData);
}

class BDKSyncCancelled extends DataUpdated<String> {
  BDKSyncCancelled(super.updatedData);
}

class BDKSyncing extends DataUpdated<String> {
  BDKSyncing(super.updatedData);
}

class BDKSyncError extends DataUpdated<String> {
  BDKSyncError(super.updatedData);
}

class BDKCacheCleared extends DataUpdated<String> {
  BDKCacheCleared(super.updatedData);
}

class BDKTransactionDataProvider extends DataProvider {
  // TODO(fix): shouldnt be here. sync shouldnt be in this class
  final WalletManager walletManager;
  final AccountDao accountDao;
  FrbBlockchainClient? blockchain;
  final ProtonApiService apiService;

  final PreferencesManager shared;

  BDKTransactionDataProvider(
    this.accountDao,
    this.apiService,
    this.shared,
    this.walletManager,
  );

  List<BDKTransactionData> bdkTransactionDataList = [];
  Map<String, bool> isWalletSyncing = {};
  Map<String, int> lastSyncedTime = {};

  Future<void> init(List<WalletModel> wallets) async {
    bdkTransactionDataList.clear();
    resetErrorCount();
    for (WalletModel walletModel in wallets) {
      final accounts = await accountDao.findAllByWalletID(walletModel.walletID);
      for (AccountModel accountModel in accounts) {
        syncWallet(
          walletModel,
          accountModel,
          forceSync: false,
          heightChanged: false,
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
    final FrbAccount? account = await walletManager.loadWalletWithID(
      walletModel.walletID,
      accountModel.accountID,
      serverScriptType: accountModel.scriptType,
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

  String getSyncCheckID(WalletModel walletModel, AccountModel accountModel) {
    final String serverWalletID = walletModel.walletID;
    final String serverAccountID = accountModel.accountID;
    final String syncCheckID =
        "${PreferenceKeys.bdkFullSyncedPrefix}_${bdkDatabaseVersion}_${serverWalletID}_$serverAccountID";
    return syncCheckID;
  }

  /// return true if at lease one full sync done
  /// i.e. preferences has at least one key starts with bdkFullSyncedPrefix, and value is true
  bool anyFullSyncedDone(){
    final map = shared.toMap();
    for (var entry in map.entries) {
      final key = entry.key;
      if (key.toString().startsWith(PreferenceKeys.bdkFullSyncedPrefix) && entry.value == true) {
        return true;
      }
    }
    return false;
  }

  Future<bool> hasFullSynced(
      WalletModel walletModel, AccountModel accountModel) async {
    final String syncCheckID = getSyncCheckID(walletModel, accountModel);
    return await shared.read(syncCheckID) ?? false;
  }

  Future<void> syncWallet(
    WalletModel walletModel,
    AccountModel accountModel, {
    required bool forceSync,
    required bool heightChanged,
  }) async {
    final bool isSyncing = isWalletSyncing.containsKey(accountModel.accountID)
        ? isWalletSyncing[accountModel.accountID]!
        : false;
    bool success = false;
    if (!isSyncing) {
      try {
        isWalletSyncing[accountModel.accountID] = true;
        blockchain ??= await Api.createEsploraBlockchainWithApi();
        final FrbAccount? account = await walletManager.loadWalletWithID(
          walletModel.walletID,
          accountModel.accountID,
          serverScriptType: accountModel.scriptType,
        );
        if (account != null) {
          logger.i("Bdk wallet sync check start!");

          /// check can i run
          final errorTimer =
              await shared.read(PreferenceKeys.syncErrorTimer) ?? 0;

          final int currentTime = DateTime.now().secondsSinceEpoch();
          if (!forceSync && currentTime - errorTimer < 0) {
            logger.i("Bdk wallet check error timmer cancelled");
            isWalletSyncing[accountModel.accountID] = false;
            final timeEnd = DateTime.now().secondsSinceEpoch();
            final check = "${accountModel.accountID}_$timeEnd";
            emitState(BDKSyncCancelled(check));
            return;
          }

          /// check last sync time
          final int lastSyncTime = lastSyncedTime[accountModel.accountID] ?? 0;
          final int currentTimestamp = DateTime.now().secondsSinceEpoch();
          final int timeDiffSeconds = currentTimestamp - lastSyncTime;
          if (!forceSync && !heightChanged && timeDiffSeconds < reSyncTime) {
            logger.i("Bdk wallet check last sync time cancelled");
            isWalletSyncing[accountModel.accountID] = false;
            final timeEnd = DateTime.now().secondsSinceEpoch();
            final check = "${accountModel.accountID}_$timeEnd";
            emitState(BDKSyncCancelled(check));
            return;
          }

          final bool isSynced = await hasFullSynced(walletModel, accountModel);
          if (!isSynced || forceSync) {
            // when force sync reset the timmer and status. incase task failed cant restart
            final String syncCheckID =
                getSyncCheckID(walletModel, accountModel);
            await shared.write(syncCheckID, false);
            lastSyncedTime[accountModel.accountID] = 0;
            final timeStart = DateTime.now().secondsSinceEpoch();
            logger.i("Bdk wallet full sync start time: $timeStart");
            await blockchain?.fullSync(
              account: account,
              stopGap: BigInt.from(appConfig.stopGap + accountModel.poolSize),
            );
            await shared.write(syncCheckID, true);
            final timeEnd = DateTime.now().secondsSinceEpoch();
            logger.i("Bdk wallet full sync end time: $timeEnd");
            success = true;
          } else {
            lastSyncedTime[accountModel.accountID] = 0;
            logger.i("Bdk wallet partial sync check");
            final timeStart = DateTime.now().secondsSinceEpoch();
            logger.i("Bdk wallet partial sync start time: $timeStart");
            await blockchain!.partialSync(account: account);

            final timeEnd = DateTime.now().secondsSinceEpoch();
            logger.i("Bdk wallet partial sync end time: $timeEnd");
            success = true;
          }

          lastSyncedTime[accountModel.accountID] =
              DateTime.now().secondsSinceEpoch();
          await resetErrorCount();
        }
      } on BridgeError catch (e, stacktrace) {
        final timeEnd = DateTime.now().secondsSinceEpoch();
        logger.i("Bdk wallet partial sync end with error time: $timeEnd");
        await updateErrorCount();
        final errorMessage = parseSampleDisplayError(e);
        logger.e("Bdk wallet full sync error: $e, stacktrace: $stacktrace");
        emitState(BDKSyncError(errorMessage));
        CommonHelper.showErrorDialog(
          errorMessage,
        );
        if (!ifMuonClientError(e)) {
          Sentry.captureException(
            e,
            stackTrace: stacktrace,
          );
        }
      } catch (e, stacktrace) {
        final count =
            await shared.read(PreferenceKeys.syncErrorCount) ?? 0;
        await shared.write(PreferenceKeys.syncErrorCount, count + 1);
        emitState(BDKSyncError(e.toString()));
        final String errorMessage =
            "Bdk wallet full sync error: $e \nstacktrace: $stacktrace";
        logger.e(errorMessage);
        CommonHelper.showErrorDialog(
          errorMessage,
        );
      } finally {
        logger.i("Bdk wallet sync end finally");
        isWalletSyncing[accountModel.accountID] = false;
        if (success) {
          final timeEnd = DateTime.now().secondsSinceEpoch();
          final check = "${accountModel.accountID}_$timeEnd";
          emitState(BDKSyncUpdated(check));
        }
      }
    }
  }

  @override
  Future<void> clear() async {
    bdkTransactionDataList.clear();
    isWalletSyncing.clear();
    lastSyncedTime.clear();
  }

  /// BDK local files and memory caches cleared
  /// change state to notify other data providers
  void notifyCacheCleared() {
    emitState(BDKCacheCleared("Cleared caches"));
  }

  int _getNextBackoffDuration(
    int attempt, {
    int minSeconds = 30,
    int maxSeconds = 600,
  }) {
    // Calculate the exponential backoff duration
    final int exponentialBackoff = pow(2, attempt).toInt();

    // Generate a random value within the exponential backoff range
    final int randomBackoff = Random().nextInt(exponentialBackoff + 1);

    // Ensure the random backoff is within the specified range
    final int duration = min(max(minSeconds, randomBackoff), maxSeconds);

    return duration;
  }

  Future<void> updateErrorCount() async {
    final count =
        await shared.read(PreferenceKeys.syncErrorCount) ?? 0;
    await shared.write(PreferenceKeys.syncErrorCount, count + 1);
    final newTimeer = DateTime.now().secondsSinceEpoch() +
        _getNextBackoffDuration(count, minSeconds: 120, maxSeconds: 300);
    await shared.write(PreferenceKeys.syncErrorTimer, newTimeer);
  }

  Future<void> resetErrorCount() async {
    await shared.write(PreferenceKeys.syncErrorCount, 0);
    await shared.write(PreferenceKeys.syncErrorTimer, 0);
  }

  @override
  Future<void> reload() async {}
}
