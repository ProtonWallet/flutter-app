import 'dart:async';

import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/viewmodel.dart';

abstract class SetupOnboardViewModel extends ViewModel {
  SetupOnboardViewModel(Coordinator coordinator) : super(coordinator);

  void goHome();
}

class SetupOnboardViewModelImpl extends SetupOnboardViewModel {
  SetupOnboardViewModelImpl(Coordinator coordinator) : super(coordinator);
  final datasourceChangedStreamController =
      StreamController<SetupOnboardViewModel>.broadcast();
  @override
  void dispose() {
    datasourceChangedStreamController.close();
  }

  @override
  Future<void> loadData() async {
    return;
  }

  @override
  void goHome() {
    // coordinator.move(to, context);
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;
}
