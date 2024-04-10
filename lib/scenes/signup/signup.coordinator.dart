import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/signup/signup.view.dart';
import 'package:wallet/scenes/signup/signup.viewmodel.dart';

class SignupCoordinator extends Coordinator {
  late ViewBase widget;

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    var viewModel = SignupViewModelImpl(this);
    widget = SignupView(
      viewModel,
    );
    return widget;
  }
}
