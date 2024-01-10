import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:wallet/helper/bdk/helper.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/models/account.dao.impl.dart';
import 'package:wallet/models/wallet.dao.impl.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/debug/bdk.test.dart';

import '../../helper/wallet_manager.dart';
import '../../models/wallet.model.dart';
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

  int unconfirmed = 0;
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
  }

  @override
  Future<void> checkNewWallet() async {
    WalletDaoImpl walletDaoImpl = WalletDaoImpl(await DBHelper.database);
    await walletDaoImpl.findAll().then((results) async {
      AccountDaoImpl accountDaoImpl = AccountDaoImpl(await DBHelper.database);
      for (WalletModel walletModel in results) {
        walletModel.accountCount =
            await accountDaoImpl.getAccountCount(walletModel.id!);
      }
      if (results.length != userWallets.length) {
        userWallets = results;
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
    //     LocalNotification.SYNC_WALLET,
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
    totalBalance = totalBalance;
    datasourceChangedStreamController.sink.add(this);
  }
}
