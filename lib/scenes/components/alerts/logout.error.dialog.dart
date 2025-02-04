import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/extension/build.context.extension.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/button.v5.dart';
import 'package:wallet/scenes/core/coordinator.dart';

void showLogoutErrorDialog(
  String errorMessage,
  VoidCallback onLogout,
) {
  final BuildContext? context = Coordinator.rootNavigatorKey.currentContext;
  if (context != null) {
    showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: ProtonColors.backgroundNorm,
          title: Center(child: Text(S.of(context).session_expired_title)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                SizedBox(
                  width: 300,
                  child: Text(S.of(context).session_expired_content),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          actions: <Widget>[
            Center(
              child: SizedBox(
                height: 50,
                child: ButtonV5(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onLogout();
                  },
                  text: context.local.logout,
                  textStyle: ProtonStyles.body1Medium(
                      color: ProtonColors.textInverted),
                  backgroundColor: ProtonColors.signalError,
                  width: 300,
                  height: 55,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
