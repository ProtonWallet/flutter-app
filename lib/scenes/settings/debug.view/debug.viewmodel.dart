import 'dart:async';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/settings/debug.view/debug.coordinator.dart';

abstract class DebugViewModel extends ViewModel<DebugCoordinator> {
  DebugViewModel(super.coordinator);
}

class DebugViewModelImpl extends DebugViewModel {
  DebugViewModelImpl(super.coordinator);

  @override
  Future<void> loadData() async {
    // get user recovery phrase
    sinkAddSafe();
  }

  @override
  Future<void> move(NavID to) async {
    switch (to) {
      default:
        break;
    }
  }
}
