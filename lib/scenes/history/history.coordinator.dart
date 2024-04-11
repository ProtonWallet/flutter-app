import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/history/details.coordinator.dart';
import 'package:wallet/scenes/history/history.view.dart';
import 'package:wallet/scenes/history/history.viewmodel.dart';

class HistoryCoordinator extends Coordinator {
  late ViewBase widget;

  final int walletID;
  final int accountID;

  HistoryCoordinator(this.walletID, this.accountID);

  @override
  void end() {}

  void showHistoryDetails(int walletID, int accountID, String txID) {
    var view = HistoryDetailCoordinator(walletID, accountID, txID).start();
    push(view, fullscreenDialog: true);
  }

  @override
  ViewBase<ViewModel> start() {
    var viewModel = HistoryViewModelImpl(this, walletID, accountID);
    widget = HistoryView(
      viewModel,
    );
    return widget;
  }
}
