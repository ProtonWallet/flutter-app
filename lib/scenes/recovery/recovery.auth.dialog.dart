import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:wallet/constants/colors.gen.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/bottom.sheets/base.dart';
import 'package:wallet/scenes/components/button.v5.dart';
import 'package:wallet/scenes/components/button.v6.dart';
import 'package:wallet/scenes/components/close.button.v1.dart';
import 'package:wallet/scenes/components/custom.header.dart';
import 'package:wallet/scenes/components/textfield.text.v2.dart';
import 'package:wallet/theme/theme.font.dart';

typedef VoidValueCallback = Future<void> Function(String, String);

Future<void> showAuthBottomSheet(
  BuildContext context,
  int twoFaEnable,
  VoidValueCallback onAuth,
  VoidCallback onCancel,
) async {
  final passwordController = TextEditingController();
  final twofaController = TextEditingController();
  final passwordFocusNode = FocusNode();
  Future.delayed(
      const Duration(milliseconds: 200), passwordFocusNode.requestFocus);
  return HomeModalBottomSheet.show(context,
      isDismissible: false, // user must tap button!
      backgroundColor: ProtonColors.white,
      header: CustomHeader(
        buttonDirection: AxisDirection.right,
        button: CloseButtonV1(
            backgroundColor: ProtonColors.backgroundProton,
            onPressed: () {
              onCancel.call();
              Navigator.of(context).pop();
            }),
      ),
      child: SingleChildScrollView(
        child: Column(children: [
          SizedBox(
            width: max(360, MediaQuery.of(context).size.width - 80),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Align text to the left
              children: <Widget>[
                Transform.translate(
                  offset: const Offset(0, -20),
                  child: Center(
                    child: Text(S.of(context).password,
                        style: FontManager.titleHeadline(ProtonColors.textNorm),
                        textAlign: TextAlign.center),
                  ),
                ),
                TextFieldTextV2(
                  labelText: S.of(context).password,
                  hintText: S.of(context).password_hint,
                  textController: passwordController,
                  myFocusNode: passwordFocusNode,
                  validation: (String _) {
                    return "";
                  },
                  isPassword: true,
                  borderColor: ProtonColors.protonShades20,
                ),
                const SizedBox(height: 16),
                if (twoFaEnable != 0)
                  Center(
                    child: Text(
                      S.of(context).two_factor_code,
                      style: FontManager.titleHeadline(ProtonColors.textNorm),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (twoFaEnable != 0) const SizedBox(height: 16),
                if (twoFaEnable != 0)
                  Center(
                    child: Text(
                      S.of(context).two_factor_code_desc,
                      style: FontManager.body2Regular(ProtonColors.textWeak),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (twoFaEnable != 0) const SizedBox(height: 8),
                if (twoFaEnable != 0)
                  CupertinoTextField.borderless(
                    keyboardType: TextInputType.visiblePassword,
                    controller: twofaController,
                    style: const TextStyle(fontSize: 16),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      border: Border.all(color: ProtonColors.protonShades20),
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 16.0,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          ButtonV6(
            onPressed: () async {
              final password = passwordController.value.text;
              final tfa = twofaController.value.text;
              await onAuth(password, tfa);
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            text: S.of(context).authenticate,
            backgroundColor: ProtonColors.protonBlue,
            borderColor: ProtonColors.protonBlue,
            textStyle: FontManager.body1Median(ProtonColors.white),
            height: 48,
            width: max(
              330,
              MediaQuery.of(context).size.width - 110,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          ButtonV5(
            onPressed: () {
              onCancel.call();
              Navigator.of(context).pop();
            },
            text: S.of(context).cancel,
            backgroundColor: ProtonColors.protonShades20,
            borderColor: ProtonColors.protonShades20,
            textStyle: FontManager.body1Median(ProtonColors.textNorm),
            height: 48,
            width: max(
              330,
              MediaQuery.of(context).size.width - 110,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
        ]),
      ));
}
