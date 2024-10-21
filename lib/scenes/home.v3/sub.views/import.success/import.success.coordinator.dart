import 'dart:ui';

import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/import.success/import.success.view.dart';
import 'package:wallet/scenes/home.v3/sub.views/import.success/import.success.viewmodel.dart';

class ImportSuccessCoordinator extends Coordinator {
  late ViewBase widget;

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    final dataProviderManager = serviceManager.get<DataProviderManager>();
    final viewModel = ImportSuccessViewModelImpl(
      this,
      dataProviderManager.userSettingsDataProvider,
    );
    widget = ImportSuccessView(
      viewModel,
    );
    return widget;
  }
}
