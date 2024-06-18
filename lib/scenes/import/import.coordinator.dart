import 'package:wallet/managers/providers/data.provider.manager.dart';
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
    var dataProviderManager = serviceManager.get<DataProviderManager>();
    var viewModel = ImportViewModelImpl(this, dataProviderManager);
    widget = ImportView(
      viewModel,
    );
    return widget;
  }
}
