import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/helper/bdk/mnemonic.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/helper/secure_storage_helper.dart';
import 'package:wallet/helper/walletkey_helper.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/address.model.dart';
import 'package:wallet/models/contacts.model.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/rust/proton_api/contacts.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/rust/proton_api/wallet.dart';
import 'package:wallet/rust/proton_api/wallet_account.dart';
import 'package:wallet/scenes/debug/bdk.test.dart';
import 'package:wallet/rust/api/proton_api.dart' as proton_api;
import 'package:proton_crypto/proton_crypto.dart' as proton_crypto;

import 'bdk/helper.dart';

class WalletManager {
  static final BdkLibrary _lib = BdkLibrary();
  static bool isFetchingWallets = false;

  static Future<Wallet> loadWalletWithID(int walletID, int accountID) async {
    late Wallet wallet;
    WalletModel walletModel = await DBHelper.walletDao!.findById(walletID);
    String passphrase =
        await SecureStorageHelper.get(walletModel.serverWalletID);
    Mnemonic mnemonic = await Mnemonic.fromString(
        await WalletManager.getMnemonicWithID(walletID));
    final DerivationPath derivationPath = await DerivationPath.create(
        path: await getDerivationPathWithID(accountID));
    final aliceDescriptor = await _lib.createDerivedDescriptor(
        mnemonic, derivationPath,
        passphrase: passphrase);
    String derivationPathClean =
        derivationPath.toString().replaceAll("'", "_").replaceAll('/', '_');
    String dbName =
        "${walletModel.serverWalletID.replaceAll('-', '_').replaceAll('=', '_')}_${derivationPathClean}_${passphrase.isNotEmpty}";
    wallet = await _lib.restoreWallet(aliceDescriptor, databaseName: dbName);
    return wallet;
  }

  static Future<void> deleteWalletByServerWalletID(
      String serverWalletID) async {
    WalletModel? walletModel =
        await DBHelper.walletDao!.getWalletByServerWalletID(serverWalletID);
    if (walletModel != null) {
      await (deleteWallet(walletModel.id!));
    }
  }

  static Future<void> deleteWallet(int walletID) async {
    DBHelper.walletDao!.delete(walletID);
    DBHelper.accountDao!.deleteAccountsByWalletID(walletID);
  }

  static Future<int> getWalletIDByServerWalletID(String serverWalletID) async {
    WalletModel? walletModel =
        await DBHelper.walletDao!.getWalletByServerWalletID(serverWalletID);
    if (walletModel != null) {
      return walletModel.id!;
    }
    return -1;
  }

  static Future<void> addEmailAddressToWalletAccount(AccountModel accountModel, EmailAddress address) async {
    WalletModel walletModel = await DBHelper.walletDao!.findById(accountModel.walletID);
    AddressModel? addressModelExisted = await DBHelper.addressDao!.findByServerID(address.id);
    AddressModel addressModel = AddressModel(
      id: null,
      email: address.email,
      serverID: address.id,
      serverWalletID: walletModel.serverWalletID,
      serverAccountID: accountModel.serverAccountID,
    );
    if (addressModelExisted == null) {
      await DBHelper.addressDao!.insert(addressModel);
    }
  }

  static Future<void> removeEmailAddressInWalletAccount(EmailAddress address) async {
    await DBHelper.addressDao!.deleteByServerID(address.id);
  }

  static Future<void> insertOrUpdateAccount(int walletID, String labelEncrypted,
      int scriptType, String derivationPath, String serverAccountID) async {
    WalletModel walletModel = await DBHelper.walletDao!.findById(walletID);
    SecretKey? secretKey = await getWalletKey(walletModel.serverWalletID);
    if (walletID != -1 && secretKey != null) {
      DateTime now = DateTime.now();
      AccountModel? account =
          await DBHelper.accountDao!.findByServerAccountID(serverAccountID);
      if (account != null) {
        account.label = base64Decode(labelEncrypted);
        account.labelDecrypt =
            await WalletKeyHelper.decrypt(secretKey, labelEncrypted);
        account.modifyTime = now.millisecondsSinceEpoch ~/ 1000;
        account.scriptType = scriptType;
        DBHelper.accountDao!.update(account);
      } else {
        account = AccountModel(
            id: null,
            walletID: walletID,
            derivationPath: derivationPath,
            label: base64Decode(labelEncrypted),
            scriptType: scriptType,
            createTime: now.millisecondsSinceEpoch ~/ 1000,
            modifyTime: now.millisecondsSinceEpoch ~/ 1000,
            serverAccountID: serverAccountID);
        account.labelDecrypt =
            await WalletKeyHelper.decrypt(secretKey, labelEncrypted);
        DBHelper.accountDao!.insert(account);
      }
    }
  }

