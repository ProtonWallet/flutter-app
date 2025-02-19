import 'dart:async';
import 'dart:typed_data';

import 'package:sentry/sentry.dart';
import 'package:wallet/constants/coin_type.dart';
import 'package:wallet/constants/script_type.dart';
import 'package:wallet/helper/extension/strings.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/providers/models/wallet.mnemonic.dart';
import 'package:wallet/managers/secure.storage/secure.storage.manager.dart';
import 'package:wallet/models/account.dao.impl.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/address.dao.impl.dart';
import 'package:wallet/models/address.model.dart';
import 'package:wallet/models/wallet.dao.impl.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/rust/api/api_service/wallet_client.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/rust/proton_api/wallet.dart';
import 'package:wallet/rust/proton_api/wallet_account.dart';

/// Defines class for wallet data, which contains a wallet and its associated accounts.
class WalletData {
  final WalletModel wallet;
  final List<AccountModel> accounts;

  WalletData({required this.wallet, required this.accounts});
}

class WalletsDataProvider extends DataProvider {
  /// secure storage
  final SecureStorageManager storage;
  final key = "proton_wallet_mn_provider_key";

  /// streams
  StreamController<DataUpdated> dataUpdateController =
      StreamController<DataUpdated>.broadcast();
  StreamController<SelectedWalletUpdated> selectedWalletUpdateController =
      StreamController<SelectedWalletUpdated>.broadcast();
  StreamController<NewBroadcastTransaction> newBroadcastTransactionController =
      StreamController<NewBroadcastTransaction>.broadcast();

  /// api client
  final WalletClient walletClient;

  /// db dao
  final WalletDao walletDao;
  final AccountDao accountDao;
  final AddressDao addressDao;

  /// memory caches
  String selectedServerWalletID;
  String selectedServerWalletAccountID;

  /// need to monitor the db changes apply to this cache
  List<WalletData>? walletsData;

  /// user id
  final String userID;

  WalletsDataProvider(
    this.storage,
    this.walletDao,
    this.accountDao,
    this.addressDao,
    this.walletClient,
    this.selectedServerWalletID,
    this.selectedServerWalletAccountID,
    this.userID,
  );

  WalletData? getCurrentWalletData() {
    for (WalletData walletData in walletsData ?? []) {
      if (walletData.wallet.walletID == selectedServerWalletID) {
        return walletData;
      }
    }
    return null;
  }

  Future<List<WalletData>?> _getFromDB() async {
    final List<WalletData> retWallet = [];

    /// try to find wallets from db
    final wallets = await walletDao.findAllByUserID(userID);

    if (wallets.isNotEmpty) {
      /// return in List<WalletData> if we can find wallets from db
      for (WalletModel walletModel in wallets) {
        retWallet.add(WalletData(
          wallet: walletModel,
          accounts: await accountDao.findAllByWalletID(
            walletModel.walletID,
          ),
        ));
      }
      return retWallet;
    }
    return null;
  }

  Future<WalletMnemonic?> getWalletMnemonic(String walletID) async {
    var found = await _searchFromKeychain(walletID);
    if (found != null) {
      return found;
    }

    /// fetch from server
    await _fetchFromServer();

    found = await _searchFromKeychain(walletID);
    if (found != null) {
      return found;
    }
    return null;
  }

  Future<WalletMnemonic?> _searchFromKeychain(String walletID) async {
    final walletMnemonics = await _getWalletMnemonics();
    if (walletMnemonics != null) {
      final key = walletMnemonics
          .where((key) => key.walletID == walletID)
          .toList()
          .firstOrNull;
      return key;
    }
    return null;
  }

  /// fetch from local cache
  Future<List<WalletMnemonic>?> _getWalletMnemonics() async {
    final json = await storage.get(key);
    if (json.isEmpty) {
      return null;
    }
    try {
      final walletMnemonics = await WalletMnemonic.loadJsonString(json);
      return walletMnemonics;
    } catch (e, stacktrace) {
      logger.e("$e stacktrace: $stacktrace");
    }
    return null;
  }

