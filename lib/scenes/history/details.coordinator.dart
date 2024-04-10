import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/history/details.view.dart';
import 'package:wallet/scenes/history/details.viewmodel.dart';

class HistoryDetailCoordinator extends Coordinator {
  late ViewBase widget;
  final int walletID;
  final int accountID;
  final String txID;

  HistoryDetailCoordinator(this.walletID, this.accountID, this.txID);

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    var viewModel = HistoryDetailViewModelImpl(this, walletID, accountID, txID);
    widget = HistoryDetailView(
      viewModel,
    );
    return widget;
  }
}
