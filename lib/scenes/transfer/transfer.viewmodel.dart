import 'dart:async';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/transfer/transfer.coordinator.dart';

abstract class TransferViewModel extends ViewModel<TransferCoordinator> {
  TransferViewModel(super.coordinator);

  int testCode = 0;
  int testCodeTwo = 0;
}

class TransferViewModelImpl extends TransferViewModel {
  TransferViewModelImpl(super.coordinator);

  @override
  Future<void> loadData() async {
    sinkAddSafe();
  }

  @override
  Future<void> move(NavID to) async {}
}
