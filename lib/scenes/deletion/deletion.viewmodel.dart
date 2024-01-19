import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/scenes/core/viewmodel.dart';

import '../../helper/local_toast.dart';
import '../../helper/wallet_manager.dart';

abstract class WalletDeletionViewModel extends ViewModel {
  WalletDeletionViewModel(super.coordinator, this.walletID);

  int walletID;

  bool hasSaveMnemonic = false;

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
    datasourceChangedStreamController.add(this);
  }

  @override
  Future<void> copyMnemonic(BuildContext context) async {
    Clipboard.setData(ClipboardData(
            text: await WalletManager.getMnemonicWithID(walletID)))
        .then((_) {
      hasSaveMnemonic = true;
      datasourceChangedStreamController.add(this);
      LocalToast.showToast(context, "Copied Mnemonic!");
    });
  }

  @override
  Future<void> deleteWallet() async {
    await DBHelper.walletDao!.delete(walletID);
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;
}
