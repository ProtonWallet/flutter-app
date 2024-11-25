import 'package:wallet/managers/features/wallet/create.wallet.bloc.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/passphrase/passphrase.view.dart';
import 'package:wallet/scenes/passphrase/passphrase.viewmodel.dart';

class SetupPassPhraseCoordinator extends Coordinator {
  late ViewBase widget;
  final String strMnemonic;

  SetupPassPhraseCoordinator(this.strMnemonic);

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    final userManager = serviceManager.get<UserManager>();
    final walletManager = serviceManager.get<WalletManager>();
    final dataProviderManager = serviceManager.get<DataProviderManager>();
    final createWalletBloc = CreateWalletBloc(
      userManager,
      dataProviderManager.walletDataProvider,
      dataProviderManager.walletKeysProvider,
      dataProviderManager.walletPassphraseProvider,
    );

    final viewModel = SetupPassPhraseViewModelImpl(
      this,
      strMnemonic,
      createWalletBloc,
      userManager.userID,
      walletManager,
    );
    widget = SetupPassPhraseView(
      viewModel,
    );
    return widget;
  }
}
