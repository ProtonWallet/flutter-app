import 'dart:async';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/proton.products/proton.products.coordinator.dart';

abstract class ProtonProductsViewModel
    extends ViewModel<ProtonProductsCoordinator> {
  ProtonProductsViewModel(
    super.coordinator,
  );
}

class ProtonProductsViewModelImpl extends ProtonProductsViewModel {
  ProtonProductsViewModelImpl(
    super.coordinator,
  );

  @override
  Future<void> loadData() async {
    sinkAddSafe();
  }

  @override
  Future<void> move(NavID to) async {}
}
