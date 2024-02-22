import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/cupertino.dart';
import 'package:proton_crypto/proton_crypto.dart' as proton_crypto;
import 'package:uuid/uuid.dart';
import 'package:wallet/constants/script_type.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/secure_storage_helper.dart';
import 'package:wallet/helper/wallet_manager.dart';
import 'package:wallet/helper/walletkey_helper.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/network/api.helper.dart';
import 'package:wallet/rust/api/proton_api.dart' as proton_api;
import 'package:wallet/rust/proton_api/wallet.dart';
import 'package:wallet/rust/proton_api/wallet_account.dart';
import 'package:wallet/scenes/core/viewmodel.dart';

abstract class ImportViewModel extends ViewModel {
  ImportViewModel(super.coordinator);

  late TextEditingController mnemonicTextController;
  late TextEditingController nameTextController;
  late TextEditingController passphraseTextController;
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
    passphraseTextController = TextEditingController();
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
    SecretKey secretKey = WalletKeyHelper.generateSecretKey();
    String userPrivateKey = await SecureStorageHelper.get("userPrivateKey");
    DateTime now = DateTime.now();
    WalletModel wallet = WalletModel(
        id: null,
        userID: 0,
        name: nameTextController.text,
        mnemonic: base64Decode(await WalletKeyHelper.encrypt(
            secretKey, mnemonicTextController.text)),
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
    Uint8List entropy = Uint8List.fromList(await secretKey.extractBytes());

    CreateWalletReq walletReq = CreateWalletReq(
        name: wallet.name,
        isImported: wallet.imported,
        type: wallet.type,
        hasPassphrase: wallet.passphrase,
        userKeyId: APIHelper.userKeyID,
        walletKey: base64Encode(proton_crypto.encryptBinaryArmor(userPrivateKey,
            entropy)),
        fingerprint: "12345678", // TODO:: send correct fingerprint
        mnemonic: await WalletKeyHelper.encrypt(
            secretKey, mnemonicTextController.text));
    WalletData walletData = await proton_api.createWallet(walletReq: walletReq);

    wallet.serverWalletID = walletData.wallet.id;
    if (passphraseTextController.text != "") {
      await SecureStorageHelper.set(
          wallet.serverWalletID, passphraseTextController.text);
    }
    CreateWalletAccountReq req = CreateWalletAccountReq(
        label:
            await WalletKeyHelper.encrypt(secretKey, "Default Account"),
        derivationPath: "m/84'/1'/0'",
        scriptType: ScriptType.nativeSegWit.index);
    WalletAccount walletAccount = await proton_api.createWalletAccount(
      walletId: wallet.serverWalletID,
      req: req,
    );

    int walletID = await DBHelper.walletDao!.insert(wallet);
    await WalletManager.setWalletKey(walletID,
        secretKey); // need to set key first, so that we can decrypt for walletAccount
    WalletManager.importAccount(walletID, "Default Account",
        ScriptType.nativeSegWit.index, "m/84'/1'/0'/0", walletAccount.id);
  }
}
