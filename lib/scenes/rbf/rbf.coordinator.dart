import 'package:wallet/managers/channels/platform.channel.manager.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/logs/logs.coordinator.dart';
import 'package:wallet/scenes/rbf/rbf.view.dart';
import 'package:wallet/scenes/rbf/rbf.viewmodel.dart';

class RbfCoordinator extends Coordinator {
  late ViewBase widget;

  @override
  void end() {}

  void showLogs() {
    final view = LogsCoordinator().start();
    push(view);
  }

  @override
  ViewBase<ViewModel> start() {
    final userManager = serviceManager.get<UserManager>();
    final nativeChannel = serviceManager.get<PlatformChannelManager>();
    final dataProviderManager = serviceManager.get<DataProviderManager>();
    final viewModel = RbfViewModelImpl(
      this,
    );
    widget = RbfView(
      viewModel,
    );
    return widget;
  }
}
