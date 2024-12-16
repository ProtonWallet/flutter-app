import 'package:wallet/managers/features/wallet.list/wallet.list.bloc.model.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/transaction.addresses.switch/transaction.addresses.switch.view.dart';
import 'package:wallet/scenes/home.v3/sub.views/transaction.addresses.switch/transaction.addresses.switch.viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/wallet.account.address.list/wallet.account.address.list.coordinator.dart';

class TransactionAddressesSwitchCoordinator extends Coordinator {
  late ViewBase widget;
  final AccountMenuModel accountMenuModel;

  TransactionAddressesSwitchCoordinator(
    this.accountMenuModel,
  );

  void showWalletAccountAddressList() {
    final view = WalletAccountAddressListCoordinator(accountMenuModel).start();
    showInBottomSheet(view);
  }

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    final viewModel = TransactionAddressesSwitchViewModelImpl(
      accountMenuModel,
      this,
    );
    widget = TransactionAddressesSwitchView(
      viewModel,
    );
    return widget;
  }
}
