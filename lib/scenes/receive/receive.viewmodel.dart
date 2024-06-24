import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/extension/stream.controller.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/wallet/proton.wallet.provider.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/bitcoin.address.model.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/rust/api/bdk_wallet/account.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/receive/receive.coordinator.dart';

abstract class ReceiveViewModel extends ViewModel<ReceiveCoordinator> {
  ReceiveViewModel(super.coordinator, this.walletID, this.accountID);

  int walletID;
  int accountID;
  int addressIndex = -1;

  String address = "";
  String errorMessage = "";
  var selectedWallet = 1;
  bool initialized = false;

  WalletModel? walletModel;
  bool hasEmailIntegration = false;
  AccountModel? accountModel;
  late ProtonWalletProvider protonWalletProvider;
  late ValueNotifier accountValueNotifier;

  void getAddress();

  void changeAccount(AccountModel newAccountModel);
}

class ReceiveViewModelImpl extends ReceiveViewModel {
  ReceiveViewModelImpl(super.coordinator, super.walletID, super.accountID);

  late FrbAccount _frbAccount;
  final datasourceChangedStreamController =
      StreamController<ReceiveViewModel>.broadcast();

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
      if (walletID == 0) {
        walletModel = await DBHelper.walletDao!.getFirstPriorityWallet();
      } else {
        walletModel = await DBHelper.walletDao!.findById(walletID);
      }
      if (accountID == 0) {
        accountModel = await DBHelper.accountDao!
            .findDefaultAccountByWalletID(walletModel?.id ?? 0);
      } else {
        accountModel = await DBHelper.accountDao!.findById(accountID);
      }
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
          walletModel!.id!,
          accountModel!.id!,
        ))!;
        List<String> emailIntegrationAddresses =
            await WalletManager.getAccountAddressIDs(
          accountModel?.serverAccountID ?? "",
        );
        hasEmailIntegration = emailIntegrationAddresses.isNotEmpty;
        BitcoinAddressModel? bitcoinAddressModel = await DBHelper
            .bitcoinAddressDao!
            .findLatestUnusedLocalBitcoinAddress(
          walletModel!.serverWalletID,
          accountModel!.serverAccountID,
        );
        if (bitcoinAddressModel != null && bitcoinAddressModel.used == 0) {
          addressIndex = bitcoinAddressModel.bitcoinAddressIndex;
        } else {
          addressIndex = await WalletManager.getBitcoinAddressIndex(
            walletModel!.serverWalletID,
            accountModel!.serverAccountID,
          );
        }
      } else {
        addressIndex = await WalletManager.getBitcoinAddressIndex(
          walletModel!.serverWalletID,
          accountModel!.serverAccountID,
        );
      }
      var addressInfo = await _frbAccount.getAddress(index: addressIndex);
      address = addressInfo.address;
      try {
        await DBHelper.bitcoinAddressDao!.insertOrUpdate(
          serverWalletID: walletModel!.serverWalletID,
          serverAccountID: accountModel!.serverAccountID,
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

  @override
  Future<void> move(NavID to) async {}

  @override
  Future<void> changeAccount(AccountModel newAccountModel) async {
    EasyLoading.show(
        status: "syncing bitcoin address index..",
        maskType: EasyLoadingMaskType.black);
    try {
      accountModel = newAccountModel;
      await WalletManager.syncBitcoinAddressIndex(
          walletModel!.serverWalletID, accountModel!.serverAccountID);
      await getAddress(init: true);
    } catch (e) {
      logger.e(e.toString());
    }
    EasyLoading.dismiss();
    datasourceChangedStreamController.sinkAddSafe(this);
  }
}
