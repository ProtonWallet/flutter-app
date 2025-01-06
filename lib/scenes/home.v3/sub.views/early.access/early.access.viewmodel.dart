import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/early.access/early.access.coordinator.dart';

abstract class EarlyAccessViewModel extends ViewModel<EarlyAccessCoordinator> {
  final String email;
  bool get showProducts => true;

  EarlyAccessViewModel(
    super.coordinator,
    this.email,
  );
}

class EarlyAccessViewModelImpl extends EarlyAccessViewModel {
  EarlyAccessViewModelImpl(
    super.coordinator,
    super.email,
  );

  @override
  Future<void> loadData() async {
    sinkAddSafe();
  }

  @override
  bool get showProducts {
    if (defaultTargetPlatform == TargetPlatform.iOS) return false;
    return true;
  }

  @override
  Future<void> move(NavID to) async {
    switch (to) {
      case NavID.protonProducts:
        coordinator.showProtonProductions();
      case NavID.logout:
        coordinator.logout();
      default:
    }
  }
}
