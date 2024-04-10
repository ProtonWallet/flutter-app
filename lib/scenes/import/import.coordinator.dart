import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/import/import.view.dart';
import 'package:wallet/scenes/import/import.viewmodel.dart';

class ImportCoordinator extends Coordinator {
  late ViewBase widget;

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    var viewModel = ImportViewModelImpl(this);
    widget = ImportView(
      viewModel,
    );
    return widget;
  }
}
