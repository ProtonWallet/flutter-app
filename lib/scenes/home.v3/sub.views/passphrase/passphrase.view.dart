import 'package:flutter/material.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/extension/build.context.extension.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/button.v6.dart';
import 'package:wallet/scenes/components/page.layout.v1.dart';
import 'package:wallet/scenes/components/textfield.text.v2.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/home.v3/sub.views/passphrase/passphrase.viewmodel.dart';

class PassphraseView extends ViewBase<PassphraseViewModel> {
  const PassphraseView(PassphraseViewModel viewModel)
      : super(viewModel, const Key("PassphraseView"));

  @override
  Widget build(BuildContext context) {
    return PageLayoutV1(
      showHeader: false,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 10),
        Text(
          viewModel.walletName,
          style: ProtonStyles.headline(color: ProtonColors.textNorm),
        ),
        const SizedBox(height: 10),
        Text(
          S.of(context).wallet_passphrase_unlock_desc,
          style: ProtonStyles.body2Regular(color: ProtonColors.textWeak),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          child: Column(children: [
            TextFieldTextV2(
              labelText: S.of(context).passphrase_label,
              hintText: S.of(context).passphrase_recovery_hint,
              alwaysShowHint: true,
              textController: viewModel.walletRecoverPassphraseController,
              myFocusNode: viewModel.walletRecoverPassphraseFocusNode,
              validation: (String value) {
                if (value.isEmpty) {
                  return "Required";
                }
                return "";
              },
              isPassword: true,
            ),
          ]),
        ),
        if (!viewModel.isWalletPassphraseMatch)
          Text(
            S.of(context).wrong_passphrase,
            style: ProtonStyles.body2Medium(color: ProtonColors.notificationError),
          ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.only(top: 20),
          margin: const EdgeInsets.symmetric(
            horizontal: defaultButtonPadding,
          ),
          child: ButtonV6(
              onPressed: () async {
                final passphrase =
                    viewModel.walletRecoverPassphraseController.text;
                final match = await viewModel.checkFingerprint(
                  passphrase,
                );
                if (match) {
                  await viewModel.savePassphrase(passphrase);
                }

                /// reset passphrase text to empty
                viewModel.walletRecoverPassphraseController.text = "";
                if (context.mounted && match) {
                  Navigator.of(context).pop();
                }
              },
              backgroundColor: ProtonColors.protonBlue,
              text: S.of(context).submit,
              width: context.width,
              textStyle: ProtonStyles.body1Medium(
                color: ProtonColors.textInverted,
              ),
              height: 55),
        ),
      ]),
    );
  }
}
