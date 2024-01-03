import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wallet/helper/local_toast.dart';
import 'package:wallet/helper/wallet_manager.dart';
import 'package:wallet/models/wallet.dao.impl.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import '../../helper/dbhelper.dart';
import '../../models/account.dao.impl.dart';
import '../../models/account.model.dart';
import '../../models/wallet.model.dart';
import '../debug/bdk.test.dart';
import 'package:wallet/helper/bdk/helper.dart';

abstract class WalletViewModel extends ViewModel {
  List accounts = [];
  int walletID;
  bool initialed = false;
  late WalletModel walletModel;
  late AccountModel accountModel;

  late ValueNotifier valueNotifier;

  void copyMnemonic(BuildContext context);

  void updateAccount(AccountModel accountModel);

  void updateWalletInfo();

  void syncWallet();

  WalletViewModel(super.coordinator, this.walletID);

  int totalBalance = 0;
  int balance = 0;
  int unconfirmed = 0;
  int confirmed = 0;
  bool isSyncing = false;
}

class WalletViewModelImpl extends WalletViewModel {
  WalletViewModelImpl(super.coordinator, super.walletID);

  final BdkLibrary _lib = BdkLibrary();
  Blockchain? blockchain;
  late Wallet wallet;
  final datasourceChangedStreamController =
      StreamController<WalletViewModel>.broadcast();

  @override
  void dispose() {
    datasourceChangedStreamController.close();
  }

  @override
  Future<void> loadData() async {
    blockchain ??= await _lib.initializeBlockchain(false);
    Database db = await DBHelper.database;
    WalletDaoImpl walletDaoImpl = WalletDaoImpl(db);
    walletModel = await walletDaoImpl.findById(walletID);
    AccountDaoImpl accountDaoImpl = AccountDaoImpl(db);
    accounts = await accountDaoImpl.findAllByWalletID(walletID);
    accountModel = accounts.first;
    wallet = await WalletManager.loadWalletWithID(walletID, accountModel.id!);
    valueNotifier = ValueNotifier(accountModel);
    valueNotifier.addListener(() {
      updateAccount(valueNotifier.value);
    });
    updateWalletInfo();
    initialed = true;
    datasourceChangedStreamController.sink.add(this);
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  @override
  Future<void> updateAccount(AccountModel accountModel) async {
    if (accountModel.id != this.accountModel.id) {
      this.accountModel = accountModel;
      wallet =
          await WalletManager.loadWalletWithID(walletID, accountModel.id!);
      var _balance = await wallet.getBalance();
      balance = _balance.total;
      var unconfirmedList = await _lib.getUnConfirmedTransactions(wallet);
      unconfirmed = unconfirmedList.length;

      var confirmedList = await _lib.getConfirmedTransactions(wallet);
      confirmed = confirmedList.length;
      datasourceChangedStreamController.sink.add(this);
    }
  }

  @override
  Future<void> copyMnemonic(BuildContext context) async {
    Clipboard.setData(ClipboardData(
            text: await WalletManager.getMnemonicWithID(walletID)))
        .then((_) {
      LocalToast.showToast(context, "Copied Mnemonic!");
    });
  }

  @override
  Future<void> syncWallet() async {
    if (initialed && !isSyncing) {
      isSyncing = true;
      datasourceChangedStreamController.sink.add(this);
      await _lib.sync(blockchain!, wallet);
      var _balance = await wallet.getBalance();
      balance = _balance.total;
      var unconfirmedList = await _lib.getUnConfirmedTransactions(wallet);
      unconfirmed = unconfirmedList.length;

      var confirmedList = await _lib.getConfirmedTransactions(wallet);
      confirmed = confirmedList.length;
      isSyncing = false;
      datasourceChangedStreamController.sink.add(this);
      updateWalletInfo();
    }
  }

  @override
  Future<void> updateWalletInfo() async{
    totalBalance = 0;
    for (AccountModel _accountModel in accounts){
      Wallet _wallet = await WalletManager.loadWalletWithID(walletID, _accountModel.id!);
      totalBalance += (await _wallet.getBalance()).total;
      datasourceChangedStreamController.sink.add(this);
    };
  }
}
