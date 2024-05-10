import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/home.v3/bottom.sheet/base.dart';
import 'package:wallet/scenes/home.v3/bottom.sheet/email.integration.setting.dart';
import 'package:wallet/scenes/home.v3/bottom.sheet/fiat.currency.setting.dart';
import 'package:wallet/scenes/home.v3/home.viewmodel.dart';
import 'package:wallet/theme/theme.font.dart';

class SecureYourWalletSheet {
  static void show(BuildContext context, HomeViewModel viewModel) {
    HomeModalBottomSheet.show(context, viewModel,
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(S.of(context).secure_your_wallet,
                  style: FontManager.body2Median(ProtonColors.textNorm)),
              const SizedBox(height: 10),
              ListTile(
                title: Text(S.of(context).todos_backup_proton_account,
                    style: FontManager.body2Median(ProtonColors.protonBlue)),
                trailing: Icon(Icons.arrow_forward_ios_rounded,
                    color: ProtonColors.protonBlue, size: 14),
                onTap: () {},
              ),
              const Divider(
                height: 0.3,
                thickness: 0.3,
              ),
              ListTile(
                title: Text(S.of(context).todos_backup_wallet_mnemonic,
                    style: FontManager.body2Median(ProtonColors.protonBlue)),
                trailing: Icon(Icons.arrow_forward_ios_rounded,
                    color: ProtonColors.protonBlue, size: 14),
                onTap: () {
                  if (CommonHelper.checkSelectWallet(context)) {
                    viewModel.move(ViewIdentifiers.setupBackup);
                  }
                },
              ),
              const Divider(
                height: 0.3,
                thickness: 0.3,
              ),
              ListTile(
                title: Text(S.of(context).todos_setup_2fa,
                    style: FontManager.body2Median(ProtonColors.protonBlue)),
                trailing: Icon(Icons.arrow_forward_ios_rounded,
                    color: ProtonColors.protonBlue, size: 14),
                onTap: () {},
              ),
              const Divider(
                height: 0.3,
                thickness: 0.3,
              ),
              ListTile(
                title: Text(S.of(context).todos_setup_email_integration,
                    style: FontManager.body2Median(ProtonColors.protonBlue)),
                trailing: Icon(Icons.arrow_forward_ios_rounded,
                    color: ProtonColors.protonBlue, size: 14),
                onTap: () {
                  if (CommonHelper.checkSelectWallet(context)) {
                    viewModel.updateEmailIntegration();
                    EmailIntegrationSheet.show(context, viewModel);
                  }
                },
              ),
              const Divider(
                height: 0.3,
                thickness: 0.3,
              ),
              ListTile(
                title: Text(S.of(context).todos_setup_fiat,
                    style: FontManager.body2Median(ProtonColors.protonBlue)),
                trailing: Icon(Icons.arrow_forward_ios_rounded,
                    color: ProtonColors.protonBlue, size: 14),
                onTap: () {
                  if (CommonHelper.checkSelectWallet(context)) {
                    FiatCurrencySettingSheet.show(context, viewModel);
                  }
                },
              )
            ]));
  }
}
