import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:wallet/constants/app.config.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/script_type.dart';
import 'package:wallet/helper/extension/stream.controller.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/features/create.wallet.bloc.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/rust/api/bdk_wallet/mnemonic.dart';
import 'package:wallet/rust/common/network.dart';
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
  (bool, String) mnemonicValidation(String strMnemonic);

  Future<void> importWallet();
}

class ImportViewModelImpl extends ImportViewModel {
  final DataProviderManager dataProviderManager;

  final String preInputWalletName;

  final CreateWalletBloc createWalletBloc;

  ImportViewModelImpl(
    super.coordinator,
    this.dataProviderManager,
    this.preInputWalletName,
    this.createWalletBloc,
  );

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
    nameTextController.text = preInputWalletName;
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
      Network network = appConfig.coinType.network;
      ScriptTypeInfo scriptTypeInfo = appConfig.scriptTypeInfo;

      var apiWallet = await createWalletBloc.createWallet(
        walletName,
        strMnemonic,
        network,
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

  @override
  (bool, String) mnemonicValidation(String strMnemonic) {
    final mnemonicLength = strMnemonic.split(" ");
    final length = mnemonicLength.length;
    for (var i = 0; i < mnemonicLength.length; i++) {
      var word = mnemonicLength[i];
      if (!FrbMnemonic.getWordsAutocomplete(wordStart: word)
          .contains(mnemonicLength[i])) {
        var pending = "\nWord: `$word`";
        return (false, pending);
      }
    }
    if (length != 12 && length != 18 && length != 24) {
      logger.i("length not match! ($mnemonicLength)");
      var pending = "\nLength: $length";
      return (false, pending);
    }

    return (true, "");
  }
}
