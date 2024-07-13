import 'package:wallet/constants/env.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home/navigation.coordinator.dart';
import 'package:wallet/scenes/logs/logs.view.dart';
import 'package:wallet/scenes/logs/logs.viewmodel.dart';

class LogsCoordinator extends Coordinator {
  late ViewBase widget;
  @override
  void end() {}

  void showHome(ApiEnv env) {
    final view = HomeNavigationCoordinator(env).start();
    pushReplacement(view);
  }

  @override
  ViewBase<ViewModel> start() {
    final viewModel = LogsViewModelImpl(
      this,
    );
    widget = LogsView(
      viewModel,
    );
    return widget;
  }
}
