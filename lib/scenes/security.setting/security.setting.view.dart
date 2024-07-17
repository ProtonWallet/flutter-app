import 'package:flutter/material.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/local_toast.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/models/unlock.type.dart';
import 'package:wallet/scenes/components/dropdown.button.v3.dart';
import 'package:wallet/scenes/components/page.layout.v1.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/recovery/recovery.section.dart';
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
          if (viewModel.error.isNotEmpty)
            Text(
              viewModel.error,
              style: FontManager.body2Regular(ProtonColors.signalError),
            ),
          const SizedBox(height: 10),
          RecoverySection(
            title: 'Two-factor authentication',
            description:
                'Add another layer of security to your account. You’ll need to verify yourself with 2FA every time you sign in.',
            isLoading: viewModel.isLoading,
            isSwitched: viewModel.hadSetup2FA,
            onChanged: (bool newValue) {
              // try to disable recovery
              if (!newValue) {
                viewModel.move(NavID.twoFactorAuthDisable);
              } else {
                viewModel.move(NavID.twoFactorAuthSetup);
              }
            },
          ),
          const SizedBox(height: 10),
          DropdownButtonV3(
              padding: const EdgeInsets.only(
                left: defaultPadding,
                right: defaultPadding,
                top: 14,
                bottom: 14,
              ),
              selected: viewModel.selectedType,
              labelText: S.of(context).unlock_with,
              width: MediaQuery.of(context).size.width,
              items: const [UnlockType.none, UnlockType.biometrics],
              itemsText: [
                UnlockType.none.enumToString(),
                UnlockType.biometrics.enumToString()
              ],
              onChanged: (newValue) async {
                final error = await viewModel.updateType(newValue);
                if (error.isNotEmpty && context.mounted) {
                  LocalToast.showErrorToast(context, error);
                }
              }),
        ],
      ),
    );
  }
}
