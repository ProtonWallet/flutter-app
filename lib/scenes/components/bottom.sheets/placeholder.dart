import 'package:flutter/material.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/bottom.sheets/base.dart';
import 'package:wallet/scenes/components/button.v5.dart';

class CustomPlaceholder {
  static void show(BuildContext context) {
    HomeModalBottomSheet.show(context,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Assets.images.icon.noWalletFound
                .svg(fit: BoxFit.fill, width: 86, height: 87),
            const SizedBox(height: 10),
            Text(S.of(context).placeholder,
                style: ProtonStyles.body1Medium(color: ProtonColors.textNorm)),
            const SizedBox(height: 5),
            Text(S.of(context).placeholder,
                style: ProtonStyles.body2Regular(color: ProtonColors.textWeak)),
            const SizedBox(height: 20),
            ButtonV5(
              text: S.of(context).ok,
              width: MediaQuery.of(context).size.width,
              backgroundColor: ProtonColors.protonBlue,
              textStyle: ProtonStyles.body1Medium(color: ProtonColors.white),
              height: 48,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 10),
          ],
        ));
  }
}
