import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/setup/ready.view.dart';
import 'package:wallet/scenes/setup/ready.viewmodel.dart';

class SetupReadyCoordinator extends Coordinator {
  late ViewBase widget;

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    var viewModel = SetupReadyViewModelImpl(this);
    widget = SetupReadyView(
      viewModel,
    );
    return widget;
  }
}
