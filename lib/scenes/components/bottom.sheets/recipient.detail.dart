import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/common.helper.dart';
import 'package:wallet/helper/local_toast.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/bottom.sheets/base.dart';
import 'package:wallet/scenes/components/button.v5.dart';
import 'package:wallet/scenes/components/close.button.v1.dart';

class RecipientDetailSheet {
  static void show(
    BuildContext context,
    String? name,
    String? email,
    String bitcoinAddress, {
    required bool isBitcoinAddress,
    Color? avatarColor,
    Color? avatarTextColor,
  }) {
    HomeModalBottomSheet.show(context,
        backgroundColor: ProtonColors.backgroundSecondary,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
                alignment: Alignment.centerRight,
                child: CloseButtonV1(
                    backgroundColor: ProtonColors.backgroundNorm,
                    onPressed: () {
                      Navigator.of(context).pop();
                    })),
            if (!isBitcoinAddress)
              CircleAvatar(
                backgroundColor: avatarColor ?? ProtonColors.protonBlue,
                radius: 30,
                child: Text(
                  name != null
                      ? CommonHelper.getFirstNChar(name, 1).toUpperCase()
                      : email != null
                          ? CommonHelper.getFirstNChar(email, 1).toUpperCase()
                          : "",
                  style: ProtonStyles.body1Medium(
                      color: avatarTextColor ?? ProtonColors.textInverted),
                ),
              ),
            const SizedBox(height: 10),
            if (name != null && !isBitcoinAddress)
              Text(name,
                  style:
                      ProtonStyles.body1Medium(color: ProtonColors.textNorm)),
            if (email != null &&
                name != email &&
                name == null &&
                !isBitcoinAddress)
              Text(email,
                  style:
                      ProtonStyles.body1Medium(color: ProtonColors.textNorm)),
            if (email != null &&
                name != email &&
                name != null &&
                !isBitcoinAddress)
              Text(email,
                  style:
                      ProtonStyles.body2Regular(color: ProtonColors.textHint)),
            const SizedBox(height: defaultPadding),
            if (bitcoinAddress.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.of(context).bitcoin_address,
                    style:
                        ProtonStyles.body1Medium(color: ProtonColors.textWeak),
                    textAlign: TextAlign.start,
                  ),
                  Text(bitcoinAddress,
                      maxLines: 5,
                      style: ProtonStyles.body1Medium(
                        color: ProtonColors.textNorm,
                      )),
                  const SizedBox(height: 40),
                  ButtonV5(
                      onPressed: () async {
                        Clipboard.setData(ClipboardData(text: bitcoinAddress))
                            .then((_) {
                          if (context.mounted) {
                            LocalToast.showToast(
                              context,
                              S.of(context).copied_address,
                            );
                          }
                        });
                      },
                      text: S.of(context).copy_address,
                      width: MediaQuery.of(context).size.width,
                      textStyle: ProtonStyles.body1Medium(
                        color: ProtonColors.textNorm,
                      ),
                      backgroundColor: ProtonColors.interActionWeakDisable,
                      height: 55),
                  const SizedBox(height: 8),
                ],
              )
          ],
        ));
  }
}
