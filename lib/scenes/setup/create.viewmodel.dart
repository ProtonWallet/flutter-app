import 'dart:async';

import 'package:wallet/scenes/core/viewmodel.dart';

abstract class SetupCreateViewModel extends ViewModel {
  SetupCreateViewModel(super.coordinator);

  bool inProgress = true;

  void updateProgressStatus(bool inProgress);
}

class SetupCreateViewModelImpl extends SetupCreateViewModel {
  SetupCreateViewModelImpl(super.coordinator);
  final datasourceChangedStreamController =
      StreamController<SetupCreateViewModel>.broadcast();
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

  @override
  void updateProgressStatus(bool inProgress) {
    this.inProgress = inProgress;
    datasourceChangedStreamController.add(this);
  }
}
