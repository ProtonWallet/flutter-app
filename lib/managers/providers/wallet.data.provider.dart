import 'dart:typed_data';

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

class WalletData implements DataProvider {
  final WalletModel wallet;
  final List<AccountModel> accounts;
  WalletData({required this.wallet, required this.accounts});

  @override
  Future<void> clear() async {}
}

class WalletsDataProvider implements DataProvider {
  final WalletClient walletClient;
  //
  final WalletDao walletDao;
  final AccountDao accountDao;
  final AddressDao addressDao;
  final String userID = ""; // need to add userid.

  // need to monitor the db changes apply to this cache
  List<WalletData>? walletsData;

  WalletsDataProvider(
    this.walletDao,
    this.accountDao,
    this.addressDao,
    this.walletClient,
  );

  Future<List<WalletData>?> _getFromDB() async {
    List<WalletData> retWallet = [];
    // try to find it fro cache
    var wallets = (await walletDao.findAll())
        .cast<WalletModel>(); // TODO:: search by UserID
    // if found wallet cache.
    if (wallets.isNotEmpty) {
      for (WalletModel walleModel in wallets) {
        retWallet.add(WalletData(
            wallet: walleModel,
            accounts: (await accountDao.findAllByWalletID(walleModel.id!))
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
      int walletID = await _insertOrUpdateWallet(
          userID: 0, // this need a string userID
          name: apiWalletData.wallet.name,
          encryptedMnemonic: apiWalletData.wallet.mnemonic!,
          passphrase: apiWalletData.wallet.hasPassphrase,
          imported: apiWalletData.wallet.isImported,
          priority: apiWalletData.wallet.priority,
          status: apiWalletData.wallet.status,
          type: apiWalletData.wallet.type,
          fingerprint: apiWalletData.wallet.fingerprint ?? "",
          publickey: apiWalletData.wallet.publicKey,
          serverWalletID: serverWalletID);

      List<ApiWalletAccount> apiWalletAccts =
          await walletClient.getWalletAccounts(
              walletId: apiWalletData.wallet.id); // this id is serverWalletID
      for (ApiWalletAccount apiWalletAcct in apiWalletAccts) {
        String serverAccountID = apiWalletAcct.id;
        await _insertOrUpdateAccount(
          walletID, //use server wallet id
          apiWalletAcct.label,
          apiWalletAcct.scriptType,
          "${apiWalletAcct.derivationPath}/0",
          apiWalletAcct.id,
          apiWalletAcct.fiatCurrency,
        );
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

  Future<int> _insertOrUpdateAccount(
      int walletID,
      String labelEncrypted,
      int scriptType,
      String derivationPath,
      String serverAccountID,
      FiatCurrency fiatCurrency) async {
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
    return accountID;
  }

  Future<int> _insertOrUpdateWallet(
      {required int userID,
      required String name,
      required String encryptedMnemonic,
      required int passphrase,
      required int imported,
      required int priority,
      required int status,
      required int type,
      required String serverWalletID,
      required String? publickey,
      required String fingerprint}) async {
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
    return walletID;
  }

  Future<void> _addEmailAddressToWalletAccount(String serverWalletID,
      String serverAccountID, ApiEmailAddress address) async {
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

  @override
  Future<void> clear() async {}
}
