import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/managers/app.state.manager.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/lock.core/lock.overlay.view.dart';
import 'package:wallet/scenes/lock.core/lock.overlay.viewmodel.dart';
import 'package:wallet/scenes/lock.overlay/lock.overlay.coordinator.dart';

class LockCoordinator extends Coordinator {
  late ViewBase widget;

  @override
  void end() {}

  void showLockOverlay({required bool askUnlockWhenOnload}) {
    final view =
        LockOverlayCoordinator(askUnlockWhenOnload: askUnlockWhenOnload)
            .start();
    showInBottomSheet(
      view,
      backgroundColor: ProtonColors.backgroundSecondary,
      enableDrag: false,
      isDismissible: false,
      fullScreen: true,
      canPop: false,
    );
  }

  @override
  ViewBase<ViewModel> start() {
    final appState = serviceManager.get<AppStateManager>();
    final viewModel = LockCoreViewModelImpl(
      this,
      appState,
    );
    widget = LockCoreView(
      viewModel,
    );
    return widget;
  }
}
