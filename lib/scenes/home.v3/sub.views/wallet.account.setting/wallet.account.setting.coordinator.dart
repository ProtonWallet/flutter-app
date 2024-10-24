import 'package:wallet/managers/features/wallet.list/wallet.list.bloc.model.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/delete.wallet.account/delete.wallet.account.coordinator.dart';
import 'package:wallet/scenes/home.v3/sub.views/wallet.account.setting/wallet.account.setting.view.dart';
import 'package:wallet/scenes/home.v3/sub.views/wallet.account.setting/wallet.account.setting.viewmodel.dart';

class WalletAccountSettingCoordinator extends Coordinator {
  late ViewBase widget;
  final AccountMenuModel accountMenuModel;

  WalletAccountSettingCoordinator(
    this.accountMenuModel,
  );

  void showDeleteWalletAccount() {
    final view = DeleteWalletAccountCoordinator(accountMenuModel).start();
    showInBottomSheet(view);
  }

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    final viewModel = WalletAccountSettingViewModelImpl(
      accountMenuModel,
      this,
    );
    widget = WalletAccountSettingView(
      viewModel,
    );
    return widget;
  }
}