  Future<void> saveWalletMnemonics(List<WalletMnemonic> values) async {
    if (values.isEmpty) {
      logger.e("wallet mnemonic is empty");
      return;
    }

    var walletMnemonics = await _getWalletMnemonics();

    final Map<String, WalletMnemonic> mergedMap = {};

    /// Insert items from list1 first
    for (final key in walletMnemonics ?? []) {
      mergedMap[key.walletID] = key;
    }

    for (final key in values) {
      mergedMap[key.walletID] = key;
    }

    walletMnemonics = mergedMap.values.toList();
    final jsonString = WalletMnemonic.toJsonString(walletMnemonics);
    await storage.set(key, jsonString);
  }

  Future<List<WalletData>?> getWallets() async {
    /// return memory cache directly if exitst
    if (walletsData != null) {
      return walletsData;
    }

    /// try get wallets data from db
    walletsData = await _getFromDB();
    if (walletsData != null) {
      return walletsData;
    }

    /// try fetch wallets from server if we cannot find any record in db
    await _fetchFromServer();

    /// update memory cache
    walletsData = await _getFromDB();
    if (walletsData != null) {
      return walletsData;
    }
    return null;
  }

  Future<void> _fetchFromServer() async {
    /// try to fetch from server:
    final List<ApiWalletData> apiWallets = await walletClient.getWallets();
    for (ApiWalletData apiWalletData in apiWallets.reversed) {
      /// update and insert wallet
      final String serverWalletID = apiWalletData.wallet.id;
      await _processApiWalletData(apiWalletData);
      final apiWalletAccts = await walletClient.getWalletAccounts(
        walletId: apiWalletData.wallet.id,
      );

      /// this id is serverWalletID
      for (ApiWalletAccount apiWalletAcct in apiWalletAccts) {
        final String serverAccountID = apiWalletAcct.id;
        await _processApiWalletAccountData(serverWalletID, apiWalletAcct);

        for (ApiEmailAddress address in apiWalletAcct.addresses) {
          addEmailAddressToWalletAccount(
            serverWalletID,
            serverAccountID,
            address,
          );
        }
      }
    }
  }

  Future<WalletData?> getWallet(String walletID) async {
    final wallets = await getWallets();
    if (wallets != null) {
      for (WalletData walletData in wallets) {
        if (walletData.wallet.walletID == walletID) {
          return walletData;
        }
      }
    }
    return null;
  }

  Future<void> disableShowWalletRecovery(String walletId) async {
    await walletClient.disableShowWalletRecovery(walletId: walletId);
  }

  Future<ApiWalletData> createWallet(CreateWalletReq request) async {
    /// execute createWallet api calls, if failed it will throw error
    final ApiWalletData walletData =
        await walletClient.createWallet(walletReq: request);

    await _processApiWalletData(walletData);

    /// update cache
    walletsData = await _getFromDB();

    return walletData;
  }

  Future<int> getNewDerivationAccountIndex(
    String walletID,
    ScriptTypeInfo scriptType,
    CoinType coinType,
  ) async {
    String derivationPath = "";
    int newAccountIndex = 0;
    final wallet = await getWallet(walletID);
    if (wallet == null) {
      throw Exception("Wallet not found");
    }
    while (true) {
      /// return when the derivation path is not used
      derivationPath = formatDerivationPath(
        scriptType,
        coinType,
        newAccountIndex,
      );
      if (_isDerivationPathExist(wallet.accounts, derivationPath) ||
          _isDerivationPathExist(wallet.accounts, "m/$derivationPath")) {
        newAccountIndex++;
      } else {
        return newAccountIndex;
      }
    }
  }

  Future<String> getNewDerivationPathBy(
    String walletID,
    ScriptTypeInfo scriptType,
    CoinType coinType, {
    int? accountIndex,
  }) async {
    String derivationPath = "";
    int newAccountIndex = 0;
    if (accountIndex != null) {
      newAccountIndex = accountIndex;
    } else {
      newAccountIndex = await getNewDerivationAccountIndex(
        walletID,
        scriptType,
        coinType,
      );
    }
    derivationPath = formatDerivationPath(
      scriptType,
      coinType,
      newAccountIndex,
    );
    return derivationPath;
  }

  String formatDerivationPath(
    ScriptTypeInfo scriptType,
    CoinType coinType,
    int accountIndex,
  ) {
    final String derivationPath =
        "${scriptType.bipVersion}'/${coinType.type}'/$accountIndex'";
    return derivationPath;
  }

  bool _isDerivationPathExist(
    List<AccountModel> accounts,
    String derivationPath,
  ) {
    for (var element in accounts) {
      final left = element.derivationPath;
      if (left == derivationPath) {
        return true;
      }
    }
    return false;
  }

