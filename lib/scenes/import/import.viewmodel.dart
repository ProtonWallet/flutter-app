import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:wallet/helper/extension/stream.controller.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/wallet/proton.wallet.manager.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/scenes/core/coordinator.dart';
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
  bool isValidMnemonic = false;

  bool verifyMnemonic();

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
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  @override
  Future<void> importWallet() async {
    try {
      String walletName = nameTextController.text;
      // Validation for walletName if empty
      // if (walletName.isEmpty) throw Exception("Wallet name cannot be empty");
      String strMnemonic = mnemonicTextController.text;
      String strPassphrase = passphraseTextController.text;
      await WalletManager.createWallet(
          walletName,
          strMnemonic,
          WalletModel.importByUser,
          Provider.of<ProtonWalletProvider>(
                  Coordinator.navigatorKey.currentContext!,
                  listen: false)
              .protonWallet
              .newAccountFiatCurrency,
          strPassphrase);

      await WalletManager.autoBindEmailAddresses();
      await Future.delayed(
          const Duration(seconds: 1)); // wait for account show on sidebar
    } catch (e) {
      logger.e(e);
    }
  }

  @override
  Future<void> move(NavID to) async {}

  @override
  bool verifyMnemonic() {
    String strMnemonic = mnemonicTextController.text;
    final RegExp regex = RegExp(r'^[a-z ]*$');
    isValidMnemonic = false;
    bool matchPattern = regex.hasMatch(strMnemonic);
    if (matchPattern == false) {
      logger.i("pattern not match!");
      datasourceChangedStreamController.sinkAddSafe(this);
      return false;
    }
    int mnemonicLength = strMnemonic.split(" ").length;
    if (mnemonicLength != 12 && mnemonicLength != 18 && mnemonicLength != 24) {
      logger.i("length not match! ($mnemonicLength)");
      datasourceChangedStreamController.sinkAddSafe(this);
      return false;
    }
    datasourceChangedStreamController.sinkAddSafe(this);
    isValidMnemonic = true;
    return true;
  }
}
