import 'dart:async';
import 'package:wallet/scenes/core/viewmodel.dart';

abstract class SendViewModel extends ViewModel {
  SendViewModel(super.coordinator);
}

class SendViewModelImpl extends SendViewModel {
  SendViewModelImpl(super.coordinator);
  final datasourceChangedStreamController =
      StreamController<SendViewModel>.broadcast();
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
