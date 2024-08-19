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
    this.serverAccountID, {
    required this.isWalletView,
  });

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    final userManager = serviceManager.get<UserManager>();
    final dataProviderManager = serviceManager.get<DataProviderManager>();
    final viewModel = ReceiveViewModelImpl(
      this,
      serverWalletID,
      serverAccountID,
      userManager,
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
