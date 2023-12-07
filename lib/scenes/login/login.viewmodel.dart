import 'dart:async';
import 'package:wallet/scenes/core/viewmodel.dart';

abstract class LoginViewModel extends ViewModel {
  LoginViewModel(super.coordinator);
}

class LoginViewModelImpl extends LoginViewModel {
  LoginViewModelImpl(super.coordinator);
  final datasourceChangedStreamController =
      StreamController<LoginViewModel>.broadcast();
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
