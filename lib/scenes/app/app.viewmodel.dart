import 'dart:async';

import 'package:wallet/scenes/app/app.coordinator.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';

abstract class AppViewModel extends ViewModel<AppCoordinator> {
  AppViewModel(super.coordinator);
}

class AppViewModelImpl extends AppViewModel {
  AppViewModelImpl(super.coordinator);
  final datasourceChangedStreamController =
      StreamController<AppViewModel>.broadcast();
  bool showUsernameValidationError = false;

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  @override
  void dispose() {
    datasourceChangedStreamController.close();
  }

  @override
  Future<void> loadData() async {
    return;
  }

  @override
  void move(NavID to) {}
}
