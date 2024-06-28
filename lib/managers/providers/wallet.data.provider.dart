import 'dart:async';
import 'dart:typed_data';

import 'package:wallet/constants/coin_type.dart';
import 'package:wallet/constants/script_type.dart';
import 'package:wallet/helper/extension/strings.dart';
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
  final String userID = ""; // need to add userid.
  String selectedServerWalletID;
  String selectedServerWalletAccountID;

  // need to monitor the db changes apply to this cache
  List<WalletData>? walletsData;

  WalletsDataProvider(
    this.walletDao,
    this.accountDao,
    this.addressDao,
    this.walletClient,
    this.selectedServerWalletID,
    this.selectedServerWalletAccountID,
  );

  WalletData? getCurrentWalletData() {
    for (WalletData walletData in walletsData ?? []) {
      if (walletData.wallet.serverWalletID == selectedServerWalletID) {
        return walletData;
      }
    }
    return null;
  }

  Future<List<WalletData>?> _getFromDB() async {
    List<WalletData> retWallet = [];
    // try to find it fro cache
    var wallets = (await walletDao.findAll())
        .cast<WalletModel>(); // TODO:: search by UserID
    // if found wallet cache.
    if (wallets.isNotEmpty) {
      for (WalletModel walletModel in wallets) {
        retWallet.add(WalletData(
            wallet: walletModel,
            accounts: (await accountDao.findAllByWalletID(walletModel.id!))
                .cast<AccountModel>()));
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
    List<ApiWalletData> apiWallets = await walletClient.getWallets();
    for (ApiWalletData apiWalletData in apiWallets.reversed) {
      // update and insert wallet
      String serverWalletID = apiWalletData.wallet.id;

      int walletID = await _processApiWalletData(apiWalletData);

      List<ApiWalletAccount> apiWalletAccts =
          await walletClient.getWalletAccounts(
              walletId: apiWalletData.wallet.id); // this id is serverWalletID
      for (ApiWalletAccount apiWalletAcct in apiWalletAccts) {
        String serverAccountID = apiWalletAcct.id;
        await _processApiWalletAccountData(walletID, apiWalletAcct);

        for (ApiEmailAddress address in apiWalletAcct.addresses) {
          _addEmailAddressToWalletAccount(
              serverWalletID, serverAccountID, address);
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
    var wallets = await getWallets();
    if (wallets != null) {
      for (WalletData walletData in wallets) {
        if (walletData.wallet.serverWalletID == walletID) {
          return walletData;
        }
      }
    }
    return null;
  }

  Future<ApiWalletData> createWallet(CreateWalletReq request) async {
    // api calls if failed throw error
    ApiWalletData walletData =
        await walletClient.createWallet(walletReq: request);

    await _processApiWalletData(walletData);

    /// update cache
    walletsData = await _getFromDB();

    return walletData;
  }

  Future<String> getNewDerivationPath(
    int walletID,
    ScriptTypeInfo scriptType,
    CoinType coinType, {
    int internal = 0,
  }) async {
    int accountIndex = 0;
    while (true) {
      String newDerivationPath =
          "m/${scriptType.bipVersion}'/${coinType.type}'/$accountIndex'";
      var result = await accountDao.findByDerivationPath(
          walletID, "$newDerivationPath/$internal");
      if (result == null) {
        return newDerivationPath;
      }
      accountIndex++;
    }
  }

  Future<int> getNewDerivationAccountIndex(
      String walletID, ScriptTypeInfo scriptType, CoinType coinType) async {
    String derivationPath = "";
    int newAccountIndex = 0;
    var wallet = await getWallet(walletID);
    if (wallet == null) {
      throw Exception("Wallet not found");
    }
    while (true) {
      derivationPath = formatDerivationPath(
        scriptType,
        coinType,
        newAccountIndex,
      );
      if (_isDerivationPathExist(wallet.accounts, derivationPath)) {
        newAccountIndex++;
      } else {
        return newAccountIndex;
      }
    }
  }

  Future<String> getNewDerivationPathBy(
      String walletID, ScriptTypeInfo scriptType, CoinType coinType,
      {int? accountIndex}) async {
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
      ScriptTypeInfo scriptType, CoinType coinType, int accountIndex) {
    String derivationPath =
        "m/${scriptType.bipVersion}'/${coinType.type}'/$accountIndex'";
    return derivationPath;
  }

  bool _isDerivationPathExist(
    List<AccountModel> accounts,
    String derivationPath,
  ) {
    for (var element in accounts) {
      var left = element.derivationPath;
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
    // TODO:: fix me
    var wallet = await getWallet(walletID);
    _processApiWalletAccountData(wallet!.wallet.id!, walletAccount);

    /// update cache
    walletsData = await _getFromDB();
    dataUpdateController.add(DataUpdated("some data Updated"));
    return walletAccount;
  }

  Future<void> updateWallet({required WalletModel wallet}) async {
    await walletDao.update(wallet);

    /// update cache,
    /// TODO:: improve performance here
    walletsData = await _getFromDB();
    dataUpdateController.add(DataUpdated("some data Updated"));
  }

  Future<void> updateWalletAccount({required AccountModel accountModel}) async {
    await accountDao.update(accountModel);

    /// update cache,
    /// TODO:: improve performance here
    walletsData = await _getFromDB();
    dataUpdateController.add(DataUpdated("some data Updated"));
  }

  Future<void> deleteWalletByServerID(String serverWalletID) async {
    WalletModel? walletModel =
        await walletDao.getWalletByServerWalletID(serverWalletID);
    if (walletModel != null) {
      await deleteWallet(wallet: walletModel);
    }
  }

  Future<void> deleteWallet({required WalletModel wallet}) async {
    await walletDao.deleteByServerID(wallet.serverWalletID);
    List<AccountModel> accounts =
        (await accountDao.findAllByWalletID(wallet.id ?? 0))
            .cast<AccountModel>();
    for (AccountModel accountModel in accounts) {
      await deleteWalletAccount(accountModel: accountModel, addToStream: false);
    }
    if (selectedServerWalletID == wallet.serverWalletID) {
      selectedServerWalletID = "";
    }

    /// update cache,
    /// TODO:: improve performance here
    walletsData = await _getFromDB();
    dataUpdateController.add(DataUpdated("some data Updated"));
  }

  Future<void> deleteWalletAccountByServerID(String serverAccountID) async {
    AccountModel? accountModel =
        await accountDao.findByServerAccountID(serverAccountID);
    if (accountModel != null) {
      await deleteWalletAccount(accountModel: accountModel);
    }
  }

  Future<void> deleteWalletAccount(
      {required AccountModel accountModel, bool addToStream = true}) async {
    await accountDao.deleteByServerAccountID(accountModel.serverAccountID);
    await addressDao.deleteByServerAccountID(accountModel.serverAccountID);
    if (selectedServerWalletAccountID == accountModel.serverAccountID) {
      selectedServerWalletAccountID = "";
    }
    if (addToStream) {
      /// update cache,
      /// TODO:: improve performance here
      walletsData = await _getFromDB();
      dataUpdateController.add(DataUpdated("some data Updated"));
    }
  }

  void updateSelected(String? serverWalletID, String? serverAccountID) {
    selectedServerWalletID = serverWalletID ?? "";
    selectedServerWalletAccountID = serverAccountID ?? "";
    selectedWalletUpdateController.add(SelectedWalletUpdated());
  }

  ///# DB operations

  /// process wallet data received from Api response, save it
  Future<int> _processApiWalletData(ApiWalletData apiWalletData) async {
    String serverWalletID = apiWalletData.wallet.id;
    return await insertOrUpdateWallet(
      userID: 0,
      // this need a string userID
      name: apiWalletData.wallet.name,
      encryptedMnemonic: apiWalletData.wallet.mnemonic!,
      passphrase: apiWalletData.wallet.hasPassphrase,
      imported: apiWalletData.wallet.isImported,
      priority: apiWalletData.wallet.priority,
      status: apiWalletData.wallet.status,
      type: apiWalletData.wallet.type,
      fingerprint: apiWalletData.wallet.fingerprint ?? "",
      publickey: apiWalletData.wallet.publicKey,
      serverWalletID: serverWalletID,
      initialize: true,
    );
  }

  /// process wallet account data received from Api response, save it
  Future<int> _processApiWalletAccountData(
    int walletID,
    ApiWalletAccount apiWalletAcct,
  ) async {
    return await insertOrUpdateAccount(
      walletID, //use server wallet id
      apiWalletAcct.label,
      apiWalletAcct.scriptType,
      apiWalletAcct.derivationPath,
      // "${apiWalletAcct.derivationPath}/0",
      apiWalletAcct.id,
      apiWalletAcct.fiatCurrency,
      initialize: true,
    );
  }

  /// add email address to wallet account
  Future<void> _addEmailAddressToWalletAccount(
    String serverWalletID,
    String serverAccountID,
    ApiEmailAddress address,
  ) async {
    AddressModel? addressModel = await addressDao.findByServerID(address.id);
    if (addressModel == null) {
      addressModel = AddressModel(
        id: null,
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
    required int userID,
    required String name,
    required String encryptedMnemonic,
    required int passphrase,
    required int imported,
    required int priority,
    required int status,
    required int type,
    required String serverWalletID,
    required String? publickey,
    required String fingerprint,
    bool initialize = false,
  }) async {
    int walletID = -1;
    WalletModel? wallet =
        await walletDao.getWalletByServerWalletID(serverWalletID);
    DateTime now = DateTime.now();
    if (wallet == null) {
      Uint8List uPubKey = publickey?.base64decode() ?? Uint8List(0);
      wallet = WalletModel(
          id: null,
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
          serverWalletID: serverWalletID);
      walletID = await walletDao.insert(wallet);
      wallet.id = walletID;
    } else {
      walletID = wallet.id!;
      wallet.name = name;
      wallet.status = status;
      await walletDao.update(wallet);
    }

    if (initialize == false) {
      /// update cache,
      /// TODO:: improve performance here
      walletsData = await _getFromDB();
      dataUpdateController.add(DataUpdated("some data Updated"));
    }
    return walletID;
  }

  Future<int> insertOrUpdateAccount(
    int walletID,
    String labelEncrypted,
    int scriptType,
    String derivationPath,
    String serverAccountID,
    FiatCurrency fiatCurrency, {
    bool initialize = false,
  }) async {
    int accountID = -1;
    AccountModel? account =
        await accountDao.findByServerAccountID(serverAccountID);
    DateTime now = DateTime.now();
    if (account != null) {
      accountID = account.id ?? -1;
      account.walletID = walletID;
      account.modifyTime = now.millisecondsSinceEpoch ~/ 1000;
      account.scriptType = scriptType;
      account.fiatCurrency = fiatCurrency.name.toUpperCase();
      await accountDao.update(account);
    } else {
      account = AccountModel(
          id: null,
          walletID: walletID,
          derivationPath: derivationPath,
          label: labelEncrypted.base64decode(),
          scriptType: scriptType,
          fiatCurrency: fiatCurrency.name.toUpperCase(),
          createTime: now.millisecondsSinceEpoch ~/ 1000,
          modifyTime: now.millisecondsSinceEpoch ~/ 1000,
          serverAccountID: serverAccountID);
      accountID = await accountDao.insert(account);
    }

    if (initialize == false) {
      /// update cache,
      /// TODO:: improve performance here
      walletsData = await _getFromDB();
      dataUpdateController.add(DataUpdated("some data Updated"));
    }
    return accountID;
  }

  Future<WalletData?> getFirstPriorityWallet() async {
    List<WalletData>? walletDataList = await getWallets();
    if (walletDataList != null && walletDataList.isNotEmpty) {
      return walletDataList.first;
    }
    return null;
  }

  Future<WalletData?> getWalletByServerWalletID(String serverWalletID) async {
    List<WalletData>? walletDataList = await getWallets();
    if (walletDataList != null) {
      for (WalletData walletData in walletDataList) {
        if (walletData.wallet.serverWalletID == serverWalletID) {
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
