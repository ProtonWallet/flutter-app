import 'dart:ui';

import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/early.access/early.access.view.dart';
import 'package:wallet/scenes/home.v3/sub.views/early.access/early.access.viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/proton.products/proton.products.coordinator.dart';

class EarlyAccessCoordinator extends Coordinator {
  late ViewBase widget;
  final String email;
  final VoidCallback logoutFunction;

  EarlyAccessCoordinator(
    this.logoutFunction,
    this.email,
  );

  @override
  void end() {}

  void showProtonProductions() {
    showInBottomSheet(
      ProtonProductsCoordinator().start(),
      backgroundColor: ProtonColors.white,
    );
  }

  void logout() {
    logoutFunction.call();
  }

  @override
  ViewBase<ViewModel> start() {
    final viewModel = EarlyAccessViewModelImpl(
      this,
      email,
    );
    widget = EarlyAccessView(
      viewModel,
    );
    return widget;
  }
}
