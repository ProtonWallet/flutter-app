import 'package:flutter/material.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/dropdown.button.v2.dart';
import 'package:wallet/scenes/components/page.layout.v1.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/security.setting/security.setting.viewmodel.dart';
import 'package:wallet/theme/theme.font.dart';

class SecuritySettingView extends ViewBase<SecuritySettingViewModel> {
  const SecuritySettingView(SecuritySettingViewModel viewModel)
      : super(viewModel, const Key("SecuritySettingView"));

  @override
  Widget build(BuildContext context) {
    return PageLayoutV1(
      title: S.of(context).security,
      child: Column(
        children: [
          const SizedBox(height: defaultPadding),
          GestureDetector(
              onTap: () {
                // viewModel.move(NavID.twoFactorAuthSetup); // `TODO`:: add back after fix ui
              },
              child: Container(
                padding: const EdgeInsets.all(defaultPadding),
                decoration: BoxDecoration(
                  color: ProtonColors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(18.0)),
                ),
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            S.of(context).setting_2fa_setup,
                            style:
                                FontManager.body2Regular(ProtonColors.textNorm),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 12,
                            color: ProtonColors.textHint,
                          )
                        ]),
                  ],
                ),
              )),
          const SizedBox(height: 10),
          DropdownButtonV2(
              labelText: S.of(context).unlock_with,
              width: MediaQuery.of(context).size.width,
              items: const ["Face ID", "Biometrics"],
              itemsText: const ["Face ID", "Biometrics"],
              valueNotifier: ValueNotifier("Face ID")),
        ],
      ),
    );
  }
}
