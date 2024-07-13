import 'package:wallet/managers/channels/platform.channel.manager.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/logs/logs.coordinator.dart';
import 'package:wallet/scenes/settings/settings.view.dart';
import 'package:wallet/scenes/settings/settings.viewmodel.dart';

class SettingsCoordinator extends Coordinator {
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
    final viewModel = SettingsViewModelImpl(
      this,
      userManager,
      nativeChannel,
    );
    widget = SettingsView(
      viewModel,
    );
    return widget;
  }
}
