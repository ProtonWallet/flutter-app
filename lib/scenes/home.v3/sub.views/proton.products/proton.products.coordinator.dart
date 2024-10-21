import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/proton.products/proton.products.view.dart';
import 'package:wallet/scenes/home.v3/sub.views/proton.products/proton.products.viewmodel.dart';

class ProtonProductsCoordinator extends Coordinator {
  late ViewBase widget;

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    final viewModel = ProtonProductsViewModelImpl(
      this,
    );
    widget = ProtonProductsView(
      viewModel,
    );
    return widget;
  }
}
