import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:sentry/sentry.dart';
import 'package:wallet/constants/app.config.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/script_type.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/exceptions.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/helper/path.helper.dart';
import 'package:wallet/managers/features/wallet/create.wallet.bloc.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/providers/wallet.data.provider.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/drift/db/app.database.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/rust/api/api_service/proton_api_service.dart';
import 'package:wallet/rust/api/api_service/proton_email_addr_client.dart';
import 'package:wallet/rust/api/bdk_wallet/mnemonic.dart';
import 'package:wallet/rust/api/bdk_wallet/storage.dart';
import 'package:wallet/rust/api/bdk_wallet/wallet.dart';
import 'package:wallet/rust/api/errors.dart';
import 'package:wallet/rust/common/network.dart';
import 'package:wallet/rust/proton_api/proton_address.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/import/import.coordinator.dart';

abstract class ImportViewModel extends ViewModel<ImportCoordinator> {
  ImportViewModel(
    super.coordinator,
    this.dataProviderManager,
  );

  final DataProviderManager dataProviderManager;
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
  bool hitWalletAccountLimit = false;
  bool acceptTermsAndConditions = false;
  List<ProtonAddress> protonAddresses = [];

  void switchToManualInputMode();

  void switchToPasteMode();

  void updateValidMnemonic({required bool isValidMnemonic});

  (bool, String) mnemonicValidation(String strMnemonic);

  Future<bool> importWallet();
}

class ImportViewModelImpl extends ImportViewModel {
  final String preInputWalletName;
  final ProtonApiService apiService;
  final WalletManager walletManager;
  final ProtonEmailAddressClient protonEmailAddressClient;

  final CreateWalletBloc createWalletBloc;

  ImportViewModelImpl(
    super.coordinator,
    super.dataProviderManager,
    this.preInputWalletName,
    this.createWalletBloc,
    this.apiService,
    this.walletManager,
    this.protonEmailAddressClient,
  );

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
    final WalletUserSettings? walletUserSettings =
        await dataProviderManager.userSettingsDataProvider.getSettings();
    if (walletUserSettings != null) {
      acceptTermsAndConditions = walletUserSettings.acceptTermsAndConditions;
    }

    final addresses = await protonEmailAddressClient.getProtonAddress();

    /// filter active address
    protonAddresses =
        addresses.where((element) => element.status == 1).toList();

