import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/settings/settings.view.dart';
import 'package:wallet/scenes/settings/settings.viewmodel.dart';
import 'package:wallet/scenes/welcome/welcome.coordinator.dart';

class SettingsCoordinator extends Coordinator {
  late ViewBase widget;

  @override
  void end() {}

  void logout() {
    var view = WelcomeCoordinator().start();
    pushReplacement(view);
  }

  @override
  ViewBase<ViewModel> start() {
    var viewModel = SettingsViewModelImpl(
      this,
    );
    widget = SettingsView(
      viewModel,
    );
    return widget;
  }
}
