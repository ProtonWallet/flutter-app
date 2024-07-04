import 'dart:async';
import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/extension/stream.controller.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/helper/walletkey_helper.dart';
import 'package:wallet/managers/providers/proton.address.provider.dart';
import 'package:wallet/managers/providers/wallet.data.provider.dart';
import 'package:wallet/managers/providers/wallet.keys.provider.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/managers/wallet/proton.wallet.provider.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/address.model.dart';
import 'package:wallet/models/bitcoin.address.model.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/rust/api/bdk_wallet/account.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/receive/receive.coordinator.dart';

abstract class ReceiveViewModel extends ViewModel<ReceiveCoordinator> {
  ReceiveViewModel(
    super.coordinator,
    this.serverWalletID,
    this.serverAccountID,
    this.isWalletView,
  );

  String serverWalletID;
  String serverAccountID;
  int addressIndex = -1;

  bool isWalletView;

  String address = "";
  String errorMessage = "";
  var selectedWallet = 1;
  int accountsCount = 0;
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

  void changeAccount(AccountModel newAccountModel);
}

class ReceiveViewModelImpl extends ReceiveViewModel {
  ReceiveViewModelImpl(
    super.coordinator,
    super.serverWalletID,
    super.serverAccountID,
    super.isWalletView,
    this.userManager,
    this.walletDataProvider,
    this.protonAddressProvider,
    this.walletKeysProvider,
  );

  late FrbAccount _frbAccount;
  final datasourceChangedStreamController =
      StreamController<ReceiveViewModel>.broadcast();

  SecretKey? secretKey;

  final UserManager userManager;
  final WalletsDataProvider walletDataProvider;
  final ProtonAddressProvider protonAddressProvider;
  final WalletKeysProvider walletKeysProvider;

  @override
  void dispose() {
    datasourceChangedStreamController.close();
  }

  @override
  Future<void> loadData() async {
    EasyLoading.show(
        status: "syncing bitcoin address index..",
        maskType: EasyLoadingMaskType.black);
    try {
      walletData =
          await walletDataProvider.getWalletByServerWalletID(serverWalletID);
      walletModel = walletData?.wallet;
      for (AccountModel accModel in walletData?.accounts ?? []) {
        if (accModel.accountID == serverAccountID) {
          accountModel = accModel;
          break;
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
    } catch (e) {
      errorMessage = e.toString();
    }
    EasyLoading.dismiss();
    if (errorMessage.isNotEmpty) {
      CommonHelper.showErrorDialog(errorMessage);
      errorMessage = "";
    }
    initialized = true;
    datasourceChangedStreamController.sinkAddSafe(this);
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  @override
  Future<void> getAddress({bool init = false}) async {
    if (walletModel != null && accountModel != null) {
      if (init) {
        _frbAccount = (await WalletManager.loadWalletWithID(
          walletModel!.walletID,
          accountModel!.accountID,
        ))!;
        emailIntegrationAddresses = await WalletManager.getAccountAddressIDs(
          accountModel?.accountID ?? "",
        );
        if (emailIntegrationAddresses.isNotEmpty) {
          AddressModel? addressModel = await protonAddressProvider
              .getAddressModel(emailIntegrationAddresses.first);
          if (addressModel != null) {
            bitcoinViaEmailAddress = addressModel.email;
          }
        }
        hasEmailIntegration = emailIntegrationAddresses.isNotEmpty;
        BitcoinAddressModel? bitcoinAddressModel = await DBHelper
            .bitcoinAddressDao!
            .findLatestUnusedLocalBitcoinAddress(
          walletModel!.walletID,
          accountModel!.accountID,
        );
        if (bitcoinAddressModel != null && bitcoinAddressModel.used == 0) {
          addressIndex = bitcoinAddressModel.bitcoinAddressIndex;
        } else {
          addressIndex = await WalletManager.getBitcoinAddressIndex(
            walletModel!.walletID,
            accountModel!.accountID,
          );
        }
      } else {
        addressIndex = await WalletManager.getBitcoinAddressIndex(
          walletModel!.walletID,
          accountModel!.accountID,
        );
      }
      var addressInfo = await _frbAccount.getAddress(index: addressIndex);
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
      datasourceChangedStreamController.sinkAddSafe(this);
    }
  }

  Future<String> decryptAccountName(String encryptedName) async {
    if (secretKey == null) {
      var firstUserKey = await userManager.getFirstKey();
      var walletKey = await walletKeysProvider.getWalletKey(
        serverWalletID,
      );
      if (walletKey != null) {
        secretKey = WalletKeyHelper.decryptWalletKey(
          firstUserKey,
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
    EasyLoading.show(
        status: "syncing bitcoin address index..",
        maskType: EasyLoadingMaskType.black);
    try {
      accountModel = newAccountModel;
      accountModel?.labelDecrypt =
          await decryptAccountName(base64Encode(accountModel!.label));
      await WalletManager.syncBitcoinAddressIndex(
          walletModel!.walletID, accountModel!.accountID);
      await getAddress(init: true);
    } catch (e) {
      logger.e(e.toString());
    }
    EasyLoading.dismiss();
    datasourceChangedStreamController.sinkAddSafe(this);
  }
}
