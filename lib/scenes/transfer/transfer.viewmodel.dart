import 'dart:async';
import 'package:wallet/helper/extension/stream.controller.dart';
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
  final datasourceChangedStreamController =
      StreamController<TransferViewModel>.broadcast();
  @override
  void dispose() {
    datasourceChangedStreamController.close();
  }

  @override
  Future<void> loadData() async {
    datasourceChangedStreamController.sinkAddSafe(this);
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  @override
  Future<void> move(NavID to) async {}
}
