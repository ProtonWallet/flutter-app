import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/provider/proton.wallet.provider.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/components/bottom.sheets/base.dart';
import 'package:wallet/scenes/home.v3/bottom.sheet/email.integration.setting.dart';
import 'package:wallet/scenes/home.v3/bottom.sheet/fiat.currency.setting.dart';
import 'package:wallet/scenes/home.v3/home.viewmodel.dart';
import 'package:wallet/theme/theme.font.dart';

class SecureYourWalletSheet {
  static void show(BuildContext context, HomeViewModel viewModel) {
    HomeModalBottomSheet.show(context,
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
                    viewModel.move(NavID.setupBackup);
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
                    WalletModel? walletModel =
                        Provider.of<ProtonWalletProvider>(context)
                            .protonWallet
                            .currentWallet;
                    AccountModel? accountModel =
                        Provider.of<ProtonWalletProvider>(context)
                            .protonWallet
                            .currentAccount;
                    if (walletModel != null && accountModel != null) {
                      viewModel.updateEmailIntegration(
                          walletModel, accountModel);
                    }
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
