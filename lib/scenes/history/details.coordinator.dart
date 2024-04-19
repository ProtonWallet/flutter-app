import 'package:wallet/rust/proton_api/user_settings.dart';
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
  final FiatCurrency userFiatCurrency;

  HistoryDetailCoordinator(this.walletID, this.accountID, this.txID, this.userFiatCurrency);

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    var viewModel = HistoryDetailViewModelImpl(this, walletID, accountID, txID, userFiatCurrency);
    widget = HistoryDetailView(
      viewModel,
    );
    return widget;
  }
}
