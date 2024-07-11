import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:wallet/constants/app.config.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/script_type.dart';
import 'package:wallet/helper/exceptions.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/extension/stream.controller.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/features/create.wallet.bloc.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/providers/wallet.data.provider.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/rust/api/bdk_wallet/mnemonic.dart';
import 'package:wallet/rust/common/errors.dart';
import 'package:wallet/rust/common/network.dart';
import 'package:wallet/rust/proton_api/proton_address.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/import/import.coordinator.dart';
import 'package:wallet/rust/api/proton_api.dart' as proton_api;

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
  late ValueNotifier<FiatCurrency> fiatCurrencyNotifier;

  bool isPasteMode = true;
  String errorMessage = "";
  bool isValidMnemonic = false;
  bool isFirstWallet = false;
  bool isImporting = false;
  List<ProtonAddress> protonAddresses = [];

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
    fiatCurrencyNotifier = ValueNotifier(defaultFiatCurrency);
    nameTextController.text = preInputWalletName;

    List<ProtonAddress> addresses = await proton_api.getProtonAddress();
    protonAddresses =
        addresses.where((element) => element.status == 1).toList();

    List<WalletData>? wallets =
        await dataProviderManager.walletDataProvider.getWallets();
    if (wallets == null) {
      isFirstWallet = true;
    } else if (wallets.isEmpty) {
      isFirstWallet = true;
    }
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

      var apiWalletAccount = await createWalletBloc.createWalletAccount(
        apiWallet.wallet.id,
        scriptTypeInfo,
        "My wallet account",
        defaultFiatCurrency,
        0, // default wallet account index
      );
      if (isFirstWallet) {
        /// Auto bind email address if it's first wallet
        String walletID = apiWallet.wallet.id;
        String accountID = apiWalletAccount.id;
        WalletModel? walletModel =
            await DBHelper.walletDao!.findByServerID(walletID);
        AccountModel? accountModel =
            await DBHelper.accountDao!.findByServerID(accountID);
        if (walletModel != null && accountModel != null) {
          ProtonAddress? protonAddress = protonAddresses.firstOrNull;
          if (protonAddress != null) {
            await addEmailAddressToWalletAccount(
              walletID,
              walletModel,
              accountModel,
              protonAddress.id,
            );
          }
        }
      }
    } on BridgeError catch (e, stacktrace) {
      errorMessage = parseSampleDisplayError(e);
      logger.e("importWallet error: $e, stacktrace: $stacktrace");
    } catch (e, stacktrace) {
      logger.e("importWallet error: $e, stacktrace: $stacktrace");
    }
  }

  @override
  Future<void> move(NavID to) async {}

  Future<void> addEmailAddressToWalletAccount(
    String serverWalletID,
    WalletModel walletModel,
    AccountModel accountModel,
    String serverAddressID,
  ) async {
    try {
      await WalletManager.addEmailAddress(
        serverWalletID,
        accountModel.accountID,
        serverAddressID,
      );
      dataProviderManager.walletDataProvider.notifyUpdateEmailIntegration();
    } catch (e) {
      errorMessage = e.toString();
    }
    if (errorMessage.isNotEmpty) {
      CommonHelper.showErrorDialog(errorMessage);
      errorMessage = "";
    }
  }

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
