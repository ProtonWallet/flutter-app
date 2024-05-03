import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/cupertino.dart';
import 'package:proton_crypto/proton_crypto.dart' as proton_crypto;
import 'package:wallet/constants/app.config.dart';
import 'package:wallet/helper/secure_storage_helper.dart';
import 'package:wallet/helper/wallet_manager.dart';
import 'package:wallet/helper/walletkey_helper.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/network/api.helper.dart';
import 'package:wallet/rust/api/proton_api.dart' as proton_api;
import 'package:wallet/rust/proton_api/wallet.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/import/import.coordinator.dart';

abstract class ImportViewModel extends ViewModel<ImportCoordinator> {
  ImportViewModel(super.coordinator);

  late TextEditingController mnemonicTextController;
  late TextEditingController nameTextController;
  late TextEditingController passphraseTextController;
  late FocusNode mnemonicFocusNode;
  late FocusNode nameFocusNode;
  late FocusNode passphraseFocusNode;
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
    mnemonicFocusNode = FocusNode();
    nameFocusNode = FocusNode();
    passphraseFocusNode = FocusNode();
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
    String userPrivateKey =
        await SecureStorageHelper.instance.get("userPrivateKey");
    Uint8List entropy = Uint8List.fromList(await secretKey.extractBytes());
    String strMnemonic = mnemonicTextController.text;
    String encryptedMnemonic =
        await WalletKeyHelper.encrypt(secretKey, strMnemonic);
    String? strPassphrase = passphraseTextController.text != ""
        ? passphraseTextController.text
        : null;

    String fingerprint = await WalletManager.getFingerPrintFromMnemonic(
        strMnemonic,
        passphrase: strPassphrase);
    CreateWalletReq walletReq = CreateWalletReq(
        name: nameTextController.text,
        isImported: WalletModel.importByUser,
        type: WalletModel.typeOnChain,
        hasPassphrase: 0,
        userKeyId: APIHelper.userKeyID,
        walletKey: base64Encode(
            proton_crypto.encryptBinaryArmor(userPrivateKey, entropy)),
        fingerprint: fingerprint,
        mnemonic: encryptedMnemonic);
    WalletData walletData = await proton_api.createWallet(walletReq: walletReq);

    String serverWalletID = walletData.wallet.id;
    if (passphraseTextController.text != "") {
      await SecureStorageHelper.instance
          .set(serverWalletID, passphraseTextController.text);
    }
    int walletID = await WalletManager.insertOrUpdateWallet(
        userID: 0,
        name: nameTextController.text,
        encryptedMnemonic: encryptedMnemonic,
        passphrase: passphraseTextController.text.isNotEmpty ? 1 : 0,
        imported: WalletModel.importByUser,
        priority: WalletModel.primary,
        status: WalletModel.statusActive,
        type: WalletModel.typeOnChain,
        fingerprint: fingerprint,
        serverWalletID: serverWalletID);

    await WalletManager.setWalletKey(serverWalletID,
        secretKey); // need to set key first, so that we can decrypt for walletAccount
    await WalletManager.addWalletAccount(
        walletID, appConfig.scriptType, "BTC Account");
    await WalletManager.autoBindEmailAddresses();
    await Future.delayed(
        const Duration(seconds: 1)); // wait for account show on sidebar
  }

  @override
  void move(NavigationIdentifier to) {}
}
