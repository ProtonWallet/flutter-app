import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallet/components/bottom.sheets/base.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/components/close.button.v1.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/local_toast.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/theme/theme.font.dart';

class RecipientDetailSheet {
  static void show(BuildContext context, String? name, String? email,
      String bitcoinAddress, bool isBitcoinAddress) {
    HomeModalBottomSheet.show(context,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
                alignment: Alignment.centerRight,
                child: CloseButtonV1(onPressed: () {
                  Navigator.of(context).pop();
                })),
            isBitcoinAddress
                ? CircleAvatar(
                    backgroundColor: ProtonColors.protonBlue,
                    radius: 16,
                    child: Text(
                      "B",
                      style: FontManager.captionSemiBold(ProtonColors.white),
                    ),
                  )
                : CircleAvatar(
                    backgroundColor: ProtonColors.protonBlue,
                    radius: 16,
                    child: Text(
                      name != null
                          ? CommonHelper.getFirstNChar(name, 1).toUpperCase()
                          : "",
                      style: FontManager.captionSemiBold(ProtonColors.white),
                    ),
                  ),
            if (name != null)
              Text(name, style: FontManager.body1Median(ProtonColors.textNorm)),
            if (email != null && name != email && !isBitcoinAddress)
              Text(email,
                  style: FontManager.body2Regular(ProtonColors.textNorm)),
            const SizedBox(height: defaultPadding),
            if (bitcoinAddress.isNotEmpty)
              Column(
                children: [
                  Text(S.of(context).bitcoin_address,
                      style: FontManager.captionRegular(ProtonColors.textWeak)),
                  Text(bitcoinAddress,
                          overflow: TextOverflow.ellipsis,
                          style:
                              FontManager.body2Regular(ProtonColors.textNorm)),
                  const SizedBox(height: 20),
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
                      text: S.of(context).copy_address,
                      width: MediaQuery.of(context).size.width,
                      textStyle: FontManager.body1Median(ProtonColors.textNorm),
                      backgroundColor: ProtonColors.textWeakPressed,
                      borderColor: ProtonColors.textWeakPressed,
                      height: 48),
                  const SizedBox(height: 8),
                ],
              )
          ],
        ));
  }
}
