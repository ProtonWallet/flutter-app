import 'package:wallet/channels/platform.channel.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home/navigation.coordinator.dart';
import 'package:wallet/scenes/welcome/welcome.view.dart';
import 'package:wallet/scenes/welcome/welcome.viewmodel.dart';

class WelcomeCoordinator extends Coordinator {
  late ViewBase widget;
  @override
  void end() {}

  void showNativeSignin() {
    NativeViewSwitcher.switchToNativeLogin();
  }

  void showNativeSignup() {
    NativeViewSwitcher.switchToNativeSignup();
  }

  void showHome() {
    var view = HomeNavigationCoordinator().start();
    pushReplacement(view);
  }

  @override
  ViewBase<ViewModel> start() {
    var viewModel = WelcomeViewModelImpl(this);
    widget = WelcomeView(
      viewModel,
    );
    return widget;
  }
}
