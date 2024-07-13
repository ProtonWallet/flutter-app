import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_tags_x/flutter_tags_x.dart';
import 'package:wallet/constants/app.config.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/script_type.dart';
import 'package:wallet/helper/extension/stream.controller.dart';
import 'package:wallet/managers/features/create.wallet.bloc.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/passphrase/passphrase.coordinator.dart';

abstract class SetupPassPhraseViewModel
    extends ViewModel<SetupPassPhraseCoordinator> {
  SetupPassPhraseViewModel(super.coordinator, this.strMnemonic);

  List<Item> itemList = [];
  List<Item> itemListShuffled = [];
  List<String> userPhraseList = [];
  String strMnemonic;
  int editIndex = 0;
  String errorMessage = "";
  bool isAddingPassPhrase = false;
  late TextEditingController passphraseTextController;
  late TextEditingController passphraseTextConfirmController;
  late TextEditingController nameTextController;
  late FocusNode walletNameFocusNode;

  late FocusNode passphraseFocusNode;
  late FocusNode passphraseConfirmFocusNode;

  void updateUserPhraseList(String title, {required bool remove});

  bool checkUserMnemonic();

  void setPhraseItem(String title, {required bool isActive});

  void updateState({required bool isAddingPassPhrase});

  Future<void> updateDB();

  bool checkPassphrase();
}

class SetupPassPhraseViewModelImpl extends SetupPassPhraseViewModel {
  SetupPassPhraseViewModelImpl(
    super.coordinator,
    super.strMnemonic,
    this.createWalletBloc,
    this.userID,
  );

  final CreateWalletBloc createWalletBloc;
  final String userID;

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
    datasourceChangedStreamController.sinkAddSafe(this);
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
  void updateUserPhraseList(String title, {required bool remove}) {
    if (title == "") {
      return;
    }
    for (int index = 0; index < userPhraseList.length; index++) {
      if (remove) {
        if (userPhraseList[index] == title) {
          userPhraseList[index] = "";
          setPhraseItem(title, isActive: true);
          break;
        }
      } else {
        if (userPhraseList[index] == "") {
          userPhraseList[index] = title;
          setPhraseItem(title, isActive: false);
          break;
        }
      }
    }
    updateEditIndex();
    datasourceChangedStreamController.sinkAddSafe(this);
  }

  @override
  void setPhraseItem(String title, {required bool isActive}) {
    for (int index = 0; index < itemListShuffled.length; index++) {
      if (itemListShuffled[index].title == title) {
        itemListShuffled[index] = Item(
          title: itemListShuffled[index].title,
          index: itemListShuffled[index].index,
          active: isActive,
        );
        break;
      }
    }
    datasourceChangedStreamController.sinkAddSafe(this);
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  @override
  bool checkUserMnemonic() {
    return strMnemonic == userPhraseList.join(" ");
  }

  @override
  void updateState({required bool isAddingPassPhrase}) {
    this.isAddingPassPhrase = isAddingPassPhrase;
    datasourceChangedStreamController.sinkAddSafe(this);
  }

  @override
  Future<void> updateDB() async {
    try {
      final String walletName = nameTextController.text;
      final String strPassphrase = passphraseTextController.text;
      final ScriptTypeInfo scriptTypeInfo = appConfig.scriptTypeInfo;

      final apiWallet = await createWalletBloc.createWallet(
        walletName,
        strMnemonic,
        appConfig.coinType.network,
        WalletModel.importByUser,
        strPassphrase,
      );

      await createWalletBloc.createWalletAccount(
        apiWallet.wallet.id,
        scriptTypeInfo,
        "My wallet account",
        defaultFiatCurrency,
        0, // default wallet account index
      );

      await WalletManager.autoBindEmailAddresses(userID);
      await Future.delayed(
          const Duration(seconds: 1)); // wait for account show on sidebar
    } catch (e) {
      errorMessage = e.toString();
    }
  }

  @override
  bool checkPassphrase() {
    final String passphrase1 = passphraseTextController.text;
    final String passphrase2 = passphraseTextConfirmController.text;
    // TO-DO: check passphrase is strong enough?
    return passphrase1 == passphrase2;
  }

  @override
  Future<void> move(NavID to) async {}
}
