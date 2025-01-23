import 'package:wallet/managers/app.state.manager.dart';
import 'package:wallet/managers/features/wallet.list/wallet.list.bloc.model.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/passphrase/passphrase.view.dart';
import 'package:wallet/scenes/home.v3/sub.views/passphrase/passphrase.viewmodel.dart';

class PassphraseCoordinator extends Coordinator {
  late ViewBase widget;
  final WalletMenuModel walletMenuModel;

  PassphraseCoordinator(this.walletMenuModel);

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    final walletManager = serviceManager.get<WalletManager>();
    final dataProviderManager = serviceManager.get<DataProviderManager>();
    final appStateManager = serviceManager.get<AppStateManager>();
    final viewModel = PassphraseViewModelImpl(
      this,
      walletManager,
      appStateManager,
      walletMenuModel,
      dataProviderManager.walletPassphraseProvider,
      dataProviderManager.bdkTransactionDataProvider,
    );
    widget = PassphraseView(
      viewModel,
    );
    return widget;
  }
}
