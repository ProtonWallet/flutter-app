import 'dart:async';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:wallet/constants/app.config.dart';
import 'package:wallet/helper/bdk/helper.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/wallet_manager.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/debug/bdk.test.dart';
import 'package:wallet/scenes/receive/receive.coordinator.dart';

abstract class ReceiveViewModel extends ViewModel<ReceiveCoordinator> {
  ReceiveViewModel(super.coordinator, this.walletID, this.accountID);

  int walletID;
  int accountID;

  String address = "";
  String errorMessage = "";
  var selectedWallet = 1;

  WalletModel? walletModel;
  bool hasEmailIntegration = false;
  AccountModel? accountModel;

  void getAddress();
}

class ReceiveViewModelImpl extends ReceiveViewModel {
  ReceiveViewModelImpl(super.coordinator, super.walletID, super.accountID);

  final BdkLibrary _lib = BdkLibrary(coinType: appConfig.coinType);
  late Wallet _wallet;
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
      accountModel = await DBHelper.accountDao!.findById(accountID);
      await WalletManager.syncBitcoinAddressIndex(
          walletModel!.serverWalletID, accountModel!.serverAccountID);
      await getAddress(init: true);
    } catch (e) {
      errorMessage = e.toString();
    }
    EasyLoading.dismiss();
    datasourceChangedStreamController.add(this);
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  @override
  Future<void> getAddress({bool init = false}) async {
    if (walletModel != null && accountModel != null) {
      if (init) {
        _wallet = await WalletManager.loadWalletWithID(
            walletModel!.id!, accountModel!.id!);
        List<String> emailIntegrationAddresses =
            await WalletManager.getAccountAddressIDs(
                accountModel?.serverAccountID ?? "");
        hasEmailIntegration = emailIntegrationAddresses.isNotEmpty;
      }
      int addressIndex = await WalletManager.getBitcoinAddressIndex(
          walletModel!.serverWalletID, accountModel!.serverAccountID);
      var addressInfo =
          await _lib.getAddress(_wallet, addressIndex: addressIndex);
      address = addressInfo.address;
      datasourceChangedStreamController.add(this);
    }
  }

  @override
  void move(NavigationIdentifier to) {
    // TODO: implement move
  }
}
