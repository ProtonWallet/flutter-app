import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';
import 'package:collection/collection.dart';
import 'package:flutter_tags_x/flutter_tags_x.dart';
import 'package:wallet/helper/wallet_manager.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import '../../constants/script_type.dart';
import '../../helper/dbhelper.dart';
import '../../models/wallet.model.dart';
import '../../network/api.helper.dart';

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
    DateTime now = DateTime.now();
    WalletModel wallet = WalletModel(
        id: null,
        userID: 0,
        name: 'New Wallet',
        mnemonic: utf8.encode(await WalletManager.encrypt(strMnemonic,
            passphrase_: passphraseTextController.text)),
        // TO-DO: need encrypt
        passphrase: passphraseTextController.text != "" ? 1 : 0,
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
      "WalletKey": base64Encode(utf8.encode(await WalletManager.encrypt(strMnemonic,
          passphrase_: passphraseTextController.text))),
      "Mnemonic": base64Encode(utf8.encode(await WalletManager.encrypt(strMnemonic,
          passphrase_: passphraseTextController.text))),
      // "PublicKey": Uint8List(0),
    });
  }

  @override
  bool checkPassphrase() {
    String passphrase1 = passphraseTextController.text;
    String passphrase2 = passphraseTextConfirmController.text;
    // TO-DO: check passphrase is strong enough?
    return passphrase1 == passphrase2;
  }
}
