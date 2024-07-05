import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wallet/constants/colors.gen.dart';
import 'package:wallet/scenes/components/button.v5.dart';

typedef VoidValueCallback = void Function(String, String);

Future<void> showAuthDialog(
  BuildContext context,
  int twoFaEnable,
  VoidValueCallback onAuth,
  VoidCallback onCancel,
) async {
  final passwordController = TextEditingController();
  final twofaController = TextEditingController();
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Enter your password'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Align text to the left
              children: <Widget>[
                const Text(
                  "Password",
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ColorName.weakLight),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 8),
                CupertinoTextField.borderless(
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  controller: passwordController,
                  style: const TextStyle(fontSize: 16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 16.0),
                ),
                const SizedBox(height: 16),
                if (twoFaEnable == 1)
                  const Text(
                    "Two-factor authentication code",
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: ColorName.weakLight),
                    textAlign: TextAlign.left,
                  ),
                if (twoFaEnable == 1) const SizedBox(height: 8),
                if (twoFaEnable == 1)
                  CupertinoTextField.borderless(
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ButtonV5(
                onPressed: () {
                  onCancel();
                  Navigator.of(context).pop();
                },
                text: 'Cancel',
                width: 100,
                height: 44,
              ),
              ButtonV5(
                onPressed: () {
                  var password = passwordController.value.text;
                  var tfa = twofaController.value.text;
                  onAuth(password, tfa);
                  Navigator.of(context).pop();
                },
                text: 'Authenticate',
                width: 160,
                height: 44,
              ),
            ],
          ),
        ],
      );
    },
  );
}
