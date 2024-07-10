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
    var view = LogsCoordinator().start();
    push(view);
  }

  @override
  ViewBase<ViewModel> start() {
    var userManager = serviceManager.get<UserManager>();
    var nativeChannel = serviceManager.get<PlatformChannelManager>();
    var viewModel = SettingsViewModelImpl(
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
