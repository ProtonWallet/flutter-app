import 'dart:async';
import 'package:wallet/scenes/core/viewmodel.dart';

abstract class SetupReadyViewModel extends ViewModel {
  SetupReadyViewModel(super.coordinator);
}

class SetupReadyViewModelImpl extends SetupReadyViewModel {
  SetupReadyViewModelImpl(super.coordinator);

  final datasourceChangedStreamController =
      StreamController<SetupReadyViewModel>.broadcast();

  @override
  void dispose() {
    datasourceChangedStreamController.close();
  }

  @override
  Future<void> loadData() async {
    return;
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;
}
