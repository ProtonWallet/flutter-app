import 'package:wallet/managers/api.service.manager.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/network/api.service.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/paper.wallet/paper.wallet.view.dart';
import 'package:wallet/scenes/paper.wallet/paper.wallet.viewmodel.dart';

class PaperWalletCoordinator extends Coordinator {
  late ViewBase widget;
  final WalletModel walletModel;
  final AccountModel accountModel;
  final int receiveAddressIndex;

  PaperWalletCoordinator(
    this.walletModel,
    this.accountModel,
    this.receiveAddressIndex,
  );

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    final walletManager = serviceManager.get<WalletManager>();
    final dataProviderManager = serviceManager.get<DataProviderManager>();
    final apiServiceManager = serviceManager.get<ProtonApiServiceManager>();
    final viewModel = PaperWalletViewModelImpl(
      this,
      walletModel,
      accountModel,
      receiveAddressIndex,
      apiServiceManager.getApiService().getBlockchainClient(),
      dataProviderManager.userSettingsDataProvider,
      dataProviderManager.walletDataProvider,
      dataProviderManager.walletNameProvider,
      walletManager,
    );
    widget = PaperWalletView(
      viewModel,
    );
    return widget;
  }
}
