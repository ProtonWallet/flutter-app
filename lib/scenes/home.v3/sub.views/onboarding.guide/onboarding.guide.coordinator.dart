import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/managers/app.state.manager.dart';
import 'package:wallet/managers/features/wallet.list/wallet.list.bloc.dart';
import 'package:wallet/managers/features/wallet/create.wallet.bloc.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/onboarding.guide/onboarding.guide.view.dart';
import 'package:wallet/scenes/home.v3/sub.views/onboarding.guide/onboarding.guide.viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/upgrade/upgrade.coordinator.dart';
import 'package:wallet/scenes/import/import.coordinator.dart';

class OnboardingGuideCoordinator extends Coordinator {
  late ViewBase widget;
  final CreateWalletBloc createWalletBloc;
  final WalletListBloc walletListBloc;

  OnboardingGuideCoordinator(
    this.walletListBloc,
    this.createWalletBloc,
  );

  void showImportWallet(String preInputName) {
    final view = ImportCoordinator(preInputName).start();
    showInBottomSheet(view);
  }

  void showUpgrade() {
    showInBottomSheet(
      UpgradeCoordinator(isWalletAccountExceedLimit: false).start(),
      backgroundColor: ProtonColors.white,
    );
  }

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    final walletManager = serviceManager.get<WalletManager>();
    final dataProviderManager = serviceManager.get<DataProviderManager>();
    final appStateManager = serviceManager.get<AppStateManager>();

    final viewModel = OnboardingGuideViewModelImpl(
      this,
      walletManager,
      appStateManager,
      dataProviderManager,
      walletListBloc,
      createWalletBloc,
    );
    widget = OnboardingGuideView(
      viewModel,
    );
    return widget;
  }
}
