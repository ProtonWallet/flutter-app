import 'dart:async';

import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/rbf/rbf.coordinator.dart';

abstract class RbfViewModel extends ViewModel<RbfCoordinator> {
  RbfViewModel(super.coordinator);

}

class RbfViewModelImpl extends RbfViewModel {
  RbfViewModelImpl(
    super.coordinator,
  );


  @override
  Future<void> loadData() async {
    sinkAddSafe();
  }

  @override
  Future<void> move(NavID to) {
    throw UnimplementedError();
  }
}
