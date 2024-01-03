import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:wallet/helper/bdk/helper.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/debug/bdk.test.dart';

import '../../helper/dbhelper.dart';
import '../../helper/wallet_manager.dart';
import '../../models/account.dao.impl.dart';
import '../../models/wallet.dao.impl.dart';
import '../../models/wallet.model.dart';

abstract class ReceiveViewModel extends ViewModel {
  ReceiveViewModel(super.coordinator, this.walletID, this.accountID);

  int walletID;
  int accountID;

  String address = "";
  List userWallets = [];
  List userAccounts = [];
  var selectedWallet;
  late ValueNotifier valueNotifier;
  late ValueNotifier valueNotifierForAccount;

  void getAddress();
}

class ReceiveViewModelImpl extends ReceiveViewModel {
  ReceiveViewModelImpl(super.coordinator, super.walletID, super.accountID);

  final BdkLibrary _lib = BdkLibrary();
  late Wallet _wallet;
  final datasourceChangedStreamController =
      StreamController<ReceiveViewModel>.broadcast();

  @override
  void dispose() {
    datasourceChangedStreamController.close();
  }

  @override
  Future<void> loadData() async {
    _wallet = await WalletManager.loadWalletWithID(walletID, accountID);
    WalletDaoImpl walletDaoImpl = WalletDaoImpl(await DBHelper.database);
    await walletDaoImpl.findAll().then((results) async {
      if (results.length != userWallets.length) {
        userWallets = results.take(5).toList();
      }
    });
    if (walletID == 0) {
      walletID = userWallets.first.id;
    }
    userWallets.forEach((element) {
      if (element.id == walletID) {
        valueNotifier = ValueNotifier(element);
        valueNotifier.addListener(() {
          updateAccountList();
        });
      }
    });
    updateAccountList();
    datasourceChangedStreamController.add(this);
  }

  Future<void> updateAccountList() async {
    AccountDaoImpl accountDaoImpl = AccountDaoImpl(await DBHelper.database);
    userAccounts =
        await accountDaoImpl.findAllByWalletID(valueNotifier.value.id);
    valueNotifierForAccount = ValueNotifier(userAccounts.first);
    valueNotifierForAccount.addListener(() {
      getAddress();
    });
    getAddress();
    datasourceChangedStreamController.add(this);
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  @override
  void getAddress() async {
    if (walletID != valueNotifier.value.id ||
        accountID != valueNotifierForAccount.value.id) {
      walletID = valueNotifier.value.id;
      accountID = valueNotifierForAccount.value.id;
      _wallet = await WalletManager.loadWalletWithID(
          valueNotifier.value.id, valueNotifierForAccount.value.id);
    }
    var addressinfo = await _lib.getAddress(_wallet);
    address = addressinfo.address;
    datasourceChangedStreamController.add(this);
  }
}
