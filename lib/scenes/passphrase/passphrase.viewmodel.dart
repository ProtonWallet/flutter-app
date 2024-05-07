import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:collection/collection.dart';
import 'package:flutter_tags_x/flutter_tags_x.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/helper/wallet_manager.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/models/wallet.model.dart';
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
    try {
      String walletName = nameTextController.text;
      String strPassphrase = passphraseTextController.text;
      await WalletManager.createWallet(
          walletName, strMnemonic, WalletModel.importByUser, strPassphrase);

      await WalletManager.autoBindEmailAddresses();
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
