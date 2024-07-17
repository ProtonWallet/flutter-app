import 'package:wallet/managers/app.state.manager.dart';
import 'package:wallet/managers/local.auth.manager.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/lock/lock.overlay.view.dart';
import 'package:wallet/scenes/lock/lock.overlay.viewmodel.dart';

class LockCoordinator extends Coordinator {
  late ViewBase widget;
  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    final appState = serviceManager.get<AppStateManager>();
    final localAuth = serviceManager.get<LocalAuthManager>();

    final viewModel = LockViewModelImpl(
      this,
      appState,
      localAuth,
    );
    widget = LockOverlayView(
      viewModel,
    );
    return widget;
  }
}
