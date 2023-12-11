import 'dart:async';
import 'package:wallet/scenes/core/viewmodel.dart';

abstract class ReceiveViewModel extends ViewModel {
  ReceiveViewModel(super.coordinator);
}

class ReceiveViewModelImpl extends ReceiveViewModel {
  ReceiveViewModelImpl(super.coordinator);
  final datasourceChangedStreamController =
      StreamController<ReceiveViewModel>.broadcast();
  @override
  void dispose() {
    datasourceChangedStreamController.close();
  }

  @override
  Future<void> loadData() async {}

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;
}
