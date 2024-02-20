import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';
import 'package:collection/collection.dart';
import 'package:flutter_tags_x/flutter_tags_x.dart';
import 'package:proton_crypto/proton_crypto.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/helper/secure_storage_helper.dart';
import 'package:wallet/helper/wallet_manager.dart';
import 'package:wallet/helper/walletkey_helper.dart';
import 'package:wallet/rust/api/proton_api.dart' as proton_api;
import 'package:wallet/rust/proton_api/wallet.dart';
import 'package:wallet/rust/proton_api/wallet_account.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/constants/script_type.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/network/api.helper.dart';

abstract class SetupPassPhraseViewModel extends ViewModel {
  SetupPassPhraseViewModel(super.coordinator, this.strMnemonic);

  List<Item> itemList = [];
  List<Item> itemListShuffled = [];
  List<String> userPhraseList = [];
  String strMnemonic;
  int editIndex = 0;
  bool isAddingPassPhrase = false;
  late TextEditingController passphraseTextController;
  late TextEditingController passphraseTextConfirmController;

  void updateUserPhraseList(String title, bool remove);

  bool checkUserMnemonic();

  void setPhraseItem(String title, bool active);

  void updateState(bool isAddingPassPhrase);

  void updateDB();

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
    String userPrivateKey = await SecureStorageHelper.get("userPrivateKey");
    DateTime now = DateTime.now();
    WalletModel wallet = WalletModel(
        id: null,
        userID: 0,
        name: 'New Wallet',
        mnemonic:
            utf8.encode(await WalletKeyHelper.encrypt(secretKey, strMnemonic)),
        // TO-DO: need encrypt
        passphrase: passphraseTextController.text != "" ? 1 : 0,
        publicKey: Uint8List(0),
        // TODO:: None MVP
        imported: WalletModel.createByProton,
        priority: WalletModel.primary,
        status: WalletModel.statusActive,
        type: WalletModel.typeOnChain,
        createTime: now.millisecondsSinceEpoch ~/ 1000,
        modifyTime: now.millisecondsSinceEpoch ~/ 1000,
        localDBName: const Uuid().v4().replaceAll('-', ''),
        serverWalletID: "");

    CreateWalletReq walletReq = CreateWalletReq(
        name: wallet.name,
        isImported: wallet.imported,
        type: wallet.type,
        hasPassphrase: wallet.passphrase,
        userKeyId: APIHelper.userKeyID,
        walletKey: base64Encode(utf8.encode(encrypt(
            userPrivateKey.toNativeUtf8(),
            utf8.decode(await secretKey.extractBytes()).toNativeUtf8()))),
        mnemonic: base64Encode(utf8
            .encode(await WalletKeyHelper.encrypt(secretKey, strMnemonic))));

    try {
      WalletData walletData =
          await proton_api.createWallet(walletReq: walletReq);

      // TODO:: send correct wallet key instead of mock one
      wallet.serverWalletID = walletData.wallet.id;
      if (passphraseTextController.text != "") {
        await SecureStorageHelper.set(
            wallet.serverWalletID, passphraseTextController.text);
      }
      CreateWalletAccountReq req = CreateWalletAccountReq(
          label: base64Encode(utf8.encode(
              await WalletKeyHelper.encrypt(secretKey, "Default Account"))),
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
}
