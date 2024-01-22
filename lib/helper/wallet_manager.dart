import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart';
import 'package:wallet/helper/bdk/mnemonic.dart';
import 'package:wallet/helper/dbhelper.dart';
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
    dbName +=
        "_${derivationPath.toString().replaceAll("'", "_").replaceAll('/', '_')}";
    wallet = await _lib.restoreWallet(aliceDescriptor, databaseName: dbName);
    return wallet;
  }

  static Future<void> importAccount(
      int walletID, String label, int scriptType, String derivationPath) async {
    if (walletID != -1) {
      DateTime now = DateTime.now();
      AccountModel account = AccountModel(
          id: null,
          walletID: walletID,
          derivationPath: derivationPath,
          label: utf8.encode(await encrypt(label)),
          scriptType: scriptType,
          createTime: now.millisecondsSinceEpoch ~/ 1000,
          modifyTime: now.millisecondsSinceEpoch ~/ 1000);
      DBHelper.accountDao!.insert(account);
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
    if (accountID == 0) {
      return "m/84'/1'/0'/0";
    }
    AccountModel accountModel = await DBHelper.accountDao!.findById(accountID);
    return accountModel.derivationPath;
  }

  static Future<String> getAccountLabelWithID(int accountID) async {
    if (accountID == 0) {
      return "Default Account";
    }
    AccountModel accountModel = await DBHelper.accountDao!.findById(accountID);
    return accountModel.labelDecrypt;
  }

  static Future<String> getLocalDBNameWithID(int walletID) async {
    String dbName = "";
    if (walletID == 0) {
      dbName = "test_database";
    } else {
      WalletModel walletRecord =
          await await DBHelper.walletDao!.findById(walletID);
      dbName = walletRecord.localDBName;
    }
    return dbName;
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

  static Future<bool> mnemonicExists(String mnemonic) async {
    bool exists = false;
    await DBHelper.walletDao!.findAll().then((results) async {
      for (WalletModel walletModel in results) {
        if (mnemonic == await getMnemonicWithID(walletModel.id!)) {
          exists = true;
          break;
        }
      }
    });
    return exists;
  }

  static Future<String> getMnemonicWithID(int walletID,
      {String passphrase = ""}) async {
    // TODO:: add passphrase
    if (walletID == 0) {
      return 'certain sense kiss guide crumble hint transfer crime much stereo warm coral';
    } else {
      WalletModel walletRecord = await DBHelper.walletDao!.findById(walletID);
      String mnemonic = await decrypt(utf8.decode(walletRecord.mnemonic),
          passphrase_: passphrase);
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
