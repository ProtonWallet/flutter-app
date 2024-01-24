import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';
import 'package:wallet/helper/bdk/helper.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/logger.dart';
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
          } catch (e){
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
