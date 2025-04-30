import 'dart:async';
import 'dart:math';

import 'package:sentry/sentry.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/helper/exceptions.dart';
import 'package:wallet/helper/extension/datetime.dart';
import 'package:wallet/helper/extension/response.error.extension.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/preferences/preferences.keys.dart';
import 'package:wallet/managers/preferences/preferences.manager.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/providers/unleash.data.provider.dart';
import 'package:wallet/managers/providers/user.settings.data.provider.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/models/account.dao.impl.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/rust/api/api_service/wallet_client.dart';
import 'package:wallet/rust/api/bdk_wallet/account.dart';
import 'package:wallet/rust/api/bdk_wallet/account_syncer.dart';
import 'package:wallet/rust/api/bdk_wallet/blockchain.dart';
import 'package:wallet/rust/api/bdk_wallet/transaction_details.dart';
import 'package:wallet/rust/api/errors.dart';
import 'package:wallet/rust/common/keychain_kind.dart';
import 'package:wallet/rust/common/pagination.dart';

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
  /// manager
  final WalletManager walletManager;

  /// db dao
  final AccountDao accountDao;

  /// api services
  final WalletClient walletClient;
  final FrbBlockchainClient blockchainClient;

  /// shared preference
  final PreferencesManager shared;

  /// external data providers
  final UserSettingsDataProvider userSettingsDataProvider;
  final UnleashDataProvider unleashDataProvider;

  BDKTransactionDataProvider(
    this.accountDao,
    this.walletClient,
    this.blockchainClient,
    this.shared,
    this.walletManager,
    this.userSettingsDataProvider,
    this.unleashDataProvider,
  );

  /// memeory caches
  Map<String, bool> isWalletSyncing = {};
  Map<String, int> lastSyncedTime = {};

  Future<void> init(List<WalletModel> wallets) async {
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
      transactions = await account.getTransactions(filter: TransactionFilter.all);
    }
    return BDKTransactionData(
        accountModel: accountModel, transactions: transactions);
  }

  Future<BDKTransactionData> getBDKTransactionDataByWalletAccount(
      WalletModel walletModel, AccountModel accountModel) async {
    final BDKTransactionData bdkTransactionData =
        await _getBDKTransactionData(walletModel, accountModel);
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

  String getPositiveBalanceCheckID(
      WalletModel walletModel, AccountModel accountModel) {
    final String serverWalletID = walletModel.walletID;
    final String serverAccountID = accountModel.accountID;
    final String checkID =
        "${PreferenceKeys.bdkPositiveBalancePrefix}_${serverWalletID}_$serverAccountID";
    return checkID;
  }

  Future<bool> getHasPositiveBalance(
      WalletModel walletModel, AccountModel accountModel) async {
    final String checkID = getPositiveBalanceCheckID(walletModel, accountModel);
    return await shared.read(checkID) ?? false;
  }

  Future<void> setHasPositiveBalance(
      WalletModel walletModel, AccountModel accountModel,
      {required bool hasPositiveBalance}) async {
    final String checkID = getPositiveBalanceCheckID(walletModel, accountModel);
    await shared.write(checkID, hasPositiveBalance);
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
  bool anyFullSyncedDone() {
    final map = shared.toMap();
    for (var entry in map.entries) {
      final key = entry.key;
      if (key.toString().startsWith(PreferenceKeys.bdkFullSyncedPrefix) &&
          entry.value == true) {
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

  Future<bool> hasUsedServerStopgap(
      WalletModel walletModel, AccountModel accountModel) async {
    final String syncCheckID =
        "${getSyncCheckID(walletModel, accountModel)}_ServerStopgap";
    return await shared.read(syncCheckID) ?? false;
  }

  Future<void> setUsedServerStopgap(
      WalletModel walletModel, AccountModel accountModel) async {
    final String syncCheckID =
        "${getSyncCheckID(walletModel, accountModel)}_ServerStopgap";
    await shared.write(syncCheckID, true);
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
    bool syncSuccess = false;
    if (!isSyncing) {
      try {
        isWalletSyncing[accountModel.accountID] = true;

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
          final walletSync = FrbAccountSyncer(
            client: blockchainClient,
            account: account,
          );
          if (!isSynced || forceSync) {
            // when force sync reset the timmer and status. incase task failed cant restart
            final String syncCheckID =
                getSyncCheckID(walletModel, accountModel);
            await shared.write(syncCheckID, false);
            lastSyncedTime[accountModel.accountID] = 0;
            final timeStart = DateTime.now().secondsSinceEpoch();
            logger.i("Bdk wallet full sync start time: $timeStart");
            int customStopgap =
                await userSettingsDataProvider.getCustomStopgap();

            /// use max(customStopgap, accountModel.stopGap)
            /// for first full sync
            /// so we can find transactions in far index
            final bool hasUseServerGap =
                await hasUsedServerStopgap(walletModel, accountModel);
            if (!hasUseServerGap) {
              customStopgap = max(customStopgap, accountModel.stopGap);
              await setUsedServerStopgap(walletModel, accountModel);
            }
            logger.i("customStopgap: $customStopgap");

            await walletSync.fullSync(
              stopGap: BigInt.from(customStopgap + accountModel.poolSize),
            );
            await walletSync.partialSync();
            await shared.write(syncCheckID, true);
            final timeEnd = DateTime.now().secondsSinceEpoch();
            logger.i("Bdk wallet full sync end time: $timeEnd");
            syncSuccess = true;
          } else {
            lastSyncedTime[accountModel.accountID] = 0;
            logger.i("Bdk wallet partial sync check");
            final timeStart = DateTime.now().secondsSinceEpoch();
            logger.i("Bdk wallet partial sync start time: $timeStart");
            await walletSync.partialSync();

            final timeEnd = DateTime.now().secondsSinceEpoch();
            logger.i("Bdk wallet partial sync end time: $timeEnd");
            syncSuccess = true;
          }
          lastSyncedTime[accountModel.accountID] =
              DateTime.now().secondsSinceEpoch();
          await resetErrorCount();
        }
      } on BridgeError catch (e, stacktrace) {
        final timeEnd = DateTime.now().secondsSinceEpoch();
        logger.i("Bdk wallet partial sync end with error time: $timeEnd");
        await updateErrorCount();
        logger.e("Bdk wallet full sync error: $e, stacktrace: $stacktrace");
        emitState(BDKSyncError(e.localizedString));

        /// temp work around,
        ///   showError should be here upper layer needs to handle it
        ///   ignroe session errors until refactored this
        final responseError = parseResponseError(e);
        final isSessionExpired = parseSessionExpireError(e) != null;
        final isForceUpgrade = responseError?.isForceUpgrade() ?? false;
        if (!isSessionExpired && !isForceUpgrade) {
          // CommonHelper.showErrorDialog(errorMessage);
        }
        if (!ifMuonClientError(e)) {
          Sentry.captureException(
            e,
            stackTrace: stacktrace,
          );
        }
      } catch (e, stacktrace) {
        final count = await shared.read(PreferenceKeys.syncErrorCount) ?? 0;
        await shared.write(PreferenceKeys.syncErrorCount, count + 1);
        emitState(BDKSyncError(e.toString()));
        logger.e("Bdk wallet full sync error: $e \nstacktrace: $stacktrace");
        Sentry.captureException(e, stackTrace: stacktrace);
      } finally {
        logger.i("Bdk wallet sync end finally");
        isWalletSyncing[accountModel.accountID] = false;
        if (syncSuccess) {
          final timeEnd = DateTime.now().secondsSinceEpoch();
          final check = "${accountModel.accountID}_$timeEnd";
          emitState(BDKSyncUpdated(check));
        }
      }
    }

    /// update stopgap after sync if needed
    final FrbAccount? account = await walletManager.loadWalletWithID(
      walletModel.walletID,
      accountModel.accountID,
      serverScriptType: accountModel.scriptType,
    );
    if (account != null && syncSuccess) {
      final int? maximumGapSize =
          await account.getMaximumGapSize(keychain: KeychainKind.external_);
      if (maximumGapSize != null) {
        final int rangedStopgap = await account.getStopGapRange(
          maxGap: maximumGapSize,
        );
        if (rangedStopgap != accountModel.stopGap) {
          try {
            final _ = await walletClient.updateWalletAccountStopGap(
                walletId: walletModel.walletID,
                walletAccountId: accountModel.accountID,
                stopGap: rangedStopgap);
          } catch (e, stacktrace) {
            logger.e("Update stopgap error: $e stacktrace: $stacktrace");
            Sentry.captureException(e, stackTrace: stacktrace);
          }
        }
      }
    }

    /// check metrics after sync
    if (account != null && syncSuccess) {
      try {
        final balance = await account.getBalance();
        final hasPositiveBalance =
            balance.trustedSpendable().toSat().toInt() > 0;
        final hasPositiveBalanceInCache =
            await getHasPositiveBalance(walletModel, accountModel);
        if (hasPositiveBalance != hasPositiveBalanceInCache) {
          /// update cache to avoid spam
          await setHasPositiveBalance(walletModel, accountModel,
              hasPositiveBalance: hasPositiveBalance);
          await walletClient.sendWalletAccountMetrics(
            walletId: walletModel.walletID,
            walletAccountId: accountModel.accountID,
            hasPositiveBalance: hasPositiveBalance,
          );
        }
      } catch (e, stacktrace) {
        logger
            .e("Send Wallet Account Metrics error: $e stacktrace: $stacktrace");
        Sentry.captureException(e, stackTrace: stacktrace);
      }
    }
  }

  @override
  Future<void> clear() async {
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
    final count = await shared.read(PreferenceKeys.syncErrorCount) ?? 0;
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
