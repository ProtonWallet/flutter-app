import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/deletion/deletion.coordinator.dart';
import 'package:wallet/scenes/history/history.coordinator.dart';
import 'package:wallet/scenes/receive/receive.coordinator.dart';
import 'package:wallet/scenes/send/send.coordinator.dart';
import 'package:wallet/scenes/wallet/wallet.view.dart';
import 'package:wallet/scenes/wallet/wallet.viewmodel.dart';

class WalletCoordinator extends Coordinator {
  late ViewBase widget;

  final int walletID;

  WalletCoordinator(this.walletID);

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    var viewModel = WalletViewModelImpl(this, walletID);
    widget = WalletView(
      viewModel,
    );
    return widget;
  }

  void showSend(int walletID, int accountID) {
    var view = SendCoordinator(walletID, accountID).start();
    push(view, fullscreenDialog: true);
  }

  void showReceive(int walletID, int accountID) {
    var view = ReceiveCoordinator(walletID, accountID).start();
    push(view, fullscreenDialog: true);
  }

  void showHistory(int walletID, int accountID, FiatCurrency userFiatCurrency) {
    var view =
        HistoryCoordinator(walletID, accountID, userFiatCurrency).start();
    push(view, fullscreenDialog: true);
  }

  void showDeletion(int walletID) {
    var view = WalletDeletionCoordinator(walletID).start();
    push(view, fullscreenDialog: true);
  }
}
