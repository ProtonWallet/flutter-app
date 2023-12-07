import 'dart:async';
import 'package:wallet/scenes/core/viewmodel.dart';

abstract class SignupViewModel extends ViewModel {
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
}
