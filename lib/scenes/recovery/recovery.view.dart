import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wallet/components/page.layout.v1.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/recovery/recovery.section.dart';
import 'package:wallet/scenes/recovery/recovery.viewmodel.dart';
import 'package:wallet/theme/theme.font.dart';

class RecoveryView extends ViewBase<RecoveryViewModel> {
  const RecoveryView(RecoveryViewModel viewModel)
      : super(viewModel, const Key("RecoveryView"));

  @override
  Widget build(BuildContext context) {
    return PageLayoutV1(
      title: S.of(context).recovery,
      child: Column(
        children: [
          const SizedBox(height: defaultPadding),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text("Allow recovery by recovery phrase",
                style: FontManager.body2Regular(ProtonColors.textNorm)),
            CupertinoSwitch(
              value: viewModel.recoveryEnabled,
              activeColor: ProtonColors.protonBlue,
              onChanged: (bool newValue) {
                viewModel.updateRecovery(newValue);
              },
            )
          ]),
          const SizedBox(height: 16),
          RecoverySection(
            title: 'Account recovery phrase',
            description:
                'Some explanation here, lorem ipsum dolor sit ametmconsectetur adipiscing',
            logo: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: ProtonColors.textHint,
            ),
            warning: Icon(
              Icons.info_outline_rounded,
              color: ProtonColors.signalError,
              size: 14,
            ),
          ),

          const SizedBox(height: 8),
          RecoverySection(
            title: 'Wallet recovery seed',
            description:
                'Your secret seed is the ONLY way to recover your fund if you lose access to the wallet',
            logo: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: ProtonColors.textHint,
            ),
            warning: Icon(
              Icons.info_outline_rounded,
              color: ProtonColors.signalError,
              size: 14,
            ),
          ),
          const SizedBox(height: 8),
          // RecoverySection(
          //   title: 'Recovery email and phone',
          //   description:
          //       'Some explanation here, lorem ipsum dolor sit ametmconsectetur adipiscing',
          //   logo: Icon(
          //     Icons.arrow_forward_ios_rounded,
          //     size: 12,
          //     color: ProtonColors.textHint,
          //   ),
          // warning: Icon(
          //   Icons.info_outline_rounded,
          //   color: ProtonColors.signalError,
          //   size: 24,
          // ),
        ],
      ),
    );
  }
}
