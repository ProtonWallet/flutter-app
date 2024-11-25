import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/page.layout.v1.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/home.v3/sub.views/secure.your.wallet/secure.your.wallet.viewmodel.dart';
import 'package:wallet/theme/theme.font.dart';

class SecureYourWalletView extends ViewBase<SecureYourWalletViewModel> {
  const SecureYourWalletView(SecureYourWalletViewModel viewModel)
      : super(viewModel, const Key("SecureYourWalletView"));

  @override
  Widget build(BuildContext context) {
    return PageLayoutV1(
        showHeader: false,
        expanded: false,
        backgroundColor: ProtonColors.white,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(S.of(context).secure_your_wallet,
              style: FontManager.body2Median(ProtonColors.textNorm)),
          const SizedBox(height: 10),
          ListTile(
            title: Text(S.of(context).todos_backup_proton_account,
                style: !viewModel.hadSetupRecovery
                    ? FontManager.body2Median(ProtonColors.protonBlue)
                    : FontManager.body2MedianLineThrough(
                        ProtonColors.protonBlue)),
            trailing: Icon(Icons.arrow_forward_ios_rounded,
                color: ProtonColors.protonBlue, size: 14),
            onTap: () {
              if (!viewModel.hadSetupRecovery) {
                Navigator.of(context).pop();
                viewModel.coordinator.showRecovery();
              }
            },
          ),
          const Divider(
            height: 0.3,
            thickness: 0.3,
          ),
          ListTile(
            title: Text(S.of(context).todos_backup_wallet_mnemonic,
                style: viewModel.showWalletRecovery
                    ? FontManager.body2Median(ProtonColors.protonBlue)
                    : FontManager.body2MedianLineThrough(
                        ProtonColors.protonBlue)),
            trailing: Icon(Icons.arrow_forward_ios_rounded,
                color: ProtonColors.protonBlue, size: 14),
            onTap: () {
              if (viewModel.showWalletRecovery) {
                Navigator.of(context).pop();
                viewModel.coordinator.showSetupBackup();
              }
            },
          ),
          const Divider(
            height: 0.3,
            thickness: 0.3,
          ),
          ListTile(
            title: Text(S.of(context).todos_setup_2fa,
                style: !viewModel.hadSetup2FA
                    ? FontManager.body2Median(ProtonColors.protonBlue)
                    : FontManager.body2MedianLineThrough(
                        ProtonColors.protonBlue)),
            trailing: Icon(Icons.arrow_forward_ios_rounded,
                color: ProtonColors.protonBlue, size: 14),
            onTap: () {
              if (!viewModel.hadSetup2FA) {
                Navigator.of(context).pop();
                viewModel.coordinator.showSecuritySetting();
              }
            },
          ),
        ]));
  }
}
