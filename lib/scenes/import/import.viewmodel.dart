import 'dart:async';
import 'package:wallet/scenes/core/viewmodel.dart';

abstract class ImportViewModel extends ViewModel {
  ImportViewModel(super.coordinator);
}

class ImportViewModelImpl extends ImportViewModel {
  ImportViewModelImpl(super.coordinator);
  final datasourceChangedStreamController =
      StreamController<ImportViewModel>.broadcast();
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
