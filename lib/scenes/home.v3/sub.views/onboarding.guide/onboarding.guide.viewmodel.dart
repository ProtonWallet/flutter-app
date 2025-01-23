import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:sentry/sentry.dart';
import 'package:wallet/constants/app.config.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/helper/common.helper.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/exceptions.dart';
import 'package:wallet/helper/extension/response.error.extension.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/app.state.manager.dart';
import 'package:wallet/managers/features/wallet.list/wallet.list.bloc.dart';
import 'package:wallet/managers/features/wallet/create.wallet.bloc.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/providers/wallet.data.provider.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/rust/api/bdk_wallet/mnemonic.dart';
import 'package:wallet/rust/api/errors.dart';
import 'package:wallet/rust/common/word_count.dart';
import 'package:wallet/rust/proton_api/proton_address.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/onboarding.guide/onboarding.guide.coordinator.dart';

abstract class OnboardingGuideViewModel
    extends ViewModel<OnboardingGuideCoordinator> {
  final WalletManager walletManager;
  final AppStateManager appStateManager;
  final DataProviderManager dataProviderManager;
  final WalletListBloc walletListBloc;
  final CreateWalletBloc createWalletBloc;
  bool firstWallet = false;
  bool initialized = false;

  String errorMessage = "";

  bool passphraseMatched = true;
  bool isCreatingWallet = false;

  List<ProtonAddress> protonAddresses = [];

  late TextEditingController nameTextController;
  late TextEditingController passphraseTextController;
  late TextEditingController passphraseConfirmTextController;
  late FocusNode walletNameFocusNode;
  late FocusNode passphraseFocusNode;
  late FocusNode passphraseConfirmFocusNode;
  ValueNotifier<FiatCurrency> fiatCurrencyNotifier =
      ValueNotifier(defaultFiatCurrency);

  void updateCreatingWalletStatus(creating);

  void checkPassphraseMatched();

  Future<bool> createWallet();

  void showImportWallet(String preInputName) {
    coordinator.showImportWallet(preInputName);
  }

  OnboardingGuideViewModel(
    super.coordinator,
    this.walletManager,
    this.appStateManager,
    this.dataProviderManager,
    this.walletListBloc,
    this.createWalletBloc,
  );
}

class OnboardingGuideViewModelImpl extends OnboardingGuideViewModel {
  OnboardingGuideViewModelImpl(
    super.coordinator,
    super.walletManager,
    super.appStateManager,
    super.dataProviderManager,
    super.walletListBloc,
    super.createWalletBloc,
  );

  Future<void> loadProtonAddresses() async {
    try {
      protonAddresses =
          await dataProviderManager.addressKeyProvider.getAddresses();
    } catch (e) {
      errorMessage = e.toString();
    }
  }

  @override
  Future<void> loadData() async {
    /// check if it's first wallet
    final List<WalletData>? wallets =
        await walletListBloc.walletsDataProvider.getWallets();
    if (wallets == null) {
      firstWallet = true;
    } else if (wallets.isEmpty) {
      firstWallet = true;
    }

    /// init controllers and focusNodes
    nameTextController =
        TextEditingController(text: firstWallet ? defaultWalletName : "");
    passphraseTextController = TextEditingController(text: "");
    passphraseConfirmTextController = TextEditingController(text: "");
    walletNameFocusNode = FocusNode();
    passphraseFocusNode = FocusNode();
    passphraseConfirmFocusNode = FocusNode();

    await loadProtonAddresses();
    initialized = true;
    sinkAddSafe();
  }

  @override
  Future<void> move(NavID to) async {}

  @override
  void updateCreatingWalletStatus(creating) {
    isCreatingWallet = creating;
    sinkAddSafe();
  }

  @override
  void checkPassphraseMatched() {
    passphraseMatched =
        passphraseTextController.text == passphraseConfirmTextController.text;
    sinkAddSafe();
  }

  @override
  Future<bool> createWallet() async {
    WalletModel? walletModel;
    AccountModel? accountModel;

    try {
      final FrbMnemonic mnemonic = FrbMnemonic(wordCount: WordCount.words12);
      final String strMnemonic = mnemonic.asString();
      final String walletName = nameTextController.text;
      final String strPassphrase = passphraseTextController.text;

      final apiWallet = await createWalletBloc.createWallet(
        walletName,
        strMnemonic,
        appConfig.coinType.network,
        WalletModel.createByProton,
        strPassphrase,
      );

      /// default Primary Account (without BvE)
      final apiWalletAccount = await createWalletBloc.createWalletAccount(
        apiWallet.wallet.id,
        appConfig.scriptTypeInfo,
        "Primary Account",
        fiatCurrencyNotifier.value,
        0,
      );

      /// Auto create Bitcoin via Email account at 84'/0'/1'
      if (firstWallet) {
        final apiWalletAccountBvE = await createWalletBloc.createWalletAccount(
          apiWallet.wallet.id,
          appConfig.scriptTypeInfo,
          "Bitcoin via Email",
          fiatCurrencyNotifier.value,
          1,
        );
        final String walletID = apiWallet.wallet.id;
        walletModel = await DBHelper.walletDao!.findByServerID(walletID);

        final String accountID = apiWalletAccountBvE.id;
        accountModel = await DBHelper.accountDao!.findByServerID(accountID);
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
      } else {
        final String walletID = apiWallet.wallet.id;
        walletModel = await DBHelper.walletDao!.findByServerID(walletID);
        final String accountID = apiWalletAccount.id;
        accountModel = await DBHelper.accountDao!.findByServerID(accountID);
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
      if (!appStateManager.updateStateFrom(e)) {
        final responsError = parseResponseError(e);
        if (responsError != null && responsError.isCreationLimition()) {
          if (defaultTargetPlatform == TargetPlatform.iOS) {
            CommonHelper.showInfoDialog(responsError.error);
            errorMessage = "";
            return false;
          } else {
            errorMessage = "";
            coordinator.showUpgrade();
          }
          return false;
        }

        final msg = parseSampleDisplayError(e);
        CommonHelper.showErrorDialog(msg);
      }
      logger.e("importWallet error: $e, stacktrace: $stacktrace");
      Sentry.captureException(e, stackTrace: stacktrace);
      return false;
    } catch (e, stacktrace) {
      CommonHelper.showErrorDialog(e.toString());
      Sentry.captureException(e, stackTrace: stacktrace);
      return false;
    }

    return true;
  }

  Future<bool> addEmailAddressToWalletAccount(
    String serverWalletID,
    WalletModel walletModel,
    AccountModel accountModel,
    String serverAddressID,
  ) async {
    try {
      /// update db tables
      await walletManager.addEmailAddress(
        serverWalletID,
        accountModel.accountID,
        serverAddressID,
      );

      /// update memory caches
      walletListBloc.addEmailIntegration(
        walletModel,
        accountModel,
        serverAddressID,
      );
    } on BridgeError catch (e, stacktrace) {
      if (!appStateManager.updateStateFrom(e)) {
        errorMessage = parseSampleDisplayError(e);
      }
      logger.e("importWallet error: $e, stacktrace: $stacktrace");
    } catch (e) {
      errorMessage = e.toString();
    }
    if (errorMessage.isNotEmpty) {
      CommonHelper.showErrorDialog(errorMessage);
      errorMessage = "";
      return false;
    }
    return true;
  }
}
