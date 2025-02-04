import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/external.url.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/button.v6.dart';
import 'package:wallet/scenes/core/coordinator.dart';

void showUpgradeErrorDialog(
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
          title: Center(child: Text(S.of(context).force_upgrade)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                SizedBox(
                  width: 300,
                  child: Text(errorMessage),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          actions: <Widget>[
            SizedBox(
              width: 300,
              child: Column(
                children: [
                  ButtonV6(
                    onPressed: () async {
                      ExternalUrl.shared.lanuchStore();
                    },
                    text: S.of(context).upgrade,
                    textStyle: ProtonStyles.body1Medium(
                        color: ProtonColors.textInverted),
                    backgroundColor: ProtonColors.protonBlue,
                    borderColor: ProtonColors.protonBlue,
                    width: 300,
                    height: 55,
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  ButtonV6(
                    onPressed: () async {
                      ExternalUrl.shared.lanuchForceUpgradeLearnMore();
                    },
                    text: S.of(context).learn_more,
                    backgroundColor: ProtonColors.interActionWeak,
                    borderColor: ProtonColors.interActionWeak,
                    textStyle:
                        ProtonStyles.body1Medium(color: ProtonColors.textNorm),
                    width: 300,
                    height: 55,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
