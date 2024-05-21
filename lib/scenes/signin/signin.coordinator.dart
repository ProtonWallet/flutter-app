import 'package:wallet/constants/env.dart';
import 'package:wallet/managers/user.manager.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home/navigation.coordinator.dart';
import 'package:wallet/scenes/signin/signin.view.dart';
import 'package:wallet/scenes/signin/signin.viewmodel.dart';

class SigninCoordinator extends Coordinator {
  late ViewBase widget;
  @override
  void end() {}

  void showHome(ApiEnv env) {
    var view = HomeNavigationCoordinator(env).start();
    pushReplacement(view);
  }

  @override
  ViewBase<ViewModel> start() {
    var userManager = serviceManager.get<UserManager>();
    var viewModel = SigninViewModelImpl(this, userManager);
    widget = SigninView(
      viewModel,
    );
    return widget;
  }
}
