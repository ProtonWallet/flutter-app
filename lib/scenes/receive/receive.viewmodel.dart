import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:sentry/sentry.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/exceptions.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/providers/local.bitcoin.address.provider.dart';
import 'package:wallet/managers/providers/proton.address.provider.dart';
import 'package:wallet/managers/providers/receive.address.data.provider.dart';
import 'package:wallet/managers/providers/wallet.data.provider.dart';
import 'package:wallet/managers/providers/wallet.keys.provider.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/rust/api/bdk_wallet/account.dart';
import 'package:wallet/rust/api/errors.dart';
import 'package:wallet/rust/api/proton_wallet/crypto/wallet_key_helper.dart';
import 'package:wallet/rust/common/address_info.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/receive/receive.coordinator.dart';

abstract class ReceiveViewModel extends ViewModel<ReceiveCoordinator> {
  ReceiveViewModel(
    super.coordinator,
    this.serverWalletID,
    this.serverAccountID, {
    required this.isWalletView,
  });

  String serverWalletID;
  String serverAccountID;

  String errorMessage = "";
  int localLastUsedIndex = -1;

  /// flags for UI
  bool isWalletView;
  bool initialized = false;
  bool loadingAddress = false;
  bool tooManyUnusedAddress = false;
  bool warnUnusedAddress = false;

  WalletData? walletData;
  WalletModel? walletModel;
  AccountModel? accountModel;
  late ValueNotifier accountValueNotifier;

  /// the address belongs to selected account, and will be displayed to user
  FrbAddressInfo? currentAddress;

  void getAddress();

  void generateNewAddress();

  void changeAccount(AccountModel newAccountModel);
}

class ReceiveViewModelImpl extends ReceiveViewModel {
  ReceiveViewModelImpl(
    super.coordinator,
    super.serverWalletID,
    super.serverAccountID,
    this.userManager,
    this.walletManager,
    this.walletDataProvider,
    this.protonAddressProvider,
    this.walletKeysProvider,
    this.localBitcoinAddressDataProvider,
    this.receiveAddressDataProvider, {
    required super.isWalletView,
  });

  late FrbAccount _frbAccount;

  final UserManager userManager;
  final WalletManager walletManager;
  final WalletsDataProvider walletDataProvider;
  final LocalBitcoinAddressDataProvider localBitcoinAddressDataProvider;
  final ProtonAddressProvider protonAddressProvider;
  final WalletKeysProvider walletKeysProvider;
  final ReceiveAddressDataProvider receiveAddressDataProvider;

  @override
  Future<void> loadData() async {
    try {
      walletData =
          await walletDataProvider.getWalletByServerWalletID(serverWalletID);
      walletModel = walletData?.wallet;
      for (AccountModel accModel in walletData?.accounts ?? []) {
        accModel.labelDecrypt =
            await decryptAccountName(base64Encode(accModel.label));
        final balance = await walletManager.getWalletAccountBalance(
          walletModel?.walletID ?? "",
          accModel.accountID,
        );
        accModel.balance = balance.toDouble();
        if (accModel.accountID == serverAccountID) {
          accountModel = accModel;
        }
      }
      accountModel ??= walletData?.accounts.firstOrNull;
      if (walletModel == null || accountModel == null) {
        errorMessage = "Can not load wallet or walletAccount";
      } else {
        accountValueNotifier = ValueNotifier(accountModel);
        accountValueNotifier.addListener(() {
          changeAccount(accountValueNotifier.value);
        });
        await changeAccount(accountModel!);
      }
    } on BridgeError catch (e, stacktrace) {
      errorMessage = parseSampleDisplayError(e);
      logger.e("importWallet error: $e, stacktrace: $stacktrace");
    } catch (e) {
      errorMessage = e.toString();
    }
    if (errorMessage.isNotEmpty) {
      CommonHelper.showErrorDialog(errorMessage);
      errorMessage = "";
    }
    initialized = true;
    sinkAddSafe();
  }

