import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/receive/receive.view.dart';
import 'package:wallet/scenes/receive/receive.viewmodel.dart';

class ReceiveCoordinator extends Coordinator {
  late ViewBase widget;
  final String serverWalletID;
  final String serverAccountID;
  final bool isWalletView;

  ReceiveCoordinator(
    this.serverWalletID,
    this.serverAccountID,
    this.isWalletView,
  );

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    var userManager = serviceManager.get<UserManager>();
    var dataProviderManager = serviceManager.get<DataProviderManager>();
    var viewModel = ReceiveViewModelImpl(
      this,
      serverWalletID,
      serverAccountID,
      isWalletView,
      userManager,
      dataProviderManager.walletDataProvider,
      dataProviderManager.protonAddressProvider,
      dataProviderManager.walletKeysProvider,
    );
    widget = ReceiveView(
      viewModel,
    );
    return widget;
  }
}
