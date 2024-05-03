import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/cupertino.dart';
import 'package:collection/collection.dart';
import 'package:flutter_tags_x/flutter_tags_x.dart';
import 'package:proton_crypto/proton_crypto.dart' as proton_crypto;
import 'package:wallet/constants/app.config.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/helper/secure_storage_helper.dart';
import 'package:wallet/helper/wallet_manager.dart';
import 'package:wallet/helper/walletkey_helper.dart';
import 'package:wallet/rust/api/proton_api.dart' as proton_api;
import 'package:wallet/rust/proton_api/wallet.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/network/api.helper.dart';
import 'package:wallet/scenes/passphrase/passphrase.coordinator.dart';

abstract class SetupPassPhraseViewModel
    extends ViewModel<SetupPassPhraseCoordinator> {
  SetupPassPhraseViewModel(super.coordinator, this.strMnemonic);

  List<Item> itemList = [];
  List<Item> itemListShuffled = [];
  List<String> userPhraseList = [];
  String strMnemonic;
  int editIndex = 0;
  bool isAddingPassPhrase = false;
  late TextEditingController passphraseTextController;
  late TextEditingController passphraseTextConfirmController;
  late TextEditingController nameTextController;
  late FocusNode walletNameFocusNode;

  late FocusNode passphraseFocusNode;
  late FocusNode passphraseConfirmFocusNode;

  void updateUserPhraseList(String title, bool remove);

  bool checkUserMnemonic();

  void setPhraseItem(String title, bool active);

  void updateState(bool isAddingPassPhrase);

  Future<void> updateDB();

  bool checkPassphrase();
}

class SetupPassPhraseViewModelImpl extends SetupPassPhraseViewModel {
  SetupPassPhraseViewModelImpl(super.coordinator, super.strMnemonic);

  final datasourceChangedStreamController =
      StreamController<SetupPassPhraseViewModel>.broadcast();

  @override
  void dispose() {
    datasourceChangedStreamController.close();
  }

  @override
  Future<void> loadData() async {
    passphraseTextController = TextEditingController();
    passphraseTextConfirmController = TextEditingController();
    walletNameFocusNode = FocusNode();
    passphraseFocusNode = FocusNode();
    passphraseConfirmFocusNode = FocusNode();
    nameTextController = TextEditingController(text: "New Wallet");
    strMnemonic.split(" ").forEachIndexed((index, element) {
      itemList.add(Item(
        title: element,
        index: index,
      ));
    });
    itemListShuffled = itemList
        .map((item) => Item(title: item.title, index: item.index, active: true))
        .toList();
    itemListShuffled.shuffle();
    userPhraseList = List<String>.filled(itemList.length, "");
    datasourceChangedStreamController.add(this);
  }

  void updateEditIndex() {
    for (int index = 0; index < userPhraseList.length; index++) {
      if (userPhraseList[index] == "") {
        editIndex = index;
        break;
      }
    }
  }

  @override
  void updateUserPhraseList(String title, bool remove) {
    if (title == "") {
      return;
    }
    for (int index = 0; index < userPhraseList.length; index++) {
      if (remove) {
        if (userPhraseList[index] == title) {
          userPhraseList[index] = "";
          setPhraseItem(title, true);
          break;
        }
      } else {
        if (userPhraseList[index] == "") {
          userPhraseList[index] = title;
          setPhraseItem(title, false);
          break;
        }
      }
    }
    updateEditIndex();
    datasourceChangedStreamController.add(this);
  }

  @override
  void setPhraseItem(String title, bool active) {
    for (int index = 0; index < itemListShuffled.length; index++) {
      if (itemListShuffled[index].title == title) {
        itemListShuffled[index] = Item(
          title: itemListShuffled[index].title,
          index: itemListShuffled[index].index,
          active: active,
        );
        break;
      }
    }
    datasourceChangedStreamController.add(this);
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  @override
  bool checkUserMnemonic() {
    return strMnemonic == userPhraseList.join(" ");
  }

  @override
  void updateState(bool isAddingPassPhrase) {
    this.isAddingPassPhrase = isAddingPassPhrase;
    datasourceChangedStreamController.add(this);
  }

  @override
  Future<void> updateDB() async {
    SecretKey secretKey = WalletKeyHelper.generateSecretKey();
    String userPrivateKey =
        await SecureStorageHelper.instance.get("userPrivateKey");
    int passphrase = passphraseTextController.text != "" ? 1 : 0;
    String encryptedMnemonic =
        await WalletKeyHelper.encrypt(secretKey, strMnemonic);
    String walletName = nameTextController.text.isNotEmpty
        ? nameTextController.text
        : "New Wallet";
    Uint8List entropy = Uint8List.fromList(await secretKey.extractBytes());

    String? strPassphrase = passphraseTextController.text != ""
        ? passphraseTextController.text
        : null;
    String fingerprint = await WalletManager.getFingerPrintFromMnemonic(
        strMnemonic,
        passphrase: strPassphrase);
    CreateWalletReq walletReq = CreateWalletReq(
      name: walletName,
      isImported: WalletModel.createByProton,
      type: WalletModel.typeOnChain,
      hasPassphrase: passphrase,
      userKeyId: APIHelper.userKeyID,
      walletKey: base64Encode(
          proton_crypto.encryptBinaryArmor(userPrivateKey, entropy)),
      fingerprint: fingerprint,
      mnemonic: encryptedMnemonic,
    );

    try {
      WalletData walletData =
          await proton_api.createWallet(walletReq: walletReq);
      String serverWalletID = walletData.wallet.id;
      if (passphraseTextController.text != "") {
        await SecureStorageHelper.instance
            .set(serverWalletID, passphraseTextController.text);
      }
      int walletID = await WalletManager.insertOrUpdateWallet(
          userID: 0,
          name: walletName,
          encryptedMnemonic: encryptedMnemonic,
          passphrase: passphraseTextController.text.isNotEmpty ? 1 : 0,
          imported: WalletModel.createByProton,
          priority: WalletModel.primary,
          status: WalletModel.statusActive,
          type: WalletModel.typeOnChain,
          fingerprint: fingerprint,
          serverWalletID: serverWalletID);
      await WalletManager.setWalletKey(serverWalletID,
          secretKey); // need to set key first, so that we can decrypt for walletAccount
      await WalletManager.addWalletAccount(
          walletID, appConfig.scriptType, "BTC Account");
      await Future.delayed(
          const Duration(seconds: 1)); // wait for account show on sidebar
    } catch (e) {
      logger.e(e);
    }
  }

  @override
  bool checkPassphrase() {
    String passphrase1 = passphraseTextController.text;
    String passphrase2 = passphraseTextConfirmController.text;
    // TO-DO: check passphrase is strong enough?
    return passphrase1 == passphrase2;
  }

  @override
  void move(NavigationIdentifier to) {}
}
