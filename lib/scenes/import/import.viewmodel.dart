import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:uuid/uuid.dart';

import '../../constants/script_type.dart';
import '../../helper/dbhelper.dart';
import '../../helper/wallet_manager.dart';
import '../../models/wallet.dao.impl.dart';
import '../../models/wallet.model.dart';

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
        imported: WalletModel.CREATE_BY_PROTON,
        priority: WalletModel.PRIMARY,
        status: WalletModel.STATUS_ACTIVE,
        type: WalletModel.TYPE_ON_CHAIN,
        createTime: now.millisecondsSinceEpoch ~/ 1000,
        modifyTime: now.millisecondsSinceEpoch ~/ 1000,
        localDBName: const Uuid().v4().replaceAll('-', ''));
    Database db = await DBHelper.database;
    WalletDaoImpl walletDaoImpl = WalletDaoImpl(db);
    int walletID = await walletDaoImpl.insert(wallet);
    WalletManager.importAccount(walletID, "Default Account",
        ScriptType.NativeSegWit.index, "m/84'/1'/0'/0");
  }
}
