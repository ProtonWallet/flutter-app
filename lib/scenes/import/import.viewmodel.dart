import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';
import 'package:wallet/constants/script_type.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/wallet_manager.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/network/api.helper.dart';
import 'package:wallet/scenes/core/viewmodel.dart';

abstract class ImportViewModel extends ViewModel {
  ImportViewModel(super.coordinator);

  late TextEditingController mnemonicTextController;
  late TextEditingController nameTextController;
  int mnemonicLength = 12;

  void updateMnemonic(int length);

  Future<void> importWallet();
}

class ImportViewModelImpl extends ImportViewModel {
  ImportViewModelImpl(super.coordinator);

  final datasourceChangedStreamController =
      StreamController<ImportViewModel>.broadcast();

  @override
  void dispose() {
    datasourceChangedStreamController.close();
  }

  @override
  Future<void> loadData() async {
    mnemonicTextController = TextEditingController();
    nameTextController = TextEditingController();
  }

  @override
  void updateMnemonic(int length) {
    mnemonicLength = length;
    datasourceChangedStreamController.add(this);
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  @override
  Future<void> importWallet() async {
    DateTime now = DateTime.now();
    WalletModel wallet = WalletModel(
        id: null,
        userID: 0,
        name: nameTextController.text,
        mnemonic: utf8
            .encode(await WalletManager.encrypt(mnemonicTextController.text)),
        // TO-DO: need encrypt
        passphrase: 0,
        publicKey: Uint8List(0),
        imported: WalletModel.createByProton,
        priority: WalletModel.primary,
        status: WalletModel.statusActive,
        type: WalletModel.typeOnChain,
        createTime: now.millisecondsSinceEpoch ~/ 1000,
        modifyTime: now.millisecondsSinceEpoch ~/ 1000,
        localDBName: const Uuid().v4().replaceAll('-', ''));
    int walletID = await DBHelper.walletDao!.insert(wallet);
    WalletManager.importAccount(walletID, "Default Account",
        ScriptType.nativeSegWit.index, "m/84'/1'/0'/0");

    // TODO:: send correct wallet key instead of mock one
    APIHelper.createWallet({
      "Name": wallet.name,
      "IsImported": wallet.imported,
      "Type": wallet.type,
      "HasPassphrase": wallet.passphrase,
      "UserKeyId": APIHelper.userKeyID,
      "WalletKey": base64Encode(utf8
          .encode(await WalletManager.encrypt(mnemonicTextController.text))),
      "Mnemonic": base64Encode(utf8
          .encode(await WalletManager.encrypt(mnemonicTextController.text))),
      // "PublicKey": Uint8List(0),
    });
  }
}
