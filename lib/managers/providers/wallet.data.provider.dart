import 'dart:async';
import 'dart:typed_data';

import 'package:wallet/constants/coin_type.dart';
import 'package:wallet/constants/script_type.dart';
import 'package:wallet/helper/extension/strings.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
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

class WalletData {
  final WalletModel wallet;
  final List<AccountModel> accounts;

  WalletData({required this.wallet, required this.accounts});
}

class WalletsDataProvider extends DataProvider {
  StreamController<DataUpdated> dataUpdateController =
      StreamController<DataUpdated>.broadcast();

  StreamController<SelectedWalletUpdated> selectedWalletUpdateController =
      StreamController<SelectedWalletUpdated>.broadcast();

  final WalletClient walletClient;

  //
  final WalletDao walletDao;
  final AccountDao accountDao;
  final AddressDao addressDao;
  String selectedServerWalletID;
  String selectedServerWalletAccountID;

  /// current user id
  final String userID;

  // need to monitor the db changes apply to this cache
  List<WalletData>? walletsData;

  WalletsDataProvider(
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
    // try to find it fro cache
    final wallets = await walletDao.findAllByUserID(userID);
    // if found wallet cache.
    if (wallets.isNotEmpty) {
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

  Future<List<WalletData>?> getWallets() async {
    if (walletsData != null) {
      return walletsData;
    }

    walletsData = await _getFromDB();
    if (walletsData != null) {
      return walletsData;
    }

    // try to fetch from server:
    final List<ApiWalletData> apiWallets = await walletClient.getWallets();
    for (ApiWalletData apiWalletData in apiWallets.reversed) {
      // update and insert wallet
      final String serverWalletID = apiWalletData.wallet.id;
      await _processApiWalletData(apiWalletData);
      final List<ApiWalletAccount> apiWalletAccts =
          await walletClient.getWalletAccounts(
              walletId: apiWalletData.wallet.id); // this id is serverWalletID
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

    walletsData = await _getFromDB();
    if (walletsData != null) {
      return walletsData;
    }
    return null;
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
    // api calls if failed throw error
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
        walletId: walletID, req: request);

    walletAccount = await walletClient.updateWalletAccountFiatCurrency(
      walletId: walletID,
      walletAccountId: walletAccount.id,
      newFiatCurrency: fiatCurrency,
    );
    // TODO(fix): fix me
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
    // TODO(fix): improve performance here
    walletsData = await _getFromDB();
    dataUpdateController.add(DataUpdated("some data Updated"));
  }

  Future<void> updateWalletAccount({required AccountModel accountModel}) async {
    await accountDao.update(accountModel);

    /// update cache,
    // TODO(fix): improve performance here
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
      await deleteWalletAccount(accountModel: accountModel, addToStream: false);
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
    // TODO(fix): improve performance here
    walletsData = await _getFromDB();
    dataUpdateController.add(DataUpdated("some data Updated"));
  }

  Future<void> deleteWalletAccountByServerID(String accountID) async {
    final AccountModel? accountModel =
        await accountDao.findByServerID(accountID);
    if (accountModel != null) {
      await deleteWalletAccount(accountModel: accountModel);
    } else {
      logger.e("deleteWalletAccountByServerID: Account not found: $accountID");
    }
  }

  Future<void> deleteWalletAccount({
    required AccountModel accountModel,
    bool addToStream = true,
  }) async {
    await accountDao.deleteByServerID(accountModel.accountID);
    await addressDao.deleteByServerAccountID(accountModel.accountID);
    if (selectedServerWalletAccountID == accountModel.accountID) {
      selectedServerWalletAccountID = "";
    }
    if (addToStream) {
      /// update cache,
      // TODO(fix): improve performance here
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
      initialize: true,
    );
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
        mnemonic: encryptedMnemonic.base64decode(),
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
      await walletDao.update(wallet);
    }

    if (!initialize) {
      /// update cache,
      // TODO(fix): improve performance here
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
    int lastUsedIndex, {
    bool initialize = false,
    bool notify = true,
  }) async {
    int tmpID = -1;
    AccountModel? account = await accountDao.findByServerID(accountID);
    final DateTime now = DateTime.now();
    if (account != null) {
      tmpID = account.id;
      account.walletID = walletID;
      account.modifyTime = now.millisecondsSinceEpoch ~/ 1000;
      account.scriptType = scriptType;
      account.fiatCurrency = fiatCurrency.name.toUpperCase();
      account.priority = priority;
      account.poolSize = poolSize;
      account.lastUsedIndex = lastUsedIndex;
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

  @override
  Future<void> clear() async {
    dataUpdateController.close();
  }
}
