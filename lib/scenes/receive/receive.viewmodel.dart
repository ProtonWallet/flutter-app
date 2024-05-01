import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:wallet/constants/app.config.dart';
import 'package:wallet/helper/bdk/helper.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/wallet_manager.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/debug/bdk.test.dart';
import 'package:wallet/scenes/receive/receive.coordinator.dart';

abstract class ReceiveViewModel extends ViewModel<ReceiveCoordinator> {
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

  final BdkLibrary _lib = BdkLibrary(coinType: appConfig.coinType);
  late Wallet _wallet;
  final datasourceChangedStreamController =
      StreamController<ReceiveViewModel>.broadcast();

  @override
  void dispose() {
    datasourceChangedStreamController.close();
  }

  @override
  Future<void> loadData() async {
    if (walletID == 0) {
      WalletModel? walletModel =
          await DBHelper.walletDao!.getFirstPriorityWallet();
      if (walletModel != null) {
        walletID = walletModel.id!;
      } else {
        return;
      }
    }
    await DBHelper.walletDao!.findAll().then((results) async {
      if (results.length != userWallets.length) {
        userWallets = results;
      }
    });
    for (var element in userWallets) {
      if (element.id == walletID) {
        valueNotifier = ValueNotifier(element);
        valueNotifier.addListener(() {
          updateAccountList();
        });
      }
    }
    await updateAccountList();
    datasourceChangedStreamController.add(this);
  }

  Future<void> updateAccountList() async {
    userAccounts =
        await DBHelper.accountDao!.findAllByWalletID(valueNotifier.value.id);
    if (userAccounts.isEmpty) {
      return;
    }
    AccountModel selectedAccount = userAccounts.first;
    for (AccountModel accountModel in userAccounts) {
      if (accountModel.id == accountID) {
        selectedAccount = accountModel;
        break;
      }
    }
    valueNotifierForAccount = ValueNotifier(selectedAccount);
    valueNotifierForAccount.addListener(() {
      getAddress();
    });
    await getAddress(init: true);
    datasourceChangedStreamController.add(this);
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  @override
  Future<void> getAddress({bool init = false}) async {
    if (init ||
        walletID != valueNotifier.value.id ||
        accountID != valueNotifierForAccount.value.id) {
      walletID = valueNotifier.value.id;
      accountID = valueNotifierForAccount.value.id;
      _wallet = await WalletManager.loadWalletWithID(
          valueNotifier.value.id, valueNotifierForAccount.value.id);
    }
    var addressInfo = await _lib.getAddress(_wallet);
    address = addressInfo.address;
    datasourceChangedStreamController.add(this);
  }

  @override
  void move(NavigationIdentifier to) {
    // TODO: implement move
  }
}