  Future<ApiWalletAccount> createWalletAccount(
    String walletID,
    CreateWalletAccountReq request,
    FiatCurrency fiatCurrency,
  ) async {
    var walletAccount = await walletClient.createWalletAccount(
      walletId: walletID,
      req: request,
    );

    walletAccount = await walletClient.updateWalletAccountFiatCurrency(
      walletId: walletID,
      walletAccountId: walletAccount.id,
      newFiatCurrency: fiatCurrency,
    );

    final wallet = await getWallet(walletID);
    await _processApiWalletAccountData(wallet!.wallet.walletID, walletAccount);

    /// update cache
    walletsData = await _getFromDB();
    dataUpdateController.add(DataUpdated("some data Updated"));
    return walletAccount;
  }

  Future<void> updateWallet({required WalletModel wallet}) async {
    await walletDao.update(wallet);

    /// update cache,
    walletsData = await _getFromDB();
    dataUpdateController.add(DataUpdated("some data Updated"));
  }

  Future<void> updateWalletAccount({required AccountModel accountModel}) async {
    await accountDao.update(accountModel);

    /// update cache,
    walletsData = await _getFromDB();
    dataUpdateController.add(DataUpdated("some data Updated"));
  }

  Future<void> deleteWalletByServerID(String walletID) async {
    final WalletModel? walletModel = await walletDao.findByServerID(walletID);
    if (walletModel != null) {
      await deleteWallet(wallet: walletModel);
    }
  }

  Future<void> deleteWallet({required WalletModel wallet}) async {
    await walletDao.deleteByServerID(wallet.walletID);
    final accounts = await accountDao.findAllByWalletID(wallet.walletID);
    bool isDeletingCurrentWallet = false;
    for (AccountModel accountModel in accounts) {
      await deleteWalletAccount(
        accountID: accountModel.accountID,
        addToStream: false,
      );
      if (selectedServerWalletAccountID == accountModel.accountID) {
        isDeletingCurrentWallet = true;
      }
    }
    if (selectedServerWalletID == wallet.walletID) {
      isDeletingCurrentWallet = true;
    }
    if (isDeletingCurrentWallet) {
      updateSelected(null, null);
    }

    /// update cache,
    walletsData = await _getFromDB();
    dataUpdateController.add(DataUpdated("some data Updated"));
  }

  Future<void> deleteWalletAccount({
    required String accountID,
    bool addToStream = true,
  }) async {
    await accountDao.deleteByServerID(accountID);
    await addressDao.deleteByServerAccountID(accountID);
    if (selectedServerWalletAccountID == accountID) {
      selectedServerWalletAccountID = "";
    }
    if (addToStream) {
      /// update cache,
      walletsData = await _getFromDB();
      dataUpdateController.add(DataUpdated("some data Updated"));
    }
  }

  void notifyUpdateEmailIntegration() {
    dataUpdateController.add(DataUpdated("email integration Updated"));
  }

  void updateSelected(String? serverWalletID, String? serverAccountID) {
    selectedServerWalletID = serverWalletID ?? "";
    selectedServerWalletAccountID = serverAccountID ?? "";
    selectedWalletUpdateController.add(SelectedWalletUpdated());
  }

  ///# DB operations

  /// process wallet data received from Api response, save it
  Future<int> _processApiWalletData(ApiWalletData apiWalletData) async {
    final bool showWalletRecovery =
        apiWalletData.walletSettings.showWalletRecovery ?? true;
    final String walletID = apiWalletData.wallet.id;
    return insertOrUpdateWallet(
      userID: userID,
      name: apiWalletData.wallet.name,
      encryptedMnemonic: apiWalletData.wallet.mnemonic!,
      passphrase: apiWalletData.wallet.hasPassphrase,
      imported: apiWalletData.wallet.isImported,
      priority: apiWalletData.wallet.priority,
      status: apiWalletData.wallet.status,
      type: apiWalletData.wallet.type,
      fingerprint: apiWalletData.wallet.fingerprint ?? "",
      publickey: apiWalletData.wallet.publicKey,
      walletID: walletID,
      showWalletRecovery: showWalletRecovery ? 1 : 0,
      migrationRequired: apiWalletData.wallet.migrationRequired ?? 0,
      legacy: apiWalletData.wallet.legacy ?? 0,
      initialize: true,
    );
  }