    final List<WalletData>? wallets =
        await dataProviderManager.walletDataProvider.getWallets();
    if (wallets == null || wallets.isEmpty) {
      /// set flag for first wallet, we will need to show T&C page for first wallet import
      isFirstWallet = true;
    }
    sinkAddSafe();
  }

  @override
  Future<bool> importWallet() async {
    try {
      final String walletName = nameTextController.text;
      final String strMnemonic = mnemonicTextController.text;
      final String strPassphrase = passphraseTextController.text;
      final Network network = appConfig.coinType.network;
      final ScriptTypeInfo scriptTypeInfo = appConfig.scriptTypeInfo;

      final apiWallet = await createWalletBloc.createWallet(
        walletName,
        strMnemonic,
        network,
        WalletModel.importByUser,
        strPassphrase,
      );

      /// get fingerprint from mnemonic
      final frbWallet = FrbWallet(
        network: network,
        bip39Mnemonic: strMnemonic,
        bip38Passphrase: strPassphrase.isNotEmpty ? strPassphrase : null,
      );

      final dbPath = await getDatabaseFolderPath();
      final storage = WalletMobileConnectorFactory(folderPath: dbPath);
      final foundAccounts = await frbWallet.discoverAccount(
          apiService: apiService.getArc(),
          connectorFactory: storage,
          accountStopGap: 1,
          addressStopGap: BigInt.from(10));

      if (foundAccounts.isNotEmpty) {
        var count = 1;
        for (var element in foundAccounts) {
          final sTypeInfo = ScriptTypeInfo.lookupByType(element.scriptType);
          if (sTypeInfo == null) continue;
          final apiWalletAccount = await createWalletBloc.createWalletAccount(
            apiWallet.wallet.id,
            sTypeInfo,
            "Account $count",
            fiatCurrencyNotifier.value,
            element.index,
          );
          count += 1;
          logger.d("new account: ${apiWalletAccount.label}");
          final String walletID = apiWallet.wallet.id;
          final String accountID = apiWalletAccount.id;
          final walletModel = await DBHelper.walletDao!.findByServerID(
            walletID,
          );
          final accountModel = await DBHelper.accountDao!.findByServerID(
            accountID,
          );
          if (walletModel != null && accountModel != null) {
            dataProviderManager.bdkTransactionDataProvider.syncWallet(
              walletModel,
              accountModel,
              forceSync: true,
              heightChanged: false,
            );
          }
        }
      } else {
        final apiWalletAccount = await createWalletBloc.createWalletAccount(
          apiWallet.wallet.id,
          scriptTypeInfo,
          "Primary Account",
          fiatCurrencyNotifier.value,
          0,
        );
        final String walletID = apiWallet.wallet.id;
        final String accountID = apiWalletAccount.id;
        final walletModel = await DBHelper.walletDao!.findByServerID(
          walletID,
        );
        final accountModel = await DBHelper.accountDao!.findByServerID(
          accountID,
        );
        if (isFirstWallet) {
          /// Auto bind email address if it's first wallet
          if (walletModel != null && accountModel != null) {
            final ProtonAddress? protonAddress = protonAddresses.firstOrNull;
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
        if (walletModel != null && accountModel != null) {
          dataProviderManager.bdkTransactionDataProvider.syncWallet(
            walletModel,
            accountModel,
            forceSync: true,
            heightChanged: false,
          );
        }
      }
    } on BridgeError catch (e, stacktrace) {
      logger.e("importWallet error: $e, stacktrace: $stacktrace");
      Sentry.captureException(e, stackTrace: stacktrace);

      final limitError = parseUserLimitationError(e);
      if (limitError != null) {
        hitWalletAccountLimit = true;
        return true;
      } else {
        errorMessage = parseSampleDisplayError(e);
      }
    } catch (e, stacktrace) {
      logger.e("importWallet error: $e, stacktrace: $stacktrace");
      Sentry.captureException(e, stackTrace: stacktrace);
      errorMessage = e.toString();
    }

    if (errorMessage.isNotEmpty) {
      return false;
    }
    return true;
  }

  @override
  Future<void> move(NavID to) async {
    switch (to) {
      case NavID.importSuccess:
        coordinator.showImportSuccess();
      case NavID.nativeUpgrade:
      default:
        break;
    }
  }

  Future<void> addEmailAddressToWalletAccount(
    String serverWalletID,
    WalletModel walletModel,
    AccountModel accountModel,
    String serverAddressID,
  ) async {
    /// enable BvE for given account with given addressID
    try {
      await walletManager.addEmailAddress(
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
    sinkAddSafe();
  }

  @override
  void switchToPasteMode() {
    isPasteMode = true;
    sinkAddSafe();
  }

  @override
  void updateValidMnemonic({required bool isValidMnemonic}) {
    this.isValidMnemonic = isValidMnemonic;
    sinkAddSafe();
  }

  @override
  (bool, String) mnemonicValidation(String strMnemonic) {
    final mnemonicLength = strMnemonic.split(" ");
    final length = mnemonicLength.length;
    for (var i = 0; i < mnemonicLength.length; i++) {
      final word = mnemonicLength[i];
      if (!FrbMnemonic.getWordsAutocomplete(wordStart: word)
          .contains(mnemonicLength[i])) {
        final pending = "\nWord: `$word`";
        return (false, pending);
      }
    }
    if (length != 12 && length != 18 && length != 24) {
      logger.i("length not match! ($mnemonicLength)");
      final pending = "\nLength: $length";
      return (false, pending);
    }

    return (true, "");
  }
}
