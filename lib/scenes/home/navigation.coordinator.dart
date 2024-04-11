import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/home.coordinator.dart';
import 'package:wallet/scenes/home/navigation.view.dart';
import 'package:wallet/scenes/home/navigation.viewmodel.dart';

class HomeNavigationCoordinator extends Coordinator {
  late ViewBase widget;

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    var viewModel = HomeNavigationViewModelImpl(
      this,
    );
    widget = HomeNavigationView(
      viewModel,
    );
    return widget;
  }

  @override
  List<ViewBase<ViewModel>> starts() {
    return [
      HomeCoordinator().start(),
      // HistoryCoordinator().start(),
      // BuyBitcoinCoordinator().start(),
      // TransferCoordinator().start(),
      // SettingsCoordinator().start()
    ];
  }
}
