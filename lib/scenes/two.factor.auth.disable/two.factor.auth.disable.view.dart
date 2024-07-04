import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wallet/scenes/components/button.v5.dart';
import 'package:wallet/scenes/components/onboarding/content.dart';
import 'package:wallet/scenes/components/textfield.2fa.dart';
import 'package:wallet/scenes/components/textfield.password.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/helper/local_toast.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/theme/theme.font.dart';
import 'package:wallet/l10n/generated/locale.dart';

import 'two.factor.auth.disable.viewmodel.dart';

class TwoFactorAuthDisableView extends ViewBase<TwoFactorAuthDisableViewModel> {
  const TwoFactorAuthDisableView(TwoFactorAuthDisableViewModel viewModel)
      : super(viewModel, const Key("TwoFactorAuthDisableView"));

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: build2FAConfirm(context));
  }

  Widget build2FAConfirm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Stack(children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 4,
            color: ProtonColors.backgroundSecondary,
            child: Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 20,
                    bottom: MediaQuery.of(context).size.height / 20),
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: 100.0,
                  ),
                  child: SvgPicture.asset(
                    'assets/images/wallet_creation/passphrase_icon.svg',
                    fit: BoxFit.contain,
                  ),
                )),
          ),
        ]),
        Container(
          alignment: Alignment.topCenter,
          width: MediaQuery.of(context).size.width,
          child: OnboardingContent(
              totalPages: 3,
              currentPage: 3,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 4 * 3,
              title: S.of(context).setting_2fa_disable,
              content: S.of(context).setting_2fa_code_hint,
              children: [
                Column(children: [
                  SizedBoxes.box12,
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (int i = 0; i < 6; i++)
                          TextField2FA(
                              width: 50,
                              height: 50,
                              suffixIcon: const Icon(Icons.close),
                              showSuffixIcon: false,
                              showEnabledBorder: true,
                              centerHorizontal: true,
                              maxLength: 1,
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
                              textInputAction: i == 5
                                  ? TextInputAction.done
                                  : TextInputAction.next,
                              digitOnly: true),
                      ]),
                  SizedBoxes.box18,
                  Container(
                      alignment: Alignment.centerLeft,
                      child: Text("Password",
                          style:
                              FontManager.body1Median(ProtonColors.textHint))),
                  TextFieldPassword(
                      width: MediaQuery.of(context).size.width,
                      controller: viewModel.passwordController),
                ]),
                ButtonV5(
                    onPressed: () async {
                      bool result = await viewModel.disable2FA();
                      if (context.mounted) {
                        if (result) {
                          Navigator.pop(context);
                        } else {
                          LocalToast.showErrorToast(
                              context, "Something error!");
                        }
                      }
                    },
                    text: S.of(context).next,
                    width: MediaQuery.of(context).size.width,
                    textStyle: FontManager.body1Median(ProtonColors.white),
                    height: 48),
                SizedBoxes.box12,
                ButtonV5(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    text: S.of(context).cancel,
                    width: MediaQuery.of(context).size.width,
                    backgroundColor: ProtonColors.white,
                    borderColor: ProtonColors.interactionNorm,
                    textStyle:
                        FontManager.body1Median(ProtonColors.interactionNorm),
                    height: 48),
              ]),
        ),
      ],
    );
  }
}
