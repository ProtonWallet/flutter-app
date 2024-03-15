import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/cupertino.dart';
import 'package:proton_crypto/proton_crypto.dart' as proton_crypto;
import 'package:wallet/constants/script_type.dart';
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
    Uint8List entropy = Uint8List.fromList(await secretKey.extractBytes());
    String encryptedMnemonic =
        await WalletKeyHelper.encrypt(secretKey, mnemonicTextController.text);
    CreateWalletReq walletReq = CreateWalletReq(
        name: nameTextController.text,
        isImported: WalletModel.importByUser,
        type: WalletModel.typeOnChain,
        hasPassphrase: 0,
        userKeyId: APIHelper.userKeyID,
        walletKey: base64Encode(
            proton_crypto.encryptBinaryArmor(userPrivateKey, entropy)),
        fingerprint: "12345678", // TODO:: send correct fingerprint
        mnemonic: encryptedMnemonic);
    WalletData walletData = await proton_api.createWallet(walletReq: walletReq);

    String serverWalletID = walletData.wallet.id;
    if (passphraseTextController.text != "") {
      await SecureStorageHelper.set(
          serverWalletID, passphraseTextController.text);
    }
    CreateWalletAccountReq req = CreateWalletAccountReq(
        label: await WalletKeyHelper.encrypt(secretKey, "Default Account"),
        derivationPath: "m/84'/1'/0'",
        scriptType: ScriptType.nativeSegWit.index);
    WalletAccount walletAccount = await proton_api.createWalletAccount(
      walletId: serverWalletID,
      req: req,
    );

    int walletID = await WalletManager.insertOrUpdateWallet(
        userID: 0,
        name: nameTextController.text,
        encryptedMnemonic: encryptedMnemonic,
        passphrase: 0,
        imported: WalletModel.importByUser,
        priority: WalletModel.primary,
        status: WalletModel.statusActive,
        type: WalletModel.typeOnChain,
        serverWalletID: serverWalletID);

    await WalletManager.setWalletKey(serverWalletID,
        secretKey); // need to set key first, so that we can decrypt for walletAccount
    WalletManager.insertOrUpdateAccount(walletID, walletAccount.label,
        ScriptType.nativeSegWit.index, "m/84'/1'/0'/0", walletAccount.id);
  }
}
