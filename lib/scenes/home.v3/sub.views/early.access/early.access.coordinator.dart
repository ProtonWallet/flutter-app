import 'dart:ui';

import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/early.access/early.access.view.dart';
import 'package:wallet/scenes/home.v3/sub.views/early.access/early.access.viewmodel.dart';

class EarlyAccessCoordinator extends Coordinator {
  late ViewBase widget;
  final String email;
  final VoidCallback logoutFunction;
  final VoidCallback showProtonProducts;

  EarlyAccessCoordinator(this.logoutFunction, this.showProtonProducts, this.email);

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    final viewModel = EarlyAccessViewModelImpl(
      this,
      logoutFunction,
      showProtonProducts,
      email,
    );
    widget = EarlyAccessView(
      viewModel,
    );
    return widget;
  }
}
