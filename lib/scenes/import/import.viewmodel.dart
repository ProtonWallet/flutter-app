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
import 'package:wallet/rust/api/proton_api.dart' as proton_api;
import 'package:wallet/rust/proton_api/wallet_account_routes.dart';
import 'package:wallet/rust/proton_api/wallet_routes.dart';
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
        localDBName: const Uuid().v4().replaceAll('-', ''),
        serverWalletID: "");

    // TODO:: send correct wallet key instead of mock one
    CreateWalletReq walletReq = CreateWalletReq(
        name: wallet.name,
        isImported: wallet.imported,
        type: wallet.type,
        hasPassphrase: wallet.passphrase,
        userKeyId: APIHelper.userKeyID,
        walletKey: base64Encode(utf8
            .encode(await WalletManager.encrypt(mnemonicTextController.text))),
        mnemonic: base64Encode(utf8
            .encode(await WalletManager.encrypt(mnemonicTextController.text))));
    CreateWalletResponse createWalletResponse =
        await proton_api.createWallet(walletReq: walletReq);

    // TODO:: send correct wallet key instead of mock one
    if (createWalletResponse.code == 1000) {
      wallet.serverWalletID = createWalletResponse.wallet.id;
      CreateWalletAccountReq req = CreateWalletAccountReq(
          label: base64Encode(
              utf8.encode(await WalletManager.encrypt("Default Account"))),
          derivationPath: "m/84'/1'/0'",
          scriptType: ScriptType.nativeSegWit.index);
      WalletAccountResponse walletAccountResponse = await proton_api.createWalletAccount(
        walletId: wallet.serverWalletID,
        req: req,
      );
      if (walletAccountResponse.code == 1000) {
        int walletID = await DBHelper.walletDao!.insert(wallet);
        WalletManager.importAccount(
            walletID,
            "Default Account",
            ScriptType.nativeSegWit.index,
            "m/84'/1'/0'/0",
            walletAccountResponse.account.id);
      }
    }
  }
}
