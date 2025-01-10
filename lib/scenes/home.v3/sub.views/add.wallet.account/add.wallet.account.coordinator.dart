import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/managers/app.state.manager.dart';
import 'package:wallet/managers/features/wallet/create.wallet.bloc.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/add.wallet.account/add.wallet.account.view.dart';
import 'package:wallet/scenes/home.v3/sub.views/add.wallet.account/add.wallet.account.viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/upgrade/upgrade.coordinator.dart';

class AddWalletAccountCoordinator extends Coordinator {
  late ViewBase widget;
  final String walletID;

  AddWalletAccountCoordinator(
    this.walletID,
  );

  @override
  void end() {}

  void showUpgrade() {
    showInBottomSheet(
      UpgradeCoordinator(isWalletAccountExceedLimit: true).start(),
      backgroundColor: ProtonColors.white,
    );
  }

  @override
  ViewBase<ViewModel> start() {
    final userManager = serviceManager.get<UserManager>();
    final dataProviderManager = serviceManager.get<DataProviderManager>();
    final appStateManager = serviceManager.get<AppStateManager>();

    /// build create wallet feature bloc
    final createWalletBloc = CreateWalletBloc(
      userManager,
      dataProviderManager.walletDataProvider,
      dataProviderManager.walletKeysProvider,
      dataProviderManager.walletPassphraseProvider,
    );

    final viewModel = AddWalletAccountViewModelImpl(
      appStateManager,
      createWalletBloc,
      dataProviderManager.walletDataProvider,
      defaultFiatCurrency,
      walletID,
      this,
    );
    widget = AddWalletAccountView(
      viewModel,
    );
    return widget;
  }
}
