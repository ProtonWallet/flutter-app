import 'package:wallet/managers/event.loop.manager.dart';
import 'package:wallet/managers/wallet/proton.wallet.manager.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/send/send.view.dart';
import 'package:wallet/scenes/send/send.viewmodel.dart';

class SendCoordinator extends Coordinator {
  late ViewBase widget;
  final int walletID;
  final int accountID;

  SendCoordinator(this.walletID, this.accountID);

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    var eventLoop = serviceManager.get<EventLoop>();
    var walletManager = serviceManager.get<ProtonWalletManager>();
    var viewModel = SendViewModelImpl(
      this,
      walletID,
      accountID,
      eventLoop,
      walletManager,
    );
    widget = SendView(
      viewModel,
    );
    return widget;
  }
}
