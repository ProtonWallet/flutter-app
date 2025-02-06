import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/unavailable/buying.unavailable.viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/unavailable/unavailable.view.dart';

class BuyingUnavailableCoordinator extends Coordinator {
  late ViewBase widget;

  BuyingUnavailableCoordinator();

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    final viewModel = BuyingUnavailableViewModel(
      this,
    );
    widget = UnavailableView(
      viewModel,
    );
    return widget;
  }
}
