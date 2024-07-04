import 'package:wallet/managers/features/create.wallet.bloc.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/scenes/passphrase/passphrase.view.dart';
import 'package:wallet/scenes/passphrase/passphrase.viewmodel.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';

class SetupPassPhraseCoordinator extends Coordinator {
  late ViewBase widget;
  final String strMnemonic;

  SetupPassPhraseCoordinator(this.strMnemonic);

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    var userManager = serviceManager.get<UserManager>();
    var dataProviderManager = serviceManager.get<DataProviderManager>();
    var createWalletBloc = CreateWalletBloc(
      userManager,
      dataProviderManager.walletDataProvider,
      dataProviderManager.walletKeysProvider,
      dataProviderManager.walletPassphraseProvider,
    );

    var viewModel = SetupPassPhraseViewModelImpl(
      this,
      strMnemonic,
      createWalletBloc,
      userManager.userID,
    );
    widget = SetupPassPhraseView(
      viewModel,
    );
    return widget;
  }
}
