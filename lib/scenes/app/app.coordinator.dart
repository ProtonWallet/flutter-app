import 'package:wallet/scenes/app/app.view.dart';
import 'package:wallet/scenes/app/app.viewmodel.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/welcome/welcome.coordinator.dart';

class AppCoordinator extends Coordinator {
  late ViewBase widget;

  AppCoordinator();

  Future<void> init() async {
    //TODO:: temp fix later
    Coordinator.platformChannelManager.init();
  }

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    ViewBase view = WelcomeCoordinator(
            nativeViewChannel:
                Coordinator.platformChannelManager.nativeViewChannel)
        .start();
    var viewModel = AppViewModelImpl(
      this,
    );
    widget = AppView(
      viewModel,
      view,
    );
    return widget;
  }
}
