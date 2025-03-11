import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/wallet.account.xpub.info/wallet.account.xpub.info.view.dart';
import 'package:wallet/scenes/home.v3/sub.views/wallet.account.xpub.info/wallet.account.xpub.info.viewmodel.dart';

class WalletAccountXpubInfoCoodinator extends Coordinator {
  late ViewBase widget;
  final AccountModel accountModel;

  WalletAccountXpubInfoCoodinator(
    this.accountModel,
  );

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    final walletManager = serviceManager.get<WalletManager>();
    final viewModel =
        WalletAccountXpubInfoViewModelImpl(this, accountModel, walletManager);
    widget = WalletAccountXpubInfoView(
      viewModel,
    );
    return widget;
  }
}
