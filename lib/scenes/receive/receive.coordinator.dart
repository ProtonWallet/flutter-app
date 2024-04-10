import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/receive/receive.view.dart';
import 'package:wallet/scenes/receive/receive.viewmodel.dart';

class ReceiveCoordinator extends Coordinator {
  late ViewBase widget;
  final int walletID;
  final int accountID;

  ReceiveCoordinator(this.walletID, this.accountID);

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    var viewModel = ReceiveViewModelImpl(this, walletID, accountID);
    widget = ReceiveView(
      viewModel,
    );
    return widget;
  }
}
