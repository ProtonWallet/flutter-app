import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/extension/build.context.extension.dart';
import 'package:wallet/helper/external.url.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/button.v6.dart';
import 'package:wallet/scenes/core/coordinator.dart';

void showAppCryptoErrorDialog(
  String errorMessage,
) {
  final BuildContext? context = Coordinator.rootNavigatorKey.currentContext;
  if (context != null) {
    showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: ProtonColors.backgroundNorm,
          title: Center(
              child: Text(
            context.local.bridge_error_wallet_decryption,
            style: ProtonStyles.subheadline(
              color: ProtonColors.textNorm,
            ),
          )),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Center(
                  child: Text(
                    context.local.app_crypto_error_content,
                    style: ProtonStyles.body2Medium(
                      color: ProtonColors.textNorm,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(
                  height: 2,
                ),
                GestureDetector(
                  child: Center(
                    child: Text(
                      "https://account.proton.me/mail/encryption-keys",
                      style: ProtonStyles.body2Medium(
                        color: ProtonColors.protonBlue,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  onTap: () {
                    ExternalUrl.shared.launchEncryptionKeys();
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                Center(
                  child: Text(
                    context.local.app_crypto_error_hint,
                    style: ProtonStyles.body2Medium(
                      color: ProtonColors.textWeak,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          actions: <Widget>[
            Center(
              child: Column(
                children: [
                  ButtonV6(
                    onPressed: () async {
                      Navigator.of(context).pop();
                    },
                    text: S.of(context).ok,
                    textStyle: ProtonStyles.body1Medium(
                        color: ProtonColors.textInverted),
                    backgroundColor: ProtonColors.protonBlue,
                    borderColor: ProtonColors.protonBlue,
                    width: context.width,
                    height: 55,
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  ButtonV6(
                    onPressed: () async {
                      ExternalUrl.shared.launchDataRecovery();
                    },
                    text: S.of(context).learn_more_small,
                    backgroundColor: ProtonColors.interActionWeakDisable,
                    borderColor: ProtonColors.interActionWeakDisable,
                    textStyle:
                        ProtonStyles.body1Medium(color: ProtonColors.textNorm),
                    width: context.width,
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
