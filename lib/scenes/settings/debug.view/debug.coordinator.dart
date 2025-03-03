import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/settings/debug.view/debug.view.dart';
import 'package:wallet/scenes/settings/debug.view/debug.viewmodel.dart';

class DebugCoordinator extends Coordinator {
  late ViewBase widget;

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    final viewModel = DebugViewModelImpl(
      this,
    );
    widget = DebugView(
      viewModel,
    );
    return widget;
  }
}
