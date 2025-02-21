import 'package:flutter/material.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/extension/asset.gen.image.extension.dart';
import 'package:wallet/helper/extension/build.context.extension.dart';
import 'package:wallet/scenes/components/close.button.v1.dart';
import 'package:wallet/scenes/components/custom.header.dart';
import 'package:wallet/scenes/components/page.layout.v1.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/home.v3/sub.views/secure.your.wallet/secure.your.wallet.viewmodel.dart';

class SecureYourWalletView extends ViewBase<SecureYourWalletViewModel> {
  const SecureYourWalletView(SecureYourWalletViewModel viewModel)
      : super(viewModel, const Key("SecureYourWalletView"));

  @override
  Widget build(BuildContext context) {
    return PageLayoutV1(
      headerWidget: CustomHeader(
        buttonDirection: AxisDirection.right,
        button: CloseButtonV1(
            backgroundColor: ProtonColors.backgroundNorm,
            onPressed: () {
              Navigator.of(context).pop();
            }),
        padding: const EdgeInsets.all(0.0),
      ),
      backgroundColor: ProtonColors.backgroundSecondary,
      child: Transform.translate(
        offset: const Offset(0, -30),
        child: buildContent(context),
      ),
    );
  }

  Widget buildContent(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Assets.images.icon.lock.applyThemeIfNeeded(context).image(
            fit: BoxFit.fill,
            width: 240,
            height: 167,
          ),
      Text(
        context.local.secure_your_wallet,
        style: ProtonStyles.subheadline(color: ProtonColors.textNorm),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 6),
      Text(
        context.local.secure_your_wallet_desc,
        style: ProtonStyles.body2Regular(color: ProtonColors.textWeak),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: defaultPadding),
      ListTile(
        leading: Icon(
            !viewModel.hadSetupRecovery
                ? Icons.circle_outlined
                : Icons.check_circle_outline_rounded,
            color: ProtonColors.protonBlue,
            size: 20),
        minLeadingWidth: 10,
        title: Text(context.local.todos_backup_proton_account,
            style: !viewModel.hadSetupRecovery
                ? ProtonStyles.body2Medium(color: ProtonColors.protonBlue)
                : ProtonStyles.body2Medium(
                    color: ProtonColors.protonBlue,
                    decoration: TextDecoration.lineThrough)),
        trailing: Icon(Icons.arrow_forward_ios_rounded,
            color: ProtonColors.textDisable, size: 16),
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
        leading: Icon(
            viewModel.showWalletRecovery
                ? Icons.circle_outlined
                : Icons.check_circle_outline_rounded,
            color: ProtonColors.protonBlue,
            size: 20),
        minLeadingWidth: 10,
        title: Text(context.local.todos_backup_wallet_mnemonic,
            style: viewModel.showWalletRecovery
                ? ProtonStyles.body2Medium(color: ProtonColors.protonBlue)
                : ProtonStyles.body2Medium(
                    color: ProtonColors.protonBlue,
                    decoration: TextDecoration.lineThrough)),
        trailing: Icon(Icons.arrow_forward_ios_rounded,
            color: ProtonColors.textDisable, size: 16),
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
        leading: Icon(
            !viewModel.hadSetup2FA
                ? Icons.circle_outlined
                : Icons.check_circle_outline_rounded,
            color: ProtonColors.protonBlue,
            size: 20),
        minLeadingWidth: 10,
        title: Text(context.local.todos_setup_2fa,
            style: !viewModel.hadSetup2FA
                ? ProtonStyles.body2Medium(color: ProtonColors.protonBlue)
                : ProtonStyles.body2Medium(
                    color: ProtonColors.protonBlue,
                    decoration: TextDecoration.lineThrough)),
        trailing: Icon(Icons.arrow_forward_ios_rounded,
            color: ProtonColors.textDisable, size: 16),
        onTap: () {
          if (!viewModel.hadSetup2FA) {
            Navigator.of(context).pop();
            viewModel.showSecuritySetting();
          }
        },
      ),
    ]);
  }
}
