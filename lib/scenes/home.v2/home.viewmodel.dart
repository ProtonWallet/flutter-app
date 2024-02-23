import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';
import 'package:wallet/helper/bdk/helper.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/logger.dart';
import 'package:proton_crypto/proton_crypto.dart' as proton_crypto;
import 'package:wallet/helper/secure_storage_helper.dart';
import 'package:wallet/helper/walletkey_helper.dart';
import 'package:wallet/rust/api/proton_api.dart' as proton_api;
import 'package:wallet/rust/proton_api/wallet.dart';
import 'package:wallet/rust/proton_api/wallet_account.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/debug/bdk.test.dart';
import 'package:wallet/helper/wallet_manager.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';

abstract class HomeViewModel extends ViewModel {
  HomeViewModel(super.coordinator);

  int selectedPage = 0;
  int selectedWalletID = 0;
  double totalBalance = 0.0;
  String selectedAccountDerivationPath = WalletManager.getDerivationPath();

  void updateSelected(int index);

  List userWallets = [];
  bool hasWallet = true;
  bool hasMailIntegration = false;
  bool isFetching = false;

  void checkNewWallet();

  void updateWallets();

  void updateHasMailIntegration(bool later);

  void setOnBoard(BuildContext context);

  void fetchWallets();

  void setSelectedWallet(int walletID);

  String gopenpgpTest();

  int unconfirmed = 0;
  int totalAccount = 0;
  int confirmed = 0;

  @override
  bool get keepAlive => true;
}

class HomeViewModelImpl extends HomeViewModel {
  HomeViewModelImpl(super.coordinator);

  final datasourceChangedStreamController =
      StreamController<HomeViewModel>.broadcast();
  final selectedSectionChangedController = StreamController<int>.broadcast();

  final BdkLibrary _lib = BdkLibrary();
  Blockchain? blockchain;

  @override
  void dispose() {
    datasourceChangedStreamController.close();
    selectedSectionChangedController.close();
    //clean up wallet ....
  }

  @override
  Future<void> loadData() async {
    await proton_api.initApiService(
        userName: 'ProtonWallet', password: '11111111');
    blockchain ??= await _lib.initializeBlockchain(false);
    hasWallet = await WalletManager.hasAccount();
    datasourceChangedStreamController.sink.add(this);
    checkNewWallet();
    fetchWallets();
  }

