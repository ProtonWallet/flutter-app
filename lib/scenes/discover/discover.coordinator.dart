import 'package:wallet/managers/api.service.manager.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/discover/discover.view.dart';
import 'package:wallet/scenes/discover/discover.viewmodel.dart';

class DiscoverCoordinator extends Coordinator {
  late ViewBase widget;

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    final apiServiceManager = serviceManager.get<ProtonApiServiceManager>();
    final viewModel = DiscoverViewModelImpl(
      apiServiceManager.getApiService().getDiscoveryContentClient(),
      this,
    );
    widget = DiscoverView(
      viewModel,
    );
    return widget;
  }
}
