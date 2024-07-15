import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/local_toast.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/bottom.sheets/base.dart';
import 'package:wallet/scenes/components/button.v5.dart';
import 'package:wallet/scenes/components/close.button.v1.dart';
import 'package:wallet/theme/theme.font.dart';

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
        backgroundColor: ProtonColors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
                alignment: Alignment.centerRight,
                child: CloseButtonV1(
                    backgroundColor: ProtonColors.backgroundProton,
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
                  style: FontManager.body1Median(
                      avatarTextColor ?? ProtonColors.white),
                ),
              ),
            const SizedBox(height: 10),
            if (name != null && !isBitcoinAddress)
              Text(name, style: FontManager.body1Median(ProtonColors.textNorm)),
            if (email != null &&
                name != email &&
                name == null &&
                !isBitcoinAddress)
              Text(email,
                  style: FontManager.body1Median(ProtonColors.textNorm)),
            if (email != null &&
                name != email &&
                name != null &&
                !isBitcoinAddress)
              Text(email,
                  style: FontManager.body2Regular(ProtonColors.textHint)),
            const SizedBox(height: defaultPadding),
            if (bitcoinAddress.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.of(context).bitcoin_address,
                    style: FontManager.body1Median(ProtonColors.textWeak),
                    textAlign: TextAlign.start,
                  ),
                  Text(bitcoinAddress,
                      maxLines: 5,
                      style: FontManager.body1Median(ProtonColors.textNorm)),
                  const SizedBox(height: 40),
                  ButtonV5(
                      onPressed: () async {
                        Clipboard.setData(ClipboardData(text: bitcoinAddress))
                            .then((_) {
                          if (context.mounted) {
                            LocalToast.showToast(
                                context, S.of(context).copied_address,
                                icon: null);
                          }
                        });
                      },
                      elevation: 0,
                      text: S.of(context).copy_address,
                      width: MediaQuery.of(context).size.width,
                      textStyle: FontManager.body1Median(ProtonColors.textNorm),
                      backgroundColor: ProtonColors.backgroundProton,
                      borderColor: ProtonColors.backgroundProton,
                      height: 48),
                  const SizedBox(height: 8),
                ],
              )
          ],
        ));
  }
}
