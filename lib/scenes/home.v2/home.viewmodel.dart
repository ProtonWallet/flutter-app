import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';
import 'package:wallet/helper/bdk/helper.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/helper/proton.crypto.test.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/debug/bdk.test.dart';
import '../../helper/wallet_manager.dart';
import '../../models/wallet.model.dart';
import '../../network/api.helper.dart';
import '../core/view.navigatior.identifiers.dart';

abstract class HomeViewModel extends ViewModel {
  HomeViewModel(super.coordinator);

  int selectedPage = 0;
  int selectedWalletID = 1;
  double totalBalance = 0.0;
  String selectedAccountDerivationPath = WalletManager.getDerivationPath();

  void updateSelected(int index);

  void updateSats(String sats);

  Future<void> syncWallet();

  String sats = '0';
  List userWallets = [];

  bool isSyncing = false;
  bool hasWallet = true;
  bool hasMailIntegration = false;

  void udpateSyncStatus(bool syncing);

  void updateWallet(int id);

  void checkNewWallet();

  void updateBalance();

  void updateWallets();

  void updateHasMailIntegration(bool later);

  void setOnBoard(BuildContext context);

  void fetchWallets();

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
  late Wallet _wallet;
  Blockchain? blockchain;

  @override
  void dispose() {
    datasourceChangedStreamController.close();
    selectedSectionChangedController.close();
    //clean up wallet ....
  }

  @override
  Future<void> loadData() async {
    //restore wallet  this will need to be in global initialisation
    _wallet = await WalletManager.loadWalletWithID(0, 0);
    blockchain ??= await _lib.initializeBlockchain(false);
    _wallet.getBalance().then((value) => {
          logger.i('balance: ${value.total}'),
          sats = value.total.toString(),
          datasourceChangedStreamController.sink.add(this)
        });
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
  void updateSats(String sats) {
    this.sats = sats;
    datasourceChangedStreamController.sink.add(this);
  }

  @override
  Future<void> syncWallet() async {
    udpateSyncStatus(true);
    _wallet = await WalletManager.loadWalletWithID(0, 0);
    await _lib.sync(blockchain!, _wallet);
    var balance = await _wallet.getBalance();
    logger.i('balance: ${balance.total}');
    await updateBalance();
    udpateSyncStatus(false);
    // Use it later
    // LocalNotification.show(
    //     LocalNotification.syncWallet,
    //     "Local Notification",
    //     "Sync wallet success!\nbalance: ${balance.total}"
    // );
  }

  @override
  Future<void> updateBalance() async {
    var balance = await _wallet.getBalance();
    logger.i('balance: ${balance.total}');

    updateSats(balance.total.toString());
    var unconfirmedList = await _lib.getUnConfirmedTransactions(_wallet);
    unconfirmed = unconfirmedList.length;

    var confirmedList = await _lib.getConfirmedTransactions(_wallet);
    confirmed = confirmedList.length;
    udpateSyncStatus(false);
    datasourceChangedStreamController.sink.add(this);
  }

  @override
  void udpateSyncStatus(bool syncing) {
    isSyncing = syncing;
    datasourceChangedStreamController.sink.add(this);
  }

  @override
  void updateHasMailIntegration(bool later) {
    hasMailIntegration = later;
    datasourceChangedStreamController.sink.add(this);
  }

  @override
  Future<void> updateWallet(int id) async {
    selectedWalletID = id;
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
    String decryptMessage = decrypt(userPrivateKey.toNativeUtf8(),
        passphrase.toNativeUtf8(), armor.toNativeUtf8());
    return decryptMessage;
  }

  @override
  Future<void> fetchWallets() async {
    String result = await APIHelper.getWallets();
    Map<String, dynamic> jsonData = json.decode(result);
    if (jsonData["Code"] == 1000) {
      for (Map<String, dynamic> walletContainer in jsonData["Wallets"]) {
        Map<String, dynamic> walletData = walletContainer["Wallet"];
        // Map<String, dynamic> walletKeyData = walletContainer["WalletKey"];
        // Map<String, dynamic> walletSettingsData =
        walletContainer["WalletSettings"];
        DateTime now = DateTime.now();
        // TODO:: user mnemonic from API after bugfix by Kevin
        // String strMnemonic =
        //     "certain sense kiss guide crumble hint transfer crime much stereo warm coral";
        // if (walletData["Name"].toLowerCase().contains("third")) {
        //   strMnemonic =
        //       "elbow guide topple state museum project goat split afraid rebuild hour destroy";
        // } else if (walletData["Name"].toLowerCase().contains("second")) {
        //   strMnemonic =
        //       "blame curious virtual unhappy matter knife satisfy any young error weekend fragile";
        // }
        WalletModel? walletModel =
            await DBHelper.walletDao!.findByServerWalletId(walletData["ID"]);
        if (walletModel == null) {
          WalletModel wallet = WalletModel(
              id: null,
              userID: 0,
              name: walletData["Name"],
              mnemonic: base64Decode(walletData["Mnemonic"]),
              // mnemonic: utf8.encode(await WalletManager.encrypt(strMnemonic)),
              // TO-DO: need encrypt
              passphrase: walletData["HasPassphrase"],
              publicKey: Uint8List(0),
              imported: walletData["HasPassphrase"],
              priority: WalletModel.primary,
              status: WalletModel.statusActive,
              type: walletData["Type"],
              createTime: now.millisecondsSinceEpoch ~/ 1000,
              modifyTime: now.millisecondsSinceEpoch ~/ 1000,
              localDBName: const Uuid().v4().replaceAll('-', ''),
              serverWalletID: walletData["ID"]);
          int walletID = await DBHelper.walletDao!.insert(wallet);
          List<dynamic> accountInfos =
              await APIHelper.getAccounts(walletData["ID"]);
          if (accountInfos.isNotEmpty) {
            for (Map<String, dynamic> accountInfo in accountInfos) {
              WalletManager.importAccount(
                  walletID,
                  await WalletManager.decrypt(
                      utf8.decode(base64Decode(accountInfo["Label"]))),
                  accountInfo["ScriptType"],
                  accountInfo["DerivationPath"] + "/0",
                  accountInfo["ID"]);
            }
          }
        } else {
          List<dynamic> accountInfos =
              await APIHelper.getAccounts(walletData["ID"]);
          walletModel.accountCount =
              await DBHelper.accountDao!.getAccountCount(walletModel.id!);
          List<String> existingAccountIDs = [];
          if (accountInfos.isNotEmpty) {
            for (Map<String, dynamic> accountInfo in accountInfos) {
              existingAccountIDs.add(accountInfo["ID"]);
              WalletManager.importAccount(
                  walletModel.id!,
                  await WalletManager.decrypt(
                      utf8.decode(base64Decode(accountInfo["Label"]))),
                  accountInfo["ScriptType"],
                  accountInfo["DerivationPath"] + "/0",
                  accountInfo["ID"]);
            }
          }
          try {
            if (walletModel.accountCount != accountInfos.length) {
              DBHelper.accountDao!.deleteAccountsNotInServers(
                  walletModel.id!, existingAccountIDs);
            }
          } catch (e) {
            e.toString();
          }
        }
      }
      Future.delayed(const Duration(seconds: 30), () {
        fetchWallets();
      });
    }
  }
}
