import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/extension/stream.controller.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
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
    datasourceChangedStreamController.sinkAddSafe(this);
  }

  @override
  Future<void> copyMnemonic(BuildContext context) async {
    Clipboard.setData(ClipboardData(
            text: await WalletManager.getMnemonicWithID(walletID)))
        .then((_) {
      hasSaveMnemonic = true;
      datasourceChangedStreamController.sinkAddSafe(this);
      if (context.mounted) {
        CommonHelper.showSnackbar(context, S
            .of(context)
            .copied_mnemonic);
      }
    });
  }

  @override
  Future<void> deleteWallet() async {
    EasyLoading.show(
        status: "deleting wallet..", maskType: EasyLoadingMaskType.black);
    try {
      await proton_api.deleteWallet(walletId: walletModel!.serverWalletID);
      await WalletManager.deleteWallet(walletModel!.id!);
    } catch (e) {
      errorMessage = e.toString();
    }
    EasyLoading.dismiss();
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  @override
  Future<void> move(NavID to) async {}
}
