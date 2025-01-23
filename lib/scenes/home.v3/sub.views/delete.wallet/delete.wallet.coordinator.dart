import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/managers/api.service.manager.dart';
import 'package:wallet/managers/app.state.manager.dart';
import 'package:wallet/managers/features/wallet.list/wallet.list.bloc.model.dart';
import 'package:wallet/managers/features/wallet/delete.wallet.bloc.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/scenes/backup.seed/backup.coordinator.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/delete.wallet/delete.wallet.view.dart';
import 'package:wallet/scenes/home.v3/sub.views/delete.wallet/delete.wallet.viewmodel.dart';

class DeleteWalletCoordinator extends Coordinator {
  late ViewBase widget;
  final WalletMenuModel walletMenuModel;
  final bool triggerFromSidebar;

  DeleteWalletCoordinator(
    this.walletMenuModel, {
    required this.triggerFromSidebar,
  });

  void showSetupBackup() {
    showInBottomSheet(
      SetupBackupCoordinator(walletMenuModel.walletModel.walletID).start(),
      backgroundColor: ProtonColors.white,
    );
  }

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    final dataProviderManager = serviceManager.get<DataProviderManager>();
    final appStateManager = serviceManager.get<AppStateManager>();
    final apiServiceManager = serviceManager.get<ProtonApiServiceManager>();

    /// build delete wallet feature bloc
    final deleteWalletBloc = DeleteWalletBloc(
      dataProviderManager.walletDataProvider,
      apiServiceManager.getWalletClient(),
      apiServiceManager.getProtonUsersApiClient(),
      appStateManager,
    );

    final viewModel = DeleteWalletViewModelImpl(
      appStateManager,
      deleteWalletBloc,
      walletMenuModel,
      this,
      triggerFromSidebar: triggerFromSidebar,
    );
    widget = DeleteWalletView(
      viewModel,
    );
    return widget;
  }
}