  static Future<int> insertOrUpdateWallet(
      {required int userID,
      required String name,
      required String encryptedMnemonic,
      required int passphrase,
      required int imported,
      required int priority,
      required int status,
      required int type,
      required String serverWalletID}) async {
    WalletModel? wallet =
        await DBHelper.walletDao!.getWalletByServerWalletID(serverWalletID);

    DateTime now = DateTime.now();
    if (wallet == null) {
      wallet = WalletModel(
          id: null,
          userID: userID,
          name: name,
          mnemonic: base64Decode(encryptedMnemonic),
          passphrase: passphrase,
          publicKey: Uint8List(0),
          imported: imported,
          priority: priority,
          status: status,
          type: type,
          fingerprint: "12345678",
          // TODO:: send correct fingerprint
          createTime: now.millisecondsSinceEpoch ~/ 1000,
          modifyTime: now.millisecondsSinceEpoch ~/ 1000,
          serverWalletID: serverWalletID);
      int walletID = await DBHelper.walletDao!.insert(wallet);
      return walletID;
    } else {
      wallet.name = name;
      wallet.status = status;
      await DBHelper.walletDao!.update(wallet);
      return wallet.id!;
    }
  }

  static Future<int> getAccountCount(int walletID) async {
    return DBHelper.accountDao!.getAccountCount(walletID);
  }

  static String getDerivationPath(
      {int purpose = 84, int coin = 1, int accountIndex = 0}) {
    return "m/$purpose'/$coin'/$accountIndex'/0";
  }

  static Future<bool> hasWallet() async {
    return await DBHelper.walletDao!.counts() > 0;
  }

  static Future<String> getDerivationPathWithID(int accountID) async {
    AccountModel accountModel = await DBHelper.accountDao!.findById(accountID);
    return accountModel.derivationPath;
  }

  static Future<String> getAccountLabelWithID(int accountID) async {
    AccountModel accountModel = await DBHelper.accountDao!.findById(accountID);
    return accountModel.labelDecrypt;
  }

  static Future<String> getNameWithID(int walletID) async {
    String name = "Default Name";
    if (walletID == 0) {
      name = "Default Name";
    } else {
      WalletModel walletRecord = await DBHelper.walletDao!.findById(walletID);
      name = walletRecord.name;
    }
    return name;
  }

  static Future<double> getWalletBalance(int walletID) async {
    double balance = 0.0;
    List accounts = await DBHelper.accountDao!.findAllByWalletID(walletID);
    for (AccountModel accountModel in accounts) {
      Wallet wallet =
          await WalletManager.loadWalletWithID(walletID, accountModel.id!);
      balance += (await wallet.getBalance()).total;
    }
    return balance;
  }

  static Future<SecretKey?> getWalletKey(String serverWalletID) async {
    String keyPath = "${SecureStorageHelper.walletKey}_$serverWalletID";
    SecretKey secretKey;
    String encodedEntropy = await SecureStorageHelper.get(keyPath);
    if (encodedEntropy.isEmpty) {
      return null;
    }
    secretKey =
        WalletKeyHelper.restoreSecretKeyFromEncodedEntropy(encodedEntropy);
    return secretKey;
  }

  static Future<void> setWalletKey(
      String serverWalletID, SecretKey secretKey) async {
    String keyPath = "${SecureStorageHelper.walletKey}_$serverWalletID";
    String encodedEntropy = await SecureStorageHelper.get(keyPath);
    if (encodedEntropy.isEmpty) {
      encodedEntropy = await WalletKeyHelper.getEncodedEntropy(secretKey);
      await SecureStorageHelper.set(keyPath, encodedEntropy);
    }
  }

  static Future<String> getMnemonicWithID(int walletID) async {
    WalletModel walletModel = await DBHelper.walletDao!.findById(walletID);
    SecretKey? secretKey = await getWalletKey(walletModel.serverWalletID);
    if (secretKey != null) {
      String mnemonic = await WalletKeyHelper.decrypt(
          secretKey, base64Encode(walletModel.mnemonic));
      return mnemonic;
    }
    return "";
  }

  static Future<int> getExchangeRate(FiatCurrency fiatCurrency,
      {int? time}) async {
    var exchangeRate = await proton_api.getExchangeRate(
        fiatCurrency: fiatCurrency, time: time);
    return exchangeRate.exchangeRate;
  }

