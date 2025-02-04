import 'package:wallet/managers/api.service.manager.dart';
import 'package:wallet/managers/app.state.manager.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/send.invite/send.invite.view.dart';
import 'package:wallet/scenes/home.v3/sub.views/send.invite/send.invite.viewmodel.dart';

class SendInviteCoordinator extends Coordinator {
  late ViewBase widget;

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    final apiServiceManager = serviceManager.get<ProtonApiServiceManager>();
    final dataProviderManager = serviceManager.get<DataProviderManager>();
    final appStateManager = serviceManager.get<AppStateManager>();
    final viewModel = SendInviteViewModelImpl(
      this,
      apiServiceManager,
      dataProviderManager,
      appStateManager,
      dataProviderManager.unleashDataProvider,
    );
    widget = SendInviteView(
      viewModel,
    );
    return widget;
  }
}
