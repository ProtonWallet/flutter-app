import 'package:flutter/material.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/extension/asset.gen.image.extension.dart';
import 'package:wallet/helper/extension/build.context.extension.dart';
import 'package:wallet/helper/external.url.dart';
import 'package:wallet/scenes/components/button.v6.dart';
import 'package:wallet/scenes/components/close.button.v1.dart';
import 'package:wallet/scenes/components/custom.header.dart';
import 'package:wallet/scenes/components/page.layout.v1.dart';
import 'package:wallet/scenes/components/underline.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/home.v3/sub.views/backup.your.proton/backup.your.proton.viewmodel.dart';

class BackupYourProtonView extends ViewBase<BackupYourProtonViewModel> {
  const BackupYourProtonView(BackupYourProtonViewModel viewModel)
      : super(viewModel, const Key("BackupYourProtonView"));

  @override
  Widget build(BuildContext context) {
    return PageLayoutV1(
      headerWidget: CustomHeader(
        buttonDirection: AxisDirection.right,
        padding: const EdgeInsets.all(0.0),
        button: CloseButtonV1(
            backgroundColor: ProtonColors.backgroundNorm,
            onPressed: () {
              Navigator.of(context).pop();
            }),
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
      Assets.images.icon.key.applyThemeIfNeeded(context).image(
            fit: BoxFit.fill,
            width: 240,
            height: 167,
          ),
      Text(
        context.local.backup_your_proton_alert_title,
        style: ProtonStyles.subheadline(color: ProtonColors.textNorm),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: defaultPadding),
      Center(
        child: Text(
          context.local.backup_your_proton_alert_content,
          style: ProtonStyles.body2Medium(
            color: ProtonColors.textWeak,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      const SizedBox(height: 8),
      Underline(
        color: ProtonColors.protonBlue,
        child: Text(
          context.local.learn_more,
          style: ProtonStyles.body2Medium(
            color: ProtonColors.protonBlue,
          ),
        ),
        onTap: () {
          /// show recover-encrypted-messages link
          /// this can be add after we merge other mr
          ExternalUrl.shared.launchProtonAccount();
        },
      ),
      const SizedBox(
        height: 30,
      ),
      ButtonV6(
        onPressed: () async {
          Navigator.of(context).pop();
          viewModel.showRecovery();
        },
        text: context.local.backup_your_wallet_alert_backup_now,
        width: context.width,
        textStyle: ProtonStyles.body1Medium(
          color: ProtonColors.textInverted,
        ),
        backgroundColor: ProtonColors.protonBlue,
        borderColor: ProtonColors.protonBlue,
        height: 55,
      ),
      const SizedBox(
        height: 10,
      ),
      ButtonV6(
        onPressed: () async {
          await viewModel.remindMeLater();
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        },
        text: context.local.backup_your_wallet_alert_remind_7_days_after,
        width: context.width,
        textStyle: ProtonStyles.body1Medium(
          color: ProtonColors.textNorm,
        ),
        backgroundColor: ProtonColors.interActionWeakDisable,
        borderColor: ProtonColors.interActionWeakDisable,
        height: 55,
      ),
    ]);
  }
}
