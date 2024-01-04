import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/models/wallet.dao.impl.dart';

import '../constants/constants.dart';
import '../models/account.dao.impl.dart';
import '../models/account.model.dart';
import '../models/wallet.model.dart';
import '../scenes/debug/bdk.test.dart';
import 'bdk/helper.dart';

class WalletManager {
  static final BdkLibrary _lib = BdkLibrary();

  static Future<Wallet> loadWallet() async {
    return loadWalletWithID(0, 0);
  }

  static Future<Wallet> loadWalletWithID(int walletID, int accountID) async {
    late Wallet wallet;
    Mnemonic mnemonic = await Mnemonic.fromString(
        await WalletManager.getMnemonicWithID(walletID));
    final DerivationPath derivationPath = await DerivationPath.create(
        path: await getDerivationPathWithID(accountID));
    final aliceDescriptor =
        await _lib.createDerivedDescriptor(mnemonic, derivationPath);
    String dbName = await getLocalDBNameWithID(walletID);
    dbName += "_" +
        derivationPath.toString().replaceAll("'", "_").replaceAll('/', '_');
    wallet = await _lib.restoreWallet(aliceDescriptor, databaseName: dbName);
    return wallet;
  }

  static Future<void> importAccount(
      int walletID, String label, int scriptType, String derivationPath) async {
    if (walletID != -1) {
      Database db = await DBHelper.database;
      DateTime now = DateTime.now();
      AccountModel account = AccountModel(
          id: null,
          walletID: walletID,
          derivationPath: derivationPath,
          label: utf8.encode(await encrypt(label)),
          scriptType: scriptType,
          createTime: now.millisecondsSinceEpoch ~/ 1000,
          modifyTime: now.millisecondsSinceEpoch ~/ 1000);
      AccountDaoImpl accountDaoImpl = AccountDaoImpl(db);
      accountDaoImpl.insert(account);
    }
  }

  static Future<int> getAccountCount(int walletID) async {
    Database db = await DBHelper.database;
    AccountDaoImpl accountDaoImpl = AccountDaoImpl(db);
    return accountDaoImpl.getAccountCount(walletID);
  }

  static String getDerivationPath(
      {int purpose = 84, int coin = 1, int accountIndex = 0}) {
    return "m/$purpose'/$coin'/$accountIndex'/0";
  }

  static Future<bool> hasAccount() async {
    Database db = await DBHelper.database;
    WalletDaoImpl walletDaoImpl = WalletDaoImpl(db);
    return await walletDaoImpl.counts() > 0;
  }

  static Future<String> getDerivationPathWithID(int accountID) async {
    if (accountID == 0) {
      return "m/84'/1'/0'/0";
    }
    Database db = await DBHelper.database;
    AccountDaoImpl accountDaoImpl = AccountDaoImpl(db);
    AccountModel accountModel = await accountDaoImpl.findById(accountID);
    return accountModel.derivationPath;
  }

  static Future<String> getAccountLabelWithID(int accountID) async {
    if (accountID == 0) {
      return "Default Account";
    }
    Database db = await DBHelper.database;
    AccountDaoImpl accountDaoImpl = AccountDaoImpl(db);
    AccountModel accountModel = await accountDaoImpl.findById(accountID);
    return accountModel.labelDecrypt;
  }

  static Future<String> getLocalDBNameWithID(int walletID) async {
    WalletDaoImpl walletDaoImpl = WalletDaoImpl(await DBHelper.database);
    String dbName = "";
    if (walletID == 0) {
      dbName = "test_database";
    } else {
      WalletModel walletRecord = await walletDaoImpl.findById(walletID);
      dbName = walletRecord.localDBName;
    }
    return dbName;
  }

  static Future<String> getNameWithID(int walletID) async {
    WalletDaoImpl walletDaoImpl = WalletDaoImpl(await DBHelper.database);
    String name = "Default Name";
    if (walletID == 0) {
      name = "Default Name";
    } else {
      WalletModel walletRecord = await walletDaoImpl.findById(walletID);
      name = walletRecord.name;
    }
    return name;
  }

  static Future<double> getWalletBalance(int walletID) async {
    double balance = 0.0;
    Database db = await DBHelper.database;
    AccountDaoImpl accountDaoImpl = AccountDaoImpl(db);
    List accounts = await accountDaoImpl.findAllByWalletID(walletID);
    for (AccountModel accountModel in accounts) {
      Wallet wallet =
          await WalletManager.loadWalletWithID(walletID, accountModel.id!);
      balance += (await wallet.getBalance()).total;
    }
    return balance;
  }

  static Future<String> getMnemonicWithID(int walletID) async {
    WalletDaoImpl walletDaoImpl = WalletDaoImpl(await DBHelper.database);
    if (walletID == 0) {
      return 'certain sense kiss guide crumble hint transfer crime much stereo warm coral';
    } else {
      WalletModel walletRecord = await walletDaoImpl.findById(walletID);
      String passphrase = "";
      if (walletRecord.passphrase == 1){
        passphrase = "123456";
      }
      String mnemonic = await decrypt(utf8.decode(walletRecord.mnemonic), passphrase_: passphrase);
      return mnemonic;
    }
  }

  static Future<String> encrypt(String plaintext,
      {String passphrase_ = ""}) async {
    Uint8List plaintext0 = utf8.encode(plaintext);
    List<int> iv = AesGcm.with256bits().newNonce();
    Uint8List passphrase =
        utf8.encode(md5.convert(utf8.encode(passphrase_)).toString());
    SecretKey secretKey = SecretKey(passphrase);

    SecretBox secretBox = await AesGcm.with256bits()
        .encrypt(plaintext0, nonce: iv, secretKey: secretKey);
    String encryptText = base64.encode(
        secretBox.concatenation()); // Base64 encoding of: IV | ciphertext | MAC
    return encryptText;
  }

  static Future<String> decrypt(String encryptText,
      {String passphrase_ = ""}) async {
    Uint8List encryptText0 = base64.decode(encryptText);
    Uint8List iv = encryptText0.sublist(0, 12);
    Uint8List ciphertext = encryptText0.sublist(12, encryptText0.length - 16);
    Uint8List mac = encryptText0.sublist(encryptText0.length - 16);

    Uint8List passphrase =
        utf8.encode(md5.convert(utf8.encode(passphrase_)).toString());
    SecretKey secretKey = SecretKey(passphrase);

    SecretBox secretBox = SecretBox(ciphertext, nonce: iv, mac: Mac(mac));

    List<int> decrypted =
        await AesGcm.with256bits().decrypt(secretBox, secretKey: secretKey);
    String plaintext = utf8.decode(decrypted);
    return plaintext;
  }
}
