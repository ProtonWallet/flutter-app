import 'dart:async';
import 'dart:ui';

import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/early.access/early.access.coordinator.dart';

abstract class EarlyAccessViewModel extends ViewModel<EarlyAccessCoordinator> {
  final String email;
  final VoidCallback logoutFunction;
  final VoidCallback showProtonProducts;

  EarlyAccessViewModel(
    super.coordinator,
    this.logoutFunction,
    this.showProtonProducts,
    this.email,
  );
}

class EarlyAccessViewModelImpl extends EarlyAccessViewModel {
  EarlyAccessViewModelImpl(
    super.coordinator,
    super.logoutFunction,
    super.showProtonProducts,
    super.email,
  );

  @override
  Future<void> loadData() async {
    sinkAddSafe();
  }

  @override
  Future<void> move(NavID to) async {}
}
