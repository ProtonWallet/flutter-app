import 'dart:async';
import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/widgets.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/exceptions.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/helper/walletkey_helper.dart';
import 'package:wallet/managers/providers/local.bitcoin.address.provider.dart';
import 'package:wallet/managers/providers/proton.address.provider.dart';
import 'package:wallet/managers/providers/wallet.data.provider.dart';
import 'package:wallet/managers/providers/wallet.keys.provider.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/managers/wallet/proton.wallet.provider.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/address.model.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/rust/api/bdk_wallet/account.dart';
import 'package:wallet/rust/common/errors.dart';
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
  int addressIndex = -1;

  bool isWalletView;

  String address = "";
  String errorMessage = "";
  var selectedWallet = 1;
  int accountsCount = 0;
  int localLastUsedIndex = -1;
  bool initialized = false;

  WalletData? walletData;
  WalletModel? walletModel;
  bool hasEmailIntegration = false;
  AccountModel? accountModel;
  late ProtonWalletProvider protonWalletProvider;
  late ValueNotifier accountValueNotifier;

  List<String> emailIntegrationAddresses = [];

  String bitcoinViaEmailAddress = "";

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
    this.walletDataProvider,
    this.protonAddressProvider,
    this.walletKeysProvider,
    this.localBitcoinAddressDataProvider, {
    required super.isWalletView,
  });

  late FrbAccount _frbAccount;

  SecretKey? secretKey;

  final UserManager userManager;
  final WalletsDataProvider walletDataProvider;
  final LocalBitcoinAddressDataProvider localBitcoinAddressDataProvider;
  final ProtonAddressProvider protonAddressProvider;
  final WalletKeysProvider walletKeysProvider;

  @override
  Future<void> loadData() async {
    try {
      walletData =
          await walletDataProvider.getWalletByServerWalletID(serverWalletID);
      walletModel = walletData?.wallet;
      for (AccountModel accModel in walletData?.accounts ?? []) {
        accModel.labelDecrypt =
            await decryptAccountName(base64Encode(accModel.label));
        final balance = await WalletManager.getWalletAccountBalance(
          walletModel?.walletID ?? "",
          accModel.accountID,
        );
        accModel.balance = balance.toDouble();
        if (accModel.accountID == serverAccountID) {
          accountModel = accModel;
        }
      }
      accountsCount = walletData?.accounts.length ?? 0;
      accountModel ??= walletData?.accounts.firstOrNull;
      if (walletModel == null || accountModel == null) {
        errorMessage = "[Error-404] Can not load wallet or walletAccount";
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
    if (accountModel != null) {
      accountModel!.lastUsedIndex = accountModel!.lastUsedIndex + 1;
      await WalletManager.updateLastUsedIndex(accountModel!);
      getAddress();
    }
  }

  @override
  Future<void> getAddress({bool init = false}) async {
    if (walletModel != null && accountModel != null) {
      if (localLastUsedIndex == -1 && accountModel!.lastUsedIndex == 0) {
        addressIndex = accountModel!.lastUsedIndex;
      } else {
        addressIndex = accountModel!.lastUsedIndex + 1;
      }
      if (init) {
        _frbAccount = (await WalletManager.loadWalletWithID(
          walletModel!.walletID,
          accountModel!.accountID,
          serverScriptType: accountModel!.scriptType,
        ))!;
        emailIntegrationAddresses = await WalletManager.getAccountAddressIDs(
          accountModel?.accountID ?? "",
        );
        if (emailIntegrationAddresses.isNotEmpty) {
          final AddressModel? addressModel = await protonAddressProvider
              .getAddressModel(emailIntegrationAddresses.first);
          if (addressModel != null) {
            bitcoinViaEmailAddress = addressModel.email;
          }
        }
        hasEmailIntegration = emailIntegrationAddresses.isNotEmpty;
      }
      final addressInfo = await _frbAccount.getAddress(index: addressIndex);
      address = addressInfo.address;
      try {
        await DBHelper.bitcoinAddressDao!.insertOrUpdate(
          serverWalletID: walletModel!.walletID,
          serverAccountID: accountModel!.accountID,
          bitcoinAddress: address,
          bitcoinAddressIndex: addressIndex,
          inEmailIntegrationPool: 0,
          used: 0,
        );
      } catch (e) {
        logger.e(e.toString());
      }
      sinkAddSafe();
    }
  }

  Future<String> decryptAccountName(String encryptedName) async {
    if (secretKey == null) {
      final walletKey = await walletKeysProvider.getWalletKey(
        serverWalletID,
      );
      if (walletKey != null) {
        final userKey = await userManager.getUserKey(walletKey.userKeyId);
        secretKey = WalletKeyHelper.decryptWalletKey(
          userKey,
          walletKey,
        );
      }
    }
    String decryptedName = "Default Wallet Account";
    if (secretKey != null) {
      try {
        decryptedName = await WalletKeyHelper.decrypt(
          secretKey!,
          encryptedName,
        );
      } catch (e) {
        logger.e(e.toString());
      }
    }
    return decryptedName;
  }

  @override
  Future<void> move(NavID to) async {}

  @override
  Future<void> changeAccount(AccountModel newAccountModel) async {
    try {
      accountModel = newAccountModel;
      accountModel?.labelDecrypt =
          await decryptAccountName(base64Encode(accountModel!.label));

      /// check if local highest used bitcoin address index is higher than the one store in wallet account
      /// this will happen when some one send bitcoin via qr code
      localLastUsedIndex = await localBitcoinAddressDataProvider
          .getLastUsedIndex(walletModel, accountModel);
      if (localLastUsedIndex > accountModel!.lastUsedIndex) {
        accountModel!.lastUsedIndex = localLastUsedIndex;
        await WalletManager.updateLastUsedIndex(accountModel!);
      }
      await getAddress(init: true);
    } catch (e) {
      logger.e(e.toString());
    }
    sinkAddSafe();
  }
}
