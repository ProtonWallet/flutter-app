import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/managers/features/wallet.list/wallet.list.bloc.model.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/scenes/backup.seed/backup.coordinator.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/backup.your.wallet/backup.your.wallet.view.dart';
import 'package:wallet/scenes/home.v3/sub.views/backup.your.wallet/backup.your.wallet.viewmodel.dart';

class BackupYourWalletCoordinator extends Coordinator {
  late ViewBase widget;
  final WalletMenuModel walletMenuModel;

  BackupYourWalletCoordinator(
    this.walletMenuModel,
  );

  void showSetupBackup() {
    showInBottomSheet(
      SetupBackupCoordinator(walletMenuModel.walletModel.walletID).start(),
      backgroundColor: ProtonColors.backgroundSecondary,
    );
  }

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    final dataProviderManager = serviceManager.get<DataProviderManager>();
    final viewModel = BackupYourWalletViewModelImpl(
      this,
      dataProviderManager.backupAlertTimerProvider,
      walletMenuModel,
    );
    widget = BackupYourWalletView(
      viewModel,
    );
    return widget;
  }
}
