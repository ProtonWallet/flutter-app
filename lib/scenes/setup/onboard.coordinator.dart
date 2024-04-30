import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/import/import.coordinator.dart';
import 'package:wallet/scenes/setup/create.coordinator.dart';
import 'package:wallet/scenes/setup/onboard.view.dart';
import 'package:wallet/scenes/setup/onboard.viewmodel.dart';

class SetupOnbaordCoordinator extends Coordinator {
  late ViewBase widget;

  @override
  void end() {}

  void showSetupCreate() {
    var view = SetupCreateCoordinator().start();
    pushReplacementCustom(view);
  }

  void showImportWallet() {
    var view = ImportCoordinator().start();
    pushReplacementCustom(view);
  }

  @override
  ViewBase<ViewModel> start() {
    var viewModel = SetupOnboardViewModelImpl(this);
    widget = SetupOnboardView(
      viewModel,
    );
    return widget;
  }
}
