import 'dart:async';

import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/bve.privacy/bve.privacy.coordinator.dart';

abstract class BvEPrivacyViewModel extends ViewModel<BvEPrivacyCoordinator> {
  final bool isPrimaryAccount;

  BvEPrivacyViewModel(
    super.coordinator, {
    required this.isPrimaryAccount,
  });
}

class BvEPrivacyViewModelImpl extends BvEPrivacyViewModel {
  BvEPrivacyViewModelImpl(
    super.coordinator, {
    required super.isPrimaryAccount,
  });

  @override
  Future<void> loadData() async {
    sinkAddSafe();
  }

  @override
  Future<void> move(NavID to) async {}
}
