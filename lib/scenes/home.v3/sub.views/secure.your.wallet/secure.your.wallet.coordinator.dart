import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/scenes/backup.seed/backup.coordinator.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/secure.your.wallet/secure.your.wallet.view.dart';
import 'package:wallet/scenes/home.v3/sub.views/secure.your.wallet/secure.your.wallet.viewmodel.dart';
import 'package:wallet/scenes/recovery/recovery.coordinator.dart';
import 'package:wallet/scenes/security.setting/security.setting.coordinator.dart';

class SecureYourWalletCoordinator extends Coordinator {
  late ViewBase widget;
  final String walletID;
  final bool hadSetupRecovery;
  final bool showWalletRecovery;
  final bool hadSetup2FA;

  SecureYourWalletCoordinator(
    this.walletID, {
    required this.hadSetupRecovery,
    required this.showWalletRecovery,
    required this.hadSetup2FA,
  });

  void showSecuritySetting() {
    final view = SecuritySettingCoordinator().start();
    showInBottomSheet(view);
  }

  void showRecovery() {
    final view = RecoveryCoordinator().start();
    showInBottomSheet(view);
  }

  void showSetupBackup() {
    showInBottomSheet(
      SetupBackupCoordinator(walletID).start(),
      backgroundColor: ProtonColors.backgroundSecondary,
    );
  }

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    final viewModel = SecureYourWalletViewModelImpl(
      this,
      hadSetupRecovery: hadSetupRecovery,
      showWalletRecovery: showWalletRecovery,
      hadSetup2FA: hadSetup2FA,
    );
    widget = SecureYourWalletView(
      viewModel,
    );
    return widget;
  }
}
