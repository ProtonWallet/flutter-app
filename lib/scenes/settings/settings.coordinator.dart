import 'package:wallet/managers/channels/platform.channel.manager.dart';
import 'package:wallet/managers/features/settings/clear.cache.bloc.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
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
    final dataProviderManager = serviceManager.get<DataProviderManager>();
    final walletManager = serviceManager.get<WalletManager>();
    final clearCacheBloc = ClearCacheBloc(
      userManager,
      walletManager,
      dataProviderManager.bdkTransactionDataProvider,
    );
    final viewModel = SettingsViewModelImpl(
      this,
      clearCacheBloc,
      userManager,
      nativeChannel,
      dataProviderManager.userSettingsDataProvider,
    );
    widget = SettingsView(
      viewModel,
    );
    return widget;
  }
}
