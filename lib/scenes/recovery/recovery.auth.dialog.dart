import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wallet/constants/colors.gen.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/button.v5.dart';
import 'package:wallet/scenes/components/button.v6.dart';
import 'package:wallet/scenes/components/textfield.text.v2.dart';
import 'package:wallet/theme/theme.font.dart';

typedef VoidValueCallback = Future<void> Function(String, String);

Future<void> showAuthDialog(
  BuildContext context,
  int twoFaEnable,
  VoidValueCallback onAuth,
  VoidCallback onCancel,
) async {
  final passwordController = TextEditingController();
  final twofaController = TextEditingController();
  final passwordFocusNode = FocusNode();
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: ProtonColors.backgroundProton,
        title: Center(
          child: Text(
            S.of(context).password_hint,
            style: FontManager.body1Median(ProtonColors.textNorm),
          ),
        ),
        content: SingleChildScrollView(
          child: SizedBox(
            width: max(360, MediaQuery.of(context).size.width - 80),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Align text to the left
              children: <Widget>[
                TextFieldTextV2(
                  labelText: S.of(context).password,
                  textController: passwordController,
                  myFocusNode: passwordFocusNode,
                  validation: (String _) {
                    return "";
                  },
                  isPassword: true,
                ),
                const SizedBox(height: 16),
                if (twoFaEnable == 1)
                  const Center(
                    child: Text(
                      "Two-factor authentication code",
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: ColorName.weakLight),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (twoFaEnable == 1) const SizedBox(height: 8),
                if (twoFaEnable == 1)
                  CupertinoTextField.borderless(
                    keyboardType: TextInputType.visiblePassword,
                    controller: twofaController,
                    style: const TextStyle(fontSize: 16),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
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
        ),
        actions: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
                elevation: 0.0,
              ),
            ],
          ),
        ],
      );
    },
  );
}
