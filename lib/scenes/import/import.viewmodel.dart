import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/helper/extension/stream.controller.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/import/import.coordinator.dart';

abstract class ImportViewModel extends ViewModel<ImportCoordinator> {
  ImportViewModel(
    super.coordinator,
  );

  late TextEditingController mnemonicTextController;
  late TextEditingController nameTextController;
  late TextEditingController passphraseTextController;
  late FocusNode mnemonicFocusNode;
  late FocusNode nameFocusNode;
  late FocusNode passphraseFocusNode;
  bool isPasteMode = true;
  String errorMessage = "";
  bool isValidMnemonic = false;

  void switchToManualInputMode();

  void switchToPasteMode();

  void updateValidMnemonic(bool isValidMnemonic);

  Future<void> importWallet();
}

class ImportViewModelImpl extends ImportViewModel {
  final DataProviderManager dataProviderManager;

  ImportViewModelImpl(super.coordinator, this.dataProviderManager);

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
      await dataProviderManager.walletDataProvider.createWallet(
          walletName,
          strMnemonic,
          WalletModel.importByUser,
          defaultFiatCurrency,
          strPassphrase);
      await Future.delayed(
          const Duration(seconds: 1)); // wait for account show on sidebar
    } catch (e) {
      errorMessage = e.toString();
    }
  }

  @override
  Future<void> move(NavID to) async {}

  @override
  void switchToManualInputMode() {
    isPasteMode = false;
    datasourceChangedStreamController.sinkAddSafe(this);
  }

  @override
  void switchToPasteMode() {
    isPasteMode = true;
    datasourceChangedStreamController.sinkAddSafe(this);
  }

  @override
  void updateValidMnemonic(bool isValidMnemonic) {
    this.isValidMnemonic = isValidMnemonic;
    datasourceChangedStreamController.sinkAddSafe(this);
  }
}