  @override
  Future<void> checkNewWallet() async {
    int totalAccount_ = 0;
    await DBHelper.walletDao!.findAll().then((results) async {
      for (WalletModel walletModel in results) {
        walletModel.accountCount =
            await DBHelper.accountDao!.getAccountCount(walletModel.id!);
        totalAccount_ += walletModel.accountCount;
      }
      if (results.length != userWallets.length ||
          totalAccount != totalAccount_) {
        userWallets = results;
        totalAccount = totalAccount_;
      }
    });
    datasourceChangedStreamController.sink.add(this);
    updateWallets();
    Future.delayed(const Duration(milliseconds: 1000), () {
      checkNewWallet();
    });
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  @override
  void updateSelected(int index) {
    selectedPage = index;
    datasourceChangedStreamController.sink.add(this);
  }

  @override
  void updateHasMailIntegration(bool later) {
    hasMailIntegration = later;
    datasourceChangedStreamController.sink.add(this);
  }

  @override
  void setOnBoard(BuildContext context) {
    hasWallet = true;
    Future.delayed(const Duration(milliseconds: 100), () {
      coordinator.move(ViewIdentifiers.setupOnboard, context);
      datasourceChangedStreamController.sink.add(this);
    });
  }

  @override
  Future<void> updateWallets() async {
    if (isFetching) {
      return;
    }
    double totalBalance = 0.0;
    for (WalletModel walletModel in userWallets) {
      walletModel.balance =
          await WalletManager.getWalletBalance(walletModel.id!);
      totalBalance += walletModel.balance;
    }
    this.totalBalance = totalBalance;
    datasourceChangedStreamController.sink.add(this);
  }

  @override
  String gopenpgpTest() {
    // var sum = native_add.sum(1, 2);

    // logger.i('sum: $sum');

    String userPrivateKey = '''-----BEGIN PGP PRIVATE KEY BLOCK-----

xYYEZbIlGRYJKwYBBAHaRw8BAQdAdgwLi+IULWqS++gRe2dQ3MizLRArYnKS
ObqnhO8lmx7+CQMIylIrAYAm2CTgEg659zXzpjkiKKZy7K/JuNkR2C/vTB5K
CpwWcEFVolPUBGnogZ2FXFbsaT+X4bhtjh3BvzCcZE98w8JCtDmuuO6RVSBV
6c0Zd2lsbCA8d2lsbC5oc3VAcHJvdG9uLmNoPsKMBBAWCgA+BYJlsiUZBAsJ
BwgJkPNpnCHsB1PwAxUICgQWAAIBAhkBApsDAh4BFiEEwbyRkBhFYvxWzS6g
82mcIewHU/AAAPr/AQCYc0O+oIb5TgeRDbHIJTNbqziYbCWgyuxBh8tP4YRw
ugEA2zsKx03i8SHf5D/Vp1gTFcxjd29UEcXsrliNuSmoSwDHiwRlsiUZEgor
BgEEAZdVAQUBAQdAH6YJuedrpyBVOb40Nj+ptgoErSY1O4SL75Kj15HyIXcD
AQgH/gkDCJb3DUJaU++C4Kfqo+7C0EyL7hLP8259PlWlQHO11Z1ZrQQKgjET
LqlQAB80U19xsSzFZbmZ+MH6fZNwniysGCCBDglgS87JRnbk2OO7lZXCeAQY
FgoAKgWCZbIlGQmQ82mcIewHU/ACmwwWIQTBvJGQGEVi/FbNLqDzaZwh7AdT
8AAA9zsBANZH8j8OL7VsYbFE/+E8vN+Hra9iRFO5dP3b8G9BCPydAP46V4hM
DeYE4U0ks7cI9VPmeImOYBNcTOZIqIA2hEniBg==
=/tHc
-----END PGP PRIVATE KEY BLOCK-----''';
    String passphrase = "12345678";
    String armor = '''-----BEGIN PGP MESSAGE-----

wV4D6Ur1q/PBrZ4SAQdApm8uzokGXqEx6ZdyAjpAnkTokFEVtX/HfEEEAY8o
fXsw7silZoz8i8ADeCIoltn9yxeAWFmNuIiVn/W0NS8Tq2X179OQR/J/K2zj
EjOJpeHY0j8B14q+E3Ci5XKAVQiX3hSmN/tiq8fKXx0WIxTl8W9C4GxbCH4Z
S78EDl9lzDq2HRD4mB7Ghh1DJL9aDN8fEaM=
=Md5n
-----END PGP MESSAGE-----''';
    String decryptMessage =
        proton_crypto.decrypt(userPrivateKey, passphrase, armor);
    return decryptMessage;
  }

  @override
  Future<void> fetchWallets() async {
    isFetching = true;
    // var authInfo = await fetchAuthInfo(userName: 'ProtonWallet');
    List<WalletData> wallets = await proton_api.getWallets();
    for (WalletData walletData in wallets.reversed) {
      WalletModel? walletModel =
          await DBHelper.walletDao!.findByServerWalletId(walletData.wallet.id);
      String userPrivateKey = await SecureStorageHelper.get("userPrivateKey");
      String userKeyID = await SecureStorageHelper.get("userKeyID");
      String userPassphrase = await SecureStorageHelper.get("userPassphrase");
      if (userKeyID != walletData.walletKey.userKeyId) {
        logger.i(
            "Wallet Key mismatch: \nuserKeyID from login response:$userKeyID\nuserKeyID from API response:${walletData.walletKey.userKeyId}");
      }
      String encodedEncryptedEntropy = "";
      Uint8List entropy = Uint8List(0);
      try {
        encodedEncryptedEntropy = walletData.walletKey.walletKey;
        entropy = proton_crypto.decryptBinary(userPrivateKey, userPassphrase,
            base64Decode(encodedEncryptedEntropy));
      } catch (e) {
        logger.i(e.toString());
      }
      SecretKey secretKey =
          WalletKeyHelper.restoreSecretKeyFromEntropy(entropy);
      if (walletModel == null) {
        DateTime now = DateTime.now();
        WalletModel wallet = WalletModel(
            id: null,
            userID: 0,
            name: walletData.wallet.name,
            mnemonic: base64Decode(walletData.wallet.mnemonic!),
            passphrase: walletData.wallet.hasPassphrase,
            publicKey: Uint8List(0),
            imported: walletData.wallet.isImported,
            priority: walletData.wallet.priority,
            status: entropy.isNotEmpty
                ? walletData.wallet.status
                : WalletModel.statusDisabled,
            type: walletData.wallet.type,
            createTime: now.millisecondsSinceEpoch ~/ 1000,
            modifyTime: now.millisecondsSinceEpoch ~/ 1000,
            serverWalletID: walletData.wallet.id);
        int walletID = await DBHelper.walletDao!.insert(wallet);
        if (entropy.isNotEmpty) {
          await WalletManager.setWalletKey(walletID,
              secretKey); // need to set key first, so that we can decrypt for walletAccount
          List<WalletAccount> walletAccounts = await proton_api
              .getWalletAccounts(walletId: walletData.wallet.id);
          if (walletAccounts.isNotEmpty) {
            for (WalletAccount walletAccount in walletAccounts) {
              WalletManager.importAccount(
                  walletID,
                  await WalletKeyHelper.decrypt(secretKey, walletAccount.label),
                  walletAccount.scriptType,
                  "${walletAccount.derivationPath}/0",
                  walletAccount.id);
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
              WalletManager.importAccount(
                  walletModel.id!,
                  await WalletKeyHelper.decrypt(secretKey, walletAccount.label),
                  walletAccount.scriptType,
                  "${walletAccount.derivationPath}/0",
                  walletAccount.id);
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
    isFetching = false;
    Future.delayed(const Duration(seconds: 30), () {
      fetchWallets();
    });
  }

  @override
  void setSelectedWallet(int walletID) {
    selectedWalletID = walletID;
  }
}
