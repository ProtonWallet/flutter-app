import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wallet/helper/wallet_manager.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/helper/bdk/helper.dart';
import 'package:wallet/scenes/debug/bdk.test.dart';

abstract class SendViewModel extends ViewModel {
  SendViewModel(super.coordinator, this.walletID, this.accountID);

  int walletID;
  int accountID;
  String fromAddress = "";
  late TextEditingController textController;

  late TextEditingController recipientTextController;

  Future<void> sendCoin();
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
    textController = TextEditingController();
    recipientTextController = TextEditingController();
    //restore wallet
    _wallet = await WalletManager.loadWalletWithID(walletID, accountID);
    _blockchain = await _lib.initializeBlockchain(false);
    getAddress();
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  void getAddress() async {
    var addressinfo = await _lib.getAddress(_wallet);

    fromAddress = addressinfo.address;
    textController.text = fromAddress;
    recipientTextController.text = "tb1qw2c3lxufxqe2x9s4rdzh65tpf4d7fssjgh8nv6";
    datasourceChangedStreamController.add(this);
  }

  @override
  Future<void> sendCoin() async {
    var receipinetAddress = recipientTextController.text;
    await _lib.sendBitcoin(_blockchain!, _wallet, receipinetAddress, 300);
  }
}
