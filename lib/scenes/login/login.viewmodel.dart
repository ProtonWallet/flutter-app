import 'dart:async';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/login/login.coordinator.dart';

abstract class LoginViewModel extends ViewModel<LoginCoordinator> {
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

  @override
  void move(NavigationIdentifier to) {}
}
