import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/debug/websocket.view.dart';
import 'package:wallet/scenes/debug/websocket.viewmodel.dart';

class WebSocketCoordinator extends Coordinator {
  late ViewBase widget;

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    final viewModel = WebSocketViewModelImpl(this);
    widget = WebSocketView(
      viewModel,
    );
    return widget;
  }
}
