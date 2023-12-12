import 'dart:async';

import 'package:wallet/scenes/core/viewmodel.dart';

abstract class AppViewModel extends ViewModel {
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
}
