import 'package:wallet/managers/app.state.manager.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
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
    this.serverAccountID, {
    required this.isWalletView,
  });

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    final userManager = serviceManager.get<UserManager>();
    final walletManager = serviceManager.get<WalletManager>();
    final dataProviderManager = serviceManager.get<DataProviderManager>();
    final appStateManager = serviceManager.get<AppStateManager>();
    final viewModel = ReceiveViewModelImpl(
      this,
      serverWalletID,
      serverAccountID,
      userManager,
      walletManager,
      appStateManager,
      dataProviderManager.walletDataProvider,
      dataProviderManager.protonAddressProvider,
      dataProviderManager.walletKeysProvider,
      dataProviderManager.localBitcoinAddressDataProvider,
      dataProviderManager.receiveAddressDataProvider,
      isWalletView: isWalletView,
    );
    widget = ReceiveView(
      viewModel,
    );
    return widget;
  }
}
