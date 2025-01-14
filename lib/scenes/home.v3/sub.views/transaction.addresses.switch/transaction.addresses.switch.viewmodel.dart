import 'dart:async';
import 'package:wallet/managers/features/wallet.list/wallet.list.bloc.model.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/transaction.addresses.switch/transaction.addresses.switch.coordinator.dart';

abstract class TransactionAddressesSwitchViewModel
    extends ViewModel<TransactionAddressesSwitchCoordinator> {
  final AccountMenuModel accountMenuModel;

  TransactionAddressesSwitchViewModel(
    this.accountMenuModel,
    super.coordinator,
  );

  void showWalletAccountAddressList() {
    coordinator.showWalletAccountAddressList();
  }

  String errorMessage = "";
}

class TransactionAddressesSwitchViewModelImpl
    extends TransactionAddressesSwitchViewModel {
  TransactionAddressesSwitchViewModelImpl(
    super.accountMenuModel,
    super.coordinator,
  );

  @override
  Future<void> loadData() async {
    sinkAddSafe();
  }

  @override
  Future<void> move(NavID to) async {}
}
