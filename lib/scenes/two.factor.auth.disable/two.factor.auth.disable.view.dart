import 'package:flutter/material.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/helper/local_toast.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/button.v5.dart';
import 'package:wallet/scenes/components/button.v6.dart';
import 'package:wallet/scenes/components/close.button.v1.dart';
import 'package:wallet/scenes/components/page.layout.v1.dart';
import 'package:wallet/scenes/components/textfield.2fa.dart';
import 'package:wallet/scenes/components/textfield.text.v2.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/theme/theme.font.dart';

import 'two.factor.auth.disable.viewmodel.dart';

class TwoFactorAuthDisableView extends ViewBase<TwoFactorAuthDisableViewModel> {
  const TwoFactorAuthDisableView(TwoFactorAuthDisableViewModel viewModel)
      : super(viewModel, const Key("TwoFactorAuthDisableView"));

  @override
  Widget build(BuildContext context) {
    return build2FAConfirm(context);
  }

  Widget buildHeader(BuildContext context, String body) {
    return Column(
      children: [
        Assets.images.icon.lock.image(
          fit: BoxFit.fill,
          width: 240,
          height: 167,
        ),
        Text(
          S.of(context).setting_2fa_disable,
          style: FontManager.titleHeadline(ProtonColors.textNorm),
          textAlign: TextAlign.center,
        ),
        const SizedBox(
          height: 6,
        ),
        Text(
          body,
          style: FontManager.body2Regular(ProtonColors.textWeak),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget build2FAConfirm(BuildContext context) {
    return PageLayoutV1(
      backgroundColor: ProtonColors.white,
      headerWidget: Align(
        alignment: Alignment.centerRight,
        child: CloseButtonV1(
            backgroundColor: ProtonColors.backgroundProton,
            onPressed: () {
              Navigator.of(context).pop();
            }),
      ),
      bottomWidget: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(children: [
          ButtonV6(
            onPressed: () async {
              final bool result = await viewModel.disable2FA();
              if (context.mounted) {
                if (result) {
                  Navigator.pop(context);
                } else {
                  LocalToast.showErrorToast(context, viewModel.error);
                }
              }
            },
            text: S.of(context).submit,
            width: MediaQuery.of(context).size.width,
            backgroundColor: ProtonColors.protonBlue,
            borderColor: ProtonColors.protonBlue,
            textStyle: FontManager.body1Median(ProtonColors.white),
            height: 48,
          ),
          SizedBoxes.box12,
          ButtonV5(
            onPressed: () {
              Navigator.pop(context);
            },
            text: S.of(context).cancel,
            width: MediaQuery.of(context).size.width,
            backgroundColor: ProtonColors.protonShades20,
            borderColor: ProtonColors.protonShades20,
            elevation: 0.0,
            textStyle: FontManager.body1Median(ProtonColors.textNorm),
            height: 48,
          ),
        ]),
      ),
      child: Transform.translate(
        offset: const Offset(0, -30),
        child: Column(
          children: [
            buildHeader(
              context,
              "",
            ),
            TextFieldTextV2(
              borderColor: ProtonColors.textHint,
              labelText: S.of(context).password,
              hintText: S.of(context).password_hint,
              alwaysShowHint: true,
              textController: viewModel.passwordController,
              myFocusNode: viewModel.passphraseFocusNode,
              validation: (String _) {
                return "";
              },
              isPassword: true,
            ),
            SizedBoxes.box24,
            Text(
              S.of(context).setting_2fa_code_hint,
              style: FontManager.body2Regular(ProtonColors.textWeak),
              textAlign: TextAlign.center,
            ),
            SizedBoxes.box8,
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              for (int i = 0; i < 6; i++)
                TextField2FA(
                    width: 48,
                    controller: viewModel.digitControllers[i],
                    onChanged: (text) {
                      if (text.isNotEmpty) {
                        if (i < 5) {
                          FocusScope.of(context).nextFocus();
                        }
                      } else {
                        if (i > 0) {
                          FocusScope.of(context).previousFocus();
                        }
                      }
                    },
                    textInputAction:
                        i == 5 ? TextInputAction.done : TextInputAction.next,
                    digitOnly: true),
            ]),
          ],
        ),
      ),
    );
  }
}
