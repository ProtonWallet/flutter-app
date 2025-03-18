import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:wallet/constants/app.config.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/helper/common.helper.dart';
import 'package:wallet/helper/exceptions.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/providers/user.settings.data.provider.dart';
import 'package:wallet/managers/providers/wallet.data.provider.dart';
import 'package:wallet/managers/providers/wallet.name.provider.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/rust/api/bdk_wallet/account.dart';
import 'package:wallet/rust/api/bdk_wallet/account_sweeper.dart';
import 'package:wallet/rust/api/bdk_wallet/blockchain.dart';
import 'package:wallet/rust/api/bdk_wallet/psbt.dart';
import 'package:wallet/rust/api/errors.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/paper.wallet/paper.wallet.coordinator.dart';

enum PageStatus {
  importPaperWallet,
  verifyBalance,
}

abstract class PaperWalletViewModel extends ViewModel<PaperWalletCoordinator> {
  PaperWalletViewModel(
    super.coordinator,
    this.walletModel,
    this.accountModel,
    this.receiveAddressIndex,
  );

  final WalletModel walletModel;
  final AccountModel accountModel;
  final int receiveAddressIndex;
  FrbPsbt? draftPsbt;
  PageStatus pageStatus = PageStatus.importPaperWallet;
  String importedError = "";
  String walletName = "";
  String accountName = "";
  late TextEditingController privateKeyController;
  late FocusNode privateKeyFocusNode;

  void updatePageStatus(status);

  int getDisplayDigits();

  String getFiatCurrencyName();

  String getFiatCurrencySign();

  ProtonExchangeRate getExchangeRate();

  BitcoinUnit getBitcoinUnit();

  int getTransactionAmount();

  int getTransactionFee();

  void clearImportedError();

  Future<void> tryImportWithPrivateKey();

  Future<bool> broadcast();
}

class PaperWalletViewModelImpl extends PaperWalletViewModel {
  PaperWalletViewModelImpl(
    super.coordinator,
    super.walletModel,
    super.accountModel,
    super.receiveAddressIndex,
    this.blockChainClient,
    this.userSettingsDataProvider,
    this.walletDataProvider,
    this.walletNameProvider,
    this.walletManager,
  );

  final UserSettingsDataProvider userSettingsDataProvider;
  final WalletsDataProvider walletDataProvider;
  final WalletNameProvider walletNameProvider;
  final WalletManager walletManager;
  final FrbBlockchainClient blockChainClient;
  FrbAccount? frbAccount;

  @override
  Future<void> loadData() async {
    /// initialize UI components
    privateKeyController = TextEditingController();
    privateKeyFocusNode = FocusNode();
    walletName = await walletNameProvider.getNameWithID(walletModel.walletID);
    accountName =
        await walletNameProvider.getAccountLabelWithID(accountModel.accountID);

    /// initialize frbWallet and blockClient
    frbAccount = (await walletManager.loadWalletWithID(
      walletModel.walletID,
      accountModel.accountID,
      serverScriptType: accountModel.scriptType,
    ));
    sinkAddSafe();
  }

  @override
  Future<void> move(NavID to) async {}

  @override
  void updatePageStatus(status) {
    pageStatus = status;
    sinkAddSafe();
  }

  @override
  Future<void> tryImportWithPrivateKey() async {
    clearImportedError();
    final privateKey = privateKeyController.text.trim();

    if (frbAccount != null) {
      final fees = await blockChainClient.getFeesEstimation();
      final feeRateSatPerVb = (fees["1"] ?? 0).ceil();

      final accountSweeper = FrbAccountSweeper(
        client: blockChainClient,
        account: frbAccount!,
      );

      try {
        draftPsbt = await accountSweeper.psbtSweepFromWif(
          wif: privateKey,
          satPerVb: BigInt.from(feeRateSatPerVb),
          receiveAddressIndex: receiveAddressIndex,
          network: appConfig.coinType.network,
        );
        if (draftPsbt != null) {
          updatePageStatus(PageStatus.verifyBalance);
        }
      } on BridgeError catch (e) {
        importedError = e.localizedString;
        sinkAddSafe();
      } catch (e) {
        CommonHelper.showErrorDialog(
          e.toString(),
        );
      }
    } else {
      /// something went wrong when load frbAccount / blockClient
      CommonHelper.showErrorDialog(
        "Cannot initialized frbAccount / blockClient, please try again later",
      );
    }
  }

  @override
  String getFiatCurrencyName() {
    return userSettingsDataProvider.getFiatCurrencyName();
  }

  @override
  String getFiatCurrencySign() {
    return userSettingsDataProvider.getFiatCurrencySign();
  }

  @override
  int getDisplayDigits() {
    int displayDigits = defaultDisplayDigits;
    displayDigits =
        (log(userSettingsDataProvider.exchangeRate.cents.toInt()) / log(10))
            .round();
    return displayDigits;
  }

  @override
  ProtonExchangeRate getExchangeRate() {
    return userSettingsDataProvider.exchangeRate;
  }

  @override
  BitcoinUnit getBitcoinUnit() {
    return userSettingsDataProvider.bitcoinUnit;
  }

  @override
  int getTransactionAmount() {
    if (draftPsbt == null) {
      return 0;
    }
    return draftPsbt!.recipients.first.field1.toInt();
  }

  @override
  int getTransactionFee() {
    if (draftPsbt == null) {
      return 0;
    }
    return draftPsbt!.fee().toSat().toInt();
  }

  @override
  Future<bool> broadcast() async {
    try {
      final txid = await blockChainClient.broadcastPsbt(
        psbt: draftPsbt!,
        walletId: walletModel.walletID,
        walletAccountId: accountModel.accountID,
        exchangeRateId: userSettingsDataProvider.exchangeRate.id,
        isAnonymous: 0,
      );
      logger.i(txid);
      await walletDataProvider.newBroadcastTransaction();
      return true;
    } catch (e) {
      CommonHelper.showErrorDialog(
        e.toString(),
      );
    }
    return false;
  }

  @override
  void clearImportedError() {
    importedError = "";
    sinkAddSafe();
  }
}
