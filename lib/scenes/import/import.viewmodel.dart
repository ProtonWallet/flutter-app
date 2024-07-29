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
import 'package:wallet/managers/features/create.wallet.bloc.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/providers/wallet.data.provider.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/drift/db/app.database.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/rust/api/api_service/proton_api_service.dart';
import 'package:wallet/rust/api/bdk_wallet/mnemonic.dart';
import 'package:wallet/rust/api/bdk_wallet/storage.dart';
import 'package:wallet/rust/api/bdk_wallet/wallet.dart';
import 'package:wallet/rust/api/proton_api.dart' as proton_api;
import 'package:wallet/rust/common/errors.dart';
import 'package:wallet/rust/common/network.dart';
import 'package:wallet/rust/proton_api/proton_address.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/bottom.sheet/upgrade.intro.dart';
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

  final CreateWalletBloc createWalletBloc;

  ImportViewModelImpl(
    super.coordinator,
    super.dataProviderManager,
    this.preInputWalletName,
    this.createWalletBloc,
    this.apiService,
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

    final List<ProtonAddress> addresses = await proton_api.getProtonAddress();
    protonAddresses =
        addresses.where((element) => element.status == 1).toList();

    final List<WalletData>? wallets =
        await dataProviderManager.walletDataProvider.getWallets();
    if (wallets == null) {
      isFirstWallet = true;
    } else if (wallets.isEmpty) {
      isFirstWallet = true;
    }
  }

  @override
  Future<bool> importWallet() async {
    WalletModel? walletModel;
    AccountModel? accountModel;
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

      final dbPath = await WalletManager.getDatabaseFolderPath();
      final storage = OnchainStoreFactory(folderPath: dbPath);
      final foundAccounts = await frbWallet.discoverAccount(
          apiService: apiService,
          storageFactory: storage,
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
        }
      } else {
        final apiWalletAccount = await createWalletBloc.createWalletAccount(
          apiWallet.wallet.id,
          scriptTypeInfo,
          "Primary Account",
          fiatCurrencyNotifier.value,
          0, // default wallet account index
        );
        final String walletID = apiWallet.wallet.id;
        final String accountID = apiWalletAccount.id;
        walletModel = await DBHelper.walletDao!.findByServerID(walletID);
        accountModel = await DBHelper.accountDao!.findByServerID(accountID);
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
      }
    } on BridgeError catch (e, stacktrace) {
      logger.e("importWallet error: $e, stacktrace: $stacktrace");
      Sentry.captureException(e, stackTrace: stacktrace);

      final limitError = parseUserLimitationError(e);
      if (limitError != null) {
        final BuildContext? context =
            Coordinator.rootNavigatorKey.currentContext;
        if (context != null && context.mounted) {
          UpgradeIntroSheet.show(context, () async {
            await move(NavID.nativeUpgrade);
          });
        }
      } else {
        errorMessage = parseSampleDisplayError(e);
      }
      return false;
    } catch (e, stacktrace) {
      logger.e("importWallet error: $e, stacktrace: $stacktrace");
      Sentry.captureException(e, stackTrace: stacktrace);
      errorMessage = e.toString();
    }
    if (walletModel != null && accountModel != null) {
      dataProviderManager.bdkTransactionDataProvider.syncWallet(
        walletModel,
        accountModel,
        forceSync: true,
      );
    }
    if (errorMessage.isNotEmpty) {
      return false;
    }
    return true;
  }

  @override
  Future<void> move(NavID to) async {
    switch (to) {
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
