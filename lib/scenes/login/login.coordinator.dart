import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/login/login.view.dart';
import 'package:wallet/scenes/login/login.viewmodel.dart';

class LoginCoordinator extends Coordinator {
  late ViewBase widget;

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    var viewModel = LoginViewModelImpl(this);
    widget = LoginView(
      viewModel,
    );
    return widget;
  }
}
