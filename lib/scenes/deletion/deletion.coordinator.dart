import 'package:wallet/scenes/deletion/deletion.view.dart';
import 'package:wallet/scenes/deletion/deletion.viewmodel.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/setup/ready.coordinator.dart';

class WalletDeletionCoordinator extends Coordinator {
  late ViewBase widget;

  final int walletID;

  WalletDeletionCoordinator(this.walletID);

  @override
  void end() {}

  void showSetupReady() {
    var view = SetupReadyCoordinator().start();
    pushCustom(view, fullscreenDialog: false);
  }

  @override
  ViewBase<ViewModel> start() {
    var viewModel = WalletDeletionViewModelImpl(this, walletID);
    widget = WalletDeletionView(
      viewModel,
    );
    return widget;
  }
}
