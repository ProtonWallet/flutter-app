import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view_model.dart';

abstract class WelcomeViewModel extends ViewModel {
  WelcomeViewModel(Coordinator coordinator) : super(coordinator);
}

class WelcomeViewModelImpl extends WelcomeViewModel {
  WelcomeViewModelImpl(Coordinator coordinator) : super(coordinator);
  @override
  void dispose() {}

  @override
  Future<void> loadData() async {
    return;
  }
}
