import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/helper/bdk/helper.dart';
import 'package:wallet/scenes/debug/bdk.test.dart';

abstract class SendViewModel extends ViewModel {
  SendViewModel(super.coordinator);

  String fromAddress = "";
  late TextEditingController textController;

  late TextEditingController recipientTextController;

  Future<void> sendCoin();
}

class SendViewModelImpl extends SendViewModel {
  SendViewModelImpl(super.coordinator);
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
    final aliceMnemonic = await Mnemonic.fromString(
        'certain sense kiss guide crumble hint transfer crime much stereo warm coral');
    final aliceDescriptor = await _lib.createDescriptor(aliceMnemonic);
    _wallet = await _lib.restoreWallet(aliceDescriptor);
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


// sendBitcoin(
//       Blockchain blockchain, Wallet aliceWallet, String addressStr) async {
//     try {
//       final txBuilder = TxBuilder();
//       final address = await Address.create(address: addressStr);

//       final script = await address.scriptPubKey();
//       final feeRate = await estimateFeeRate(25, blockchain);
//       final txBuilderResult = await txBuilder
//           .addRecipient(script, 750)
//           .feeRate(feeRate.asSatPerVb())
//           .finish(aliceWallet);
//       getInputOutPuts(txBuilderResult, blockchain);
//       final aliceSbt = await aliceWallet.sign(psbt: txBuilderResult.psbt);
//       final tx = await aliceSbt.extractTx();
//       Isolate.run(() async => {await blockchain.broadcast(tx)});
//     } on Exception catch (_) {
//       rethrow;
//     }
//   }