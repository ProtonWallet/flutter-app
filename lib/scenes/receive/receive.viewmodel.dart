import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:wallet/helper/bdk/helper.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/wallet_manager.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/debug/bdk.test.dart';

abstract class ReceiveViewModel extends ViewModel {
  ReceiveViewModel(super.coordinator, this.walletID, this.accountID);

  int walletID;
  int accountID;

  String address = "";
  List userWallets = [];
  List userAccounts = [];
  var selectedWallet = 1;
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
    await DBHelper.walletDao!.findAll().then((results) async {
      if (results.length != userWallets.length) {
        userWallets = results.take(5).toList();
      }
    });
    if (walletID == 0) {
      walletID = userWallets.first.id;
    }
    for (var element in userWallets) {
      if (element.id == walletID) {
        valueNotifier = ValueNotifier(element);
        valueNotifier.addListener(() {
          updateAccountList();
        });
      }
    }
    updateAccountList();
    datasourceChangedStreamController.add(this);
  }

  Future<void> updateAccountList() async {
    userAccounts =
        await DBHelper.accountDao!.findAllByWalletID(valueNotifier.value.id);
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
