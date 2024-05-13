import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';

import 'buybitcoin.view.dart';
import 'buybitcoin.viewmodel.dart';

class BuyBitcoinCoordinator extends Coordinator {
  late ViewBase widget;

  final int walletID;
  final int accountID;

  BuyBitcoinCoordinator(this.walletID, this.accountID);

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    var viewModel = BuyBitcoinViewModelImpl(this, walletID, accountID);
    widget = BuyBitcoinView(
      viewModel,
    );
    return widget;
  }
}
