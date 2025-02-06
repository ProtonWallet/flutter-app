import 'dart:async';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/home.v3/sub.views/unavailable/unavailable.viewmodel.dart';

class BuyingUnavailableViewModel extends UnavailableViewModel {
  BuyingUnavailableViewModel(
    super.coordinator,
  );

  @override
  Future<void> loadData() async {
    sinkAddSafe();
  }

  @override
  Future<void> move(NavID to) async {}
}
