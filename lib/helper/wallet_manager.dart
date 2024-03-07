import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:wallet/helper/bdk/mnemonic.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/secure_storage_helper.dart';
import 'package:wallet/helper/walletkey_helper.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/scenes/debug/bdk.test.dart';
import 'package:wallet/rust/api/proton_api.dart' as proton_api;

import 'bdk/helper.dart';

class WalletManager {
  static final BdkLibrary _lib = BdkLibrary();

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
        "${walletModel.serverWalletID}_${derivationPathClean}_${passphrase.isNotEmpty}";
    wallet = await _lib.restoreWallet(aliceDescriptor, databaseName: dbName);
    return wallet;
  }

  static Future<void> deleteWallet(int walletID) async {
    DBHelper.walletDao!.delete(walletID);
    DBHelper.accountDao!.deleteAccountsByWalletID(walletID);
  }

  static Future<void> importAccount(int walletID, String label, int scriptType,
      String derivationPath, String serverAccountID) async {
    SecretKey? secretKey = await getWalletKey(walletID);
    if (walletID != -1 && secretKey != null) {
      DateTime now = DateTime.now();
      AccountModel? account =
          await DBHelper.accountDao!.findByServerAccountID(serverAccountID);
      if (account != null) {
        account.label =
            base64Decode(await WalletKeyHelper.encrypt(secretKey, label));
        account.labelDecrypt = label;
        account.modifyTime = now.millisecondsSinceEpoch ~/ 1000;
        account.scriptType = scriptType;
        DBHelper.accountDao!.update(account);
      } else {
        account = AccountModel(
            id: null,
            walletID: walletID,
            derivationPath: derivationPath,
            label:
                base64Decode(await WalletKeyHelper.encrypt(secretKey, label)),
            scriptType: scriptType,
            createTime: now.millisecondsSinceEpoch ~/ 1000,
            modifyTime: now.millisecondsSinceEpoch ~/ 1000,
            serverAccountID: serverAccountID);
        DBHelper.accountDao!.insert(account);
      }
    }
  }

  static Future<int> getAccountCount(int walletID) async {
    return DBHelper.accountDao!.getAccountCount(walletID);
  }

  static String getDerivationPath(
      {int purpose = 84, int coin = 1, int accountIndex = 0}) {
    return "m/$purpose'/$coin'/$accountIndex'/0";
  }

  static Future<bool> hasAccount() async {
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

  static Future<SecretKey?> getWalletKey(int walletID) async {
    WalletModel walletModel = await DBHelper.walletDao!.findById(walletID);
    String keyPath =
        "${SecureStorageHelper.walletKey}_${walletModel.serverWalletID}";
    SecretKey secretKey;
    String encodedEntropy = await SecureStorageHelper.get(keyPath);
    if (encodedEntropy.isEmpty) {
      return null;
    }
    secretKey =
        WalletKeyHelper.restoreSecretKeyFromEncodedEntropy(encodedEntropy);
    return secretKey;
  }

  static Future<void> setWalletKey(int walletID, SecretKey secretKey) async {
    WalletModel walletModel = await DBHelper.walletDao!.findById(walletID);
    String keyPath =
        "${SecureStorageHelper.walletKey}_${walletModel.serverWalletID}";
    String encodedEntropy = await SecureStorageHelper.get(keyPath);
    if (encodedEntropy.isEmpty) {
      encodedEntropy = await WalletKeyHelper.getEncodedEntropy(secretKey);
      SecureStorageHelper.set(keyPath, encodedEntropy);
    }
  }

  static Future<String> getMnemonicWithID(int walletID) async {
    WalletModel walletRecord = await DBHelper.walletDao!.findById(walletID);
    SecretKey? secretKey = await getWalletKey(walletID);
    if (secretKey != null) {
      String mnemonic = await WalletKeyHelper.decrypt(
          secretKey, base64Encode(walletRecord.mnemonic));
      return mnemonic;
    }
    return "";
  }

  static Future<int> getExchangeRate(
      CommonBitcoinUnit bitcoinUnit, ApiFiatCurrency fiatCurrency) async {
    var exchangeRate = await proton_api.getExchangeRate(
        bitcoinUnit: bitcoinUnit, fiatCurrency: fiatCurrency);
    return exchangeRate.exchangeRate;
  }
}
