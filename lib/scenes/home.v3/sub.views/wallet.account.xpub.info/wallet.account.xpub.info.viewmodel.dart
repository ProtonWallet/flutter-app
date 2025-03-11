import 'package:flutter/services.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/wallet.account.xpub.info/wallet.account.xpub.info.coordinator.dart';

abstract class WalletAccountXpubInfoViewModel
    extends ViewModel<WalletAccountXpubInfoCoodinator> {
  WalletAccountXpubInfoViewModel(super.coordinator, this.accountModel);
  final AccountModel accountModel;

  String xpub = "";
}

class WalletAccountXpubInfoViewModelImpl
    extends WalletAccountXpubInfoViewModel {
  WalletAccountXpubInfoViewModelImpl(
      super.coordinator, super.accountModel, this.walletManager);

  final WalletManager walletManager;

  @override
  Future<void> loadData() async {
    final frbAccount = await walletManager.loadWalletWithID(
        accountModel.walletID, accountModel.accountID,
        serverScriptType: accountModel.scriptType);
    xpub = await frbAccount?.getXpub() ?? "No public key (XPUB) found";
    sinkAddSafe();
  }

  Future<void> copyXpubToClipboard() async {
    await Clipboard.setData(ClipboardData(text: xpub));
  }

  @override
  Future<void> move(NavID to) async {}
}
