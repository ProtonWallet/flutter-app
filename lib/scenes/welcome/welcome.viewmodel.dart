import 'dart:async';

import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/viewmodel.dart';

abstract class WelcomeViewModel extends ViewModel {
  WelcomeViewModel(Coordinator coordinator) : super(coordinator);

  void goHome();
}

class WelcomeViewModelImpl extends WelcomeViewModel {
  WelcomeViewModelImpl(Coordinator coordinator) : super(coordinator);
  final datasourceChangedStreamController =
      StreamController<WelcomeViewModel>.broadcast();
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
