import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/page.layout.v1.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/home.v3/sub.views/secure.your.wallet/secure.your.wallet.viewmodel.dart';

class SecureYourWalletView extends ViewBase<SecureYourWalletViewModel> {
  const SecureYourWalletView(SecureYourWalletViewModel viewModel)
      : super(viewModel, const Key("SecureYourWalletView"));

  @override
  Widget build(BuildContext context) {
    return PageLayoutV1(
        showHeader: false,
        backgroundColor: ProtonColors.backgroundSecondary,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(S.of(context).secure_your_wallet,
              style: ProtonStyles.body2Medium(color: ProtonColors.textNorm)),
          const SizedBox(height: 10),
          ListTile(
            title: Text(S.of(context).todos_backup_proton_account,
                style: !viewModel.hadSetupRecovery
                    ? ProtonStyles.body2Medium(color: ProtonColors.protonBlue)
                    : ProtonStyles.body2Medium(color: ProtonColors.protonBlue)
                        .copyWith(
                        decoration: TextDecoration.lineThrough,
                      )),
            trailing: Icon(Icons.arrow_forward_ios_rounded,
                color: ProtonColors.protonBlue, size: 14),
            onTap: () {
              if (!viewModel.hadSetupRecovery) {
                Navigator.of(context).pop();
                viewModel.showRecovery();
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
                    ? ProtonStyles.body2Medium(color: ProtonColors.protonBlue)
                    : ProtonStyles.body2Medium(color: ProtonColors.protonBlue)
                        .copyWith(
                        decoration: TextDecoration.lineThrough,
                      )),
            trailing: Icon(Icons.arrow_forward_ios_rounded,
                color: ProtonColors.protonBlue, size: 14),
            onTap: () {
              if (viewModel.showWalletRecovery) {
                Navigator.of(context).pop();
                viewModel.showSetupBackup();
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
                    ? ProtonStyles.body2Medium(color: ProtonColors.protonBlue)
                    : ProtonStyles.body2Medium(color: ProtonColors.protonBlue)
                        .copyWith(
                        decoration: TextDecoration.lineThrough,
                      )),
            trailing: Icon(Icons.arrow_forward_ios_rounded,
                color: ProtonColors.protonBlue, size: 14),
            onTap: () {
              if (!viewModel.hadSetup2FA) {
                Navigator.of(context).pop();
                viewModel.showSecuritySetting();
              }
            },
          ),
        ]));
  }
}