  /// process wallet account data received from Api response, save it
  Future<int> _processApiWalletAccountData(
    String walletID,
    ApiWalletAccount apiWalletAcct,
  ) async {
    return insertOrUpdateAccount(
      walletID,
      apiWalletAcct.label,
      apiWalletAcct.scriptType,
      apiWalletAcct.derivationPath,
      apiWalletAcct.id,
      apiWalletAcct.fiatCurrency,
      apiWalletAcct.poolSize,
      apiWalletAcct.priority,
      apiWalletAcct.lastUsedIndex,
      apiWalletAcct.stopGap,
      initialize: true,
    );
  }

  /// fetch BvE info for given account from backend, then update db and memory cache
  Future<void> syncEmailAddresses(
    String serverWalletID,
    String serverAccountID,
  ) async {
    try {
      final addresses = await walletClient.getWalletAccountAddresses(
        walletId: serverWalletID,
        walletAccountId: serverAccountID,
      );

      for (final address in addresses) {
        await addEmailAddressToWalletAccount(
          serverWalletID,
          serverAccountID,
          address,
        );
      }
      if (addresses.isEmpty) {
        await removeEmailAddressOnWalletAccount(serverAccountID);
      }
    } catch (e, stacktrace) {
      /// this should only happened before production api get deployed
      await Sentry.captureException(
        e,
        stackTrace: stacktrace,
      );
      logger.e(e.toString());
    }
  }

  /// send api request to remove BvE from backend
  Future<void> removeEmailAddressOnWalletAccount(
    String serverAccountID,
  ) async {
    await addressDao.deleteByServerAccountID(serverAccountID);
  }

  /// add email address to wallet account
  Future<void> addEmailAddressToWalletAccount(
    String serverWalletID,
    String serverAccountID,
    ApiEmailAddress address,
  ) async {
    AddressModel? addressModel = await addressDao.findByServerID(address.id);
    if (addressModel == null) {
      addressModel = AddressModel(
        id: -1,
        email: address.email,
        serverID: address.id,
        serverWalletID: serverWalletID,
        serverAccountID: serverAccountID,
      );
      await addressDao.insert(addressModel);
    } else {
      addressModel.email = address.email;
      addressModel.serverID = address.id;
      addressModel.serverWalletID = serverWalletID;
      addressModel.serverAccountID = serverAccountID;
      await addressDao.update(addressModel);
    }
  }

  Future<void> updateShowWalletRecovery(
      {required String walletID, required bool showWalletRecovery}) async {
    final WalletModel? wallet = await walletDao.findByServerID(walletID);
    if (wallet != null) {
      wallet.showWalletRecovery = showWalletRecovery ? 1 : 0;
      await walletDao.update(wallet);
      walletsData = await _getFromDB();
      dataUpdateController.add(DataUpdated("some data Updated"));
    }
  }

  Future<int> insertOrUpdateWallet({
    required String userID,
    required String name,
    required String encryptedMnemonic,
    required int passphrase,
    required int imported,
    required int priority,
    required int status,
    required int type,
    required String walletID,
    required String? publickey,
    required String fingerprint,
    required int showWalletRecovery,
    required int migrationRequired,
    required int legacy,
    bool initialize = false,
  }) async {
    int tmpID = -1;
    WalletModel? wallet = await walletDao.findByServerID(walletID);
    final DateTime now = DateTime.now();
    if (wallet == null) {
      final Uint8List uPubKey = publickey?.base64decode() ?? Uint8List(0);
      wallet = WalletModel(
        id: -1,
        userID: userID,
        name: name,
        passphrase: passphrase,
        publicKey: uPubKey,
        imported: imported,
        priority: priority,
        status: status,
        type: type,
        fingerprint: fingerprint,
        createTime: now.millisecondsSinceEpoch ~/ 1000,
        modifyTime: now.millisecondsSinceEpoch ~/ 1000,
        walletID: walletID,
        showWalletRecovery: showWalletRecovery,
        migrationRequired: migrationRequired,
        legacy: legacy,
      );
      tmpID = await walletDao.insert(wallet);
      wallet.id = tmpID;
    } else {
      tmpID = wallet.id;
      wallet.name = name;
      wallet.status = status;
      wallet.fingerprint = fingerprint;
      wallet.priority = priority;
      wallet.showWalletRecovery = showWalletRecovery;
      wallet.modifyTime = now.millisecondsSinceEpoch ~/ 1000;
      wallet.migrationRequired = migrationRequired;

      await walletDao.update(wallet);
    }

    if (encryptedMnemonic.isNotEmpty) {
      // save wallet mnemonic
      final mnemonic = WalletMnemonic(
        walletID: walletID,
        mnemonic: encryptedMnemonic,
      );
      await saveWalletMnemonics([mnemonic]);
    }

    if (!initialize) {
      /// update cache,
      walletsData = await _getFromDB();
      dataUpdateController.add(DataUpdated("some data Updated"));
    }
    return tmpID;
  }

