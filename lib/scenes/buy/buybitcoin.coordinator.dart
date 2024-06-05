import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';

import 'buybitcoin.view.dart';
import 'buybitcoin.viewmodel.dart';

class BuyBitcoinCoordinator extends Coordinator {
  late ViewBase widget;

  BuyBitcoinCoordinator();

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    // var email = serviceManager.get<UserManager>().userInfo.userMail;
    var viewModel = BuyBitcoinViewModelImpl(this);
    widget = BuyBitcoinView(
      viewModel,
    );
    return widget;
  }
}
