import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wallet/helper/wallet_manager.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/helper/bdk/helper.dart';
import 'package:wallet/scenes/debug/bdk.test.dart';
import '../../helper/dbhelper.dart';
import '../../helper/logger.dart';

abstract class SendViewModel extends ViewModel {
  SendViewModel(super.coordinator, this.walletID, this.accountID);

  int walletID;
  int accountID;
  String fromAddress = "";
  List userWallets = [];
  List userAccounts = [];
  late TextEditingController coinController;
  late TextEditingController recipientTextController;
  late TextEditingController amountTextController;

  late ValueNotifier valueNotifier;
  late ValueNotifier valueNotifierForAccount;
  int balance = 0;
  double feeRate = 99.9;

  Future<void> sendCoin();
  Future<void> updateFeeRate();
}

class SendViewModelImpl extends SendViewModel {
  SendViewModelImpl(super.coordinator, super.walletID, super.accountID);

  final datasourceChangedStreamController =
      StreamController<SendViewModel>.broadcast();
  final BdkLibrary _lib = BdkLibrary();
  late Wallet _wallet;
  late Blockchain? _blockchain;

  @override
  void dispose() {
    datasourceChangedStreamController.close();
  }

  @override
  Future<void> loadData() async {
    coinController = TextEditingController();
    recipientTextController = TextEditingController();
    amountTextController = TextEditingController();
    recipientTextController.text = "tb1qw2c3lxufxqe2x9s4rdzh65tpf4d7fssjgh8nv6";
    datasourceChangedStreamController.add(this);
    _blockchain = await _lib.initializeBlockchain(false);
    await DBHelper.walletDao!.findAll().then((results) async {
      if (results.length != userWallets.length) {
        userWallets = results.take(5).toList();
      }
    });
    updateFeeRate();
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
    updateWallet();
  }

  Future<void> updateAccountList() async {
    userAccounts =
        await DBHelper.accountDao!.findAllByWalletID(valueNotifier.value.id);
    accountID = userAccounts.first.id;
    valueNotifierForAccount = ValueNotifier(userAccounts.first);
    valueNotifierForAccount.addListener(() {
      walletID = valueNotifier.value.id;
      accountID = valueNotifierForAccount.value.id;
      updateWallet();
    });
    walletID = valueNotifier.value.id;
    accountID = valueNotifierForAccount.value.id;
    updateWallet();
    datasourceChangedStreamController.add(this);
  }

  Future<void> updateWallet() async {
    _wallet = await WalletManager.loadWalletWithID(walletID, accountID);
    var walletBalance = await _wallet.getBalance();
    balance = walletBalance.total;
    datasourceChangedStreamController.add(this);
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  @override
  Future<void> sendCoin() async {
    if (amountTextController.text != "") {
      var receipinetAddress = recipientTextController.text;
      int amount = int.parse(amountTextController.text);
      logger.i("Target addr: $receipinetAddress\nAmount: $amount");
      await _lib.sendBitcoin(_blockchain!, _wallet, receipinetAddress, amount);
    }
  }

  @override
  Future<void> updateFeeRate() async{
    FeeRate feeRate_ = await _lib.estimateFeeRate(25, _blockchain!);
    feeRate = feeRate_.asSatPerVb();
    datasourceChangedStreamController.add(this);
    Future.delayed(const Duration(seconds: 5), () {
      updateFeeRate();
    });
  }
}