  Future<int> insertOrUpdateAccount(
    String walletID,
    String labelEncrypted,
    int scriptType,
    String derivationPath,
    String accountID,
    FiatCurrency fiatCurrency,
    int poolSize,
    int priority,
    int lastUsedIndex,
    int? stopGap, {
    bool initialize = false,
    bool notify = true,
  }) async {
    /// stopgap default to 500 from server
    /// before db update, it will return 0 for all wallet accounts
    /// so we need to double check the value is greater than normal stopgap
    int finalStopgap = stopGap ?? 500;
    if (finalStopgap < 20) {
      finalStopgap = 500;
    }
    int tmpID = -1;
    AccountModel? account = await accountDao.findByServerID(accountID);
    final DateTime now = DateTime.now();
    if (account != null) {
      tmpID = account.id;
      account.walletID = walletID;
      account.label = labelEncrypted.base64decode();
      account.modifyTime = now.millisecondsSinceEpoch ~/ 1000;
      account.scriptType = scriptType;
      account.fiatCurrency = fiatCurrency.name.toUpperCase();
      account.priority = priority;
      account.poolSize = poolSize;
      account.lastUsedIndex = lastUsedIndex;
      account.stopGap = finalStopgap;
      await accountDao.update(account);
    } else {
      account = AccountModel(
        id: -1,
        walletID: walletID,
        derivationPath: derivationPath,
        label: labelEncrypted.base64decode(),
        scriptType: scriptType,
        fiatCurrency: fiatCurrency.name.toUpperCase(),
        createTime: now.millisecondsSinceEpoch ~/ 1000,
        modifyTime: now.millisecondsSinceEpoch ~/ 1000,
        accountID: accountID,
        priority: priority,
        poolSize: poolSize,
        lastUsedIndex: lastUsedIndex,
        stopGap: finalStopgap,
      );
      tmpID = await accountDao.insert(account);
    }

    if (!initialize) {
      walletsData = await _getFromDB();
      if (notify) {
        dataUpdateController.add(DataUpdated("some data Updated"));
      }
    }
    return tmpID;
  }

  Future<void> newBroadcastTransaction() async {
    newBroadcastTransactionController.add(NewBroadcastTransaction());
  }

  Future<WalletData?> getFirstPriorityWallet() async {
    final List<WalletData>? walletDataList = await getWallets();
    if (walletDataList != null && walletDataList.isNotEmpty) {
      return walletDataList.first;
    }
    return null;
  }

  Future<WalletData?> getWalletByServerWalletID(String walletID) async {
    final List<WalletData>? walletDataList = await getWallets();
    if (walletDataList != null) {
      for (WalletData walletData in walletDataList) {
        if (walletData.wallet.walletID == walletID) {
          return walletData;
        }
      }
    }
    return null;
  }

  Future<void> updateWalletAccountFiatCurrency(
    String walletID,
    String accountID,
    FiatCurrency newFiatCurrency,
  ) async {
    final walletAccount = await walletClient.updateWalletAccountFiatCurrency(
      walletId: walletID,
      walletAccountId: accountID,
      newFiatCurrency: newFiatCurrency,
    );
    final AccountModel? accountModel =
        await accountDao.findByServerID(accountID);
    if (accountModel != null) {
      final newFiatCurrency = walletAccount.fiatCurrency.name.toUpperCase();
      if (accountModel.fiatCurrency != newFiatCurrency) {
        accountModel.fiatCurrency = newFiatCurrency;
        await accountDao.update(accountModel);
      }
    }
  }

  @override
  Future<void> clear() async {
    walletsData = null;
    dataUpdateController.close();
    selectedWalletUpdateController.close();
    newBroadcastTransactionController.close();
  }

  Future<void> reset() async {
    walletsData = null;
    await _fetchFromServer();
  }

  @override
  Future<void> reload() async {}
}