  static Future<void> saveUserSetting(ApiUserSettings userSettings) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setInt(userSettingsHideEmptyUsedAddresses,
        userSettings.hideEmptyUsedAddresses);
    preferences.setInt(userSettingsTwoFactorAmountThreshold,
        userSettings.twoFactorAmountThreshold ?? 0);
    preferences.setInt(
        userSettingsShowWalletRecovery, userSettings.showWalletRecovery);
    preferences.setString(
        userSettingsFiatCurrency, userSettings.fiatCurrency.name.toUpperCase());
    preferences.setString(
        userSettingsBitcoinUnit, userSettings.bitcoinUnit.name.toUpperCase());
  }

  static int getCurrentTime() {
    return DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
  }

  static Future<void> initContacts() async {
    List<ProtonContactEmails> mails = await proton_api.getContacts();
    for (ProtonContactEmails mail in mails) {
      DBHelper.contactsDao!.insertOrUpdate(
          mail.id, mail.name, mail.email, mail.canonicalEmail, mail.isProton);
    }
  }

  static Future<List<ContactsModel>> getContacts() async {
    List contacts = await DBHelper.contactsDao!.findAll();
    return contacts.cast<ContactsModel>();
  }
  
  static Future<List<String>> getAccountAddressIDs(String serverAccountID) async {
    List<AddressModel> result = await DBHelper.addressDao!.findByServerAccountID(serverAccountID);
    return result.map((e) => e.serverID).toList();
  }

  static Future<void> deleteAddress(String addressID) async{
    await DBHelper.addressDao!.deleteByServerID(addressID);
  }

  static Future<void> fetchWalletsFromServer() async {
    if (isFetchingWallets) {
      return;
    }
    isFetchingWallets = true;
    // var authInfo = await fetchAuthInfo(userName: 'ProtonWallet');
    List<WalletData> wallets = await proton_api.getWallets();
    for (WalletData walletData in wallets.reversed) {
      WalletModel? walletModel = await DBHelper.walletDao!
          .getWalletByServerWalletID(walletData.wallet.id);
      String userPrivateKey = await SecureStorageHelper.get("userPrivateKey");
      // String userKeyID = await SecureStorageHelper.get("userKeyID");
      String userPassphrase = await SecureStorageHelper.get("userPassphrase");

      String encodedEncryptedEntropy = "";
      Uint8List entropy = Uint8List(0);
      try {
        encodedEncryptedEntropy = walletData.walletKey.walletKey;
        entropy = proton_crypto.decryptBinary(userPrivateKey, userPassphrase,
            base64Decode(encodedEncryptedEntropy));
      } catch (e) {
        logger.e(e.toString());
      }
      SecretKey secretKey =
          WalletKeyHelper.restoreSecretKeyFromEntropy(entropy);
      if (walletModel == null) {
        String serverWalletID = walletData.wallet.id;
        // int status = entropy.isNotEmpty
        //     ? WalletModel.statusActive
        //     : WalletModel.statusDisabled;
        int status = WalletModel.statusActive;
        int walletID = await WalletManager.insertOrUpdateWallet(
            userID: 0,
            name: walletData.wallet.name,
            encryptedMnemonic: walletData.wallet.mnemonic!,
            passphrase: walletData.wallet.hasPassphrase,
            imported: walletData.wallet.isImported,
            priority: walletData.wallet.priority,
            status: status,
            type: walletData.wallet.type,
            serverWalletID: serverWalletID);
        if (entropy.isNotEmpty) {
          await WalletManager.setWalletKey(serverWalletID,
              secretKey); // need to set key first, so that we can decrypt for walletAccount
          List<WalletAccount> walletAccounts = await proton_api
              .getWalletAccounts(walletId: walletData.wallet.id);
          if (walletAccounts.isNotEmpty) {
            for (WalletAccount walletAccount in walletAccounts) {
              await WalletManager.insertOrUpdateAccount(
                  walletID,
                  walletAccount.label,
                  walletAccount.scriptType,
                  "${walletAccount.derivationPath}/0",
                  walletAccount.id,);
              AccountModel accountModel = await DBHelper.accountDao!.findByServerAccountID(walletAccount.id);
              for (EmailAddress address in walletAccount.addresses) {
                WalletManager.addEmailAddressToWalletAccount(
                    accountModel, address);
              }
            }
          }
        }
      } else {
        if (entropy.isNotEmpty) {
          List<String> existingAccountIDs = [];
          List<WalletAccount> walletAccounts = await proton_api
              .getWalletAccounts(walletId: walletData.wallet.id);
          if (walletAccounts.isNotEmpty) {
            for (WalletAccount walletAccount in walletAccounts) {
              existingAccountIDs.add(walletAccount.id);
              await WalletManager.insertOrUpdateAccount(
                  walletModel.id!,
                  walletAccount.label,
                  walletAccount.scriptType,
                  "${walletAccount.derivationPath}/0",
                  walletAccount.id);
              AccountModel accountModel = await DBHelper.accountDao!.findByServerAccountID(walletAccount.id);
              for (EmailAddress address in walletAccount.addresses) {
                WalletManager.addEmailAddressToWalletAccount(
                    accountModel, address);
              }
            }
          }
          try {
            if (walletModel.accountCount != walletAccounts.length) {
              DBHelper.accountDao!.deleteAccountsNotInServers(
                  walletModel.id!, existingAccountIDs);
            }
          } catch (e) {
            e.toString();
          }
        } else {
          walletModel.status = WalletModel.statusDisabled;
          DBHelper.walletDao!.update(walletModel);
        }
      }
    }
    isFetchingWallets = false;
  }

  static Future<void> setLatestEventId(String latestEventId) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString("latestEventId", latestEventId);
  }

  static Future<String?> getLatestEventId() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString("latestEventId");
  }

  static Future<String?> lookupBitcoinAddress(String email) async{
    EmailIntegrationBitcoinAddress emailIntegrationBitcoinAddress =
    await proton_api.lookupBitcoinAddress(email: email);
    // TODO:: check signature!
    return emailIntegrationBitcoinAddress.bitcoinAddress;
  }
}
