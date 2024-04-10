import 'dart:async';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/signup/signup.coordinator.dart';

abstract class SignupViewModel extends ViewModel<SignupCoordinator> {
  SignupViewModel(super.coordinator);
}

class SignupViewModelImpl extends SignupViewModel {
  SignupViewModelImpl(super.coordinator);
  final datasourceChangedStreamController =
      StreamController<SignupViewModel>.broadcast();
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
