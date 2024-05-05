import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/local_toast.dart';
import 'package:wallet/helper/wallet_manager.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/rust/api/proton_api.dart' as proton_api;
import 'package:wallet/scenes/deletion/deletion.coordinator.dart';

abstract class WalletDeletionViewModel
    extends ViewModel<WalletDeletionCoordinator> {
  WalletDeletionViewModel(super.coordinator, this.walletID);

  int walletID;
  WalletModel? walletModel;
  bool hasSaveMnemonic = false;
  String errorMessage = "";

  void copyMnemonic(BuildContext context);

  Future<void> deleteWallet();
}

class WalletDeletionViewModelImpl extends WalletDeletionViewModel {
  WalletDeletionViewModelImpl(super.coordinator, super.strMnemonic);

  final datasourceChangedStreamController =
      StreamController<WalletDeletionViewModel>.broadcast();

  @override
  void dispose() {
    datasourceChangedStreamController.close();
  }

  @override
  Future<void> loadData() async {
    walletModel = await DBHelper.walletDao!.findById(walletID);
    datasourceChangedStreamController.add(this);
  }

  @override
  Future<void> copyMnemonic(BuildContext context) async {
    Clipboard.setData(ClipboardData(
            text: await WalletManager.getMnemonicWithID(walletID)))
        .then((_) {
      hasSaveMnemonic = true;
      datasourceChangedStreamController.add(this);
      LocalToast.showToast(context, S.of(context).copied_mnemonic);
    });
  }

  @override
  Future<void> deleteWallet() async {
    EasyLoading.show(
        status: "deleting wallet..", maskType: EasyLoadingMaskType.black);
    try {
      await proton_api.deleteWallet(walletId: walletModel!.serverWalletID);
      await WalletManager.deleteWallet(walletModel!.id!);
      await Future.delayed(const Duration(
          seconds: 2)); // wait for wallet/account remove on sidebar
    } catch (e) {
      errorMessage = e.toString();
    }
    EasyLoading.dismiss();
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  @override
  void move(NavigationIdentifier to) {}
}
