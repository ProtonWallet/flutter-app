import 'package:wallet/managers/features/wallet.list/wallet.list.bloc.model.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/wallet.account.info/wallet.account.info.view.dart';
import 'package:wallet/scenes/home.v3/sub.views/wallet.account.info/wallet.account.info.viewmodel.dart';

class WalletAccountInfoCoordinator extends Coordinator {
  late ViewBase widget;
  final AccountMenuModel accountMenuModel;

  WalletAccountInfoCoordinator(
    this.accountMenuModel,
  );

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    final walletManager = serviceManager.get<WalletManager>();
    final viewModel = WalletAccountInfoViewModelImpl(
      accountMenuModel,
      this,
      walletManager,
    );
    widget = WalletAccountInfoView(
      viewModel,
    );
    return widget;
  }
}