  @override
  Future<void> generateNewAddress() async {
    /// We will need to avoid user create too many unused address,
    /// or user may encounter the transaction is out of syncing stopGap issue.
    if (accountModel != null) {
      if (localLastUsedIndex + accountModel!.poolSize + 10 >=
          accountModel!.lastUsedIndex) {
        /// if the bitcoin address index still in safe range, allow user to generate new address
        if (localLastUsedIndex + accountModel!.poolSize + 5 <=
            accountModel!.lastUsedIndex) {
          /// shows warning when the address gap is near the stopGap
          warnUnusedAddress = true;
        }
        currentAddress = await receiveAddressDataProvider
            .generateNewReceiveAddress(_frbAccount, accountModel!);
        try {
          await DBHelper.bitcoinAddressDao!.insertOrUpdate(
            serverWalletID: walletModel!.walletID,
            serverAccountID: accountModel!.accountID,
            bitcoinAddress: currentAddress!.address,
            bitcoinAddressIndex: currentAddress!.index,
            inEmailIntegrationPool: 0,
            used: 0,
          );
        } catch (e, stacktrace) {
          Sentry.captureException(e, stackTrace: stacktrace);
          logger.e(e.toString());
        }
      } else {
        /// avoid to generate new address which will cause transaction is out of syncing stopGap issue.
        warnUnusedAddress = false;
        tooManyUnusedAddress = true;
      }
      sinkAddSafe();
    }
  }

  @override
  Future<void> getAddress() async {
    if (walletModel != null && accountModel != null) {
      currentAddress = await receiveAddressDataProvider.getReceiveAddress(
          _frbAccount, accountModel!);
      try {
        await DBHelper.bitcoinAddressDao!.insertOrUpdate(
          serverWalletID: walletModel!.walletID,
          serverAccountID: accountModel!.accountID,
          bitcoinAddress: currentAddress!.address,
          bitcoinAddressIndex: currentAddress!.index,
          inEmailIntegrationPool: 0,
          used: 0,
        );
      } catch (e, stacktrace) {
        Sentry.captureException(e, stackTrace: stacktrace);
        logger.e(e.toString());
      }
      sinkAddSafe();
    }
  }

  Future<String> decryptAccountName(String encryptedName) async {
    String decryptedName = defaultWalletAccountName;
    try {
      final unlockedWalletKey = await walletKeysProvider.getWalletSecretKey(
        serverWalletID,
      );
      decryptedName = FrbWalletKeyHelper.decrypt(
        base64SecureKey: unlockedWalletKey.toBase64(),
        encryptText: encryptedName,
      );
    } catch (e) {
      logger.e(e.toString());
    }
    return decryptedName;
  }

  @override
  Future<void> move(NavID to) async {}

  @override
  Future<void> changeAccount(AccountModel newAccountModel) async {
    loadingAddress = true;
    sinkAddSafe();
    try {
      tooManyUnusedAddress = false;
      warnUnusedAddress = false;
      accountModel = newAccountModel;
      accountModel?.labelDecrypt =
          await decryptAccountName(base64Encode(accountModel!.label));

      /// check if local highest used bitcoin address index is higher than the one store in wallet account
      /// this will happen when some one send bitcoin via qr code
      localLastUsedIndex = await localBitcoinAddressDataProvider
          .getLastUsedIndex(walletModel, accountModel);
      _frbAccount = (await walletManager.loadWalletWithID(
        walletModel!.walletID,
        accountModel!.accountID,
        serverScriptType: accountModel!.scriptType,
      ))!;

      await receiveAddressDataProvider.handleLastUsedIndexOnNetwork(
          _frbAccount, accountModel!, localLastUsedIndex);
      currentAddress = null;
      await getAddress();
    } catch (e) {
      logger.e(e.toString());
    }
    loadingAddress = false;
    sinkAddSafe();
  }
}
