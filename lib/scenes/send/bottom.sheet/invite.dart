import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wallet/scenes/components/bottom.sheets/base.dart';
import 'package:wallet/scenes/components/button.v5.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/close.button.v1.dart';
import 'package:wallet/theme/theme.font.dart';

class InviteSheet {
  static void show(BuildContext context, String email, VoidCallback callback) {
    HomeModalBottomSheet.show(context, child:
        StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
              alignment: Alignment.centerRight,
              child: CloseButtonV1(onPressed: () {
                Navigator.of(context).pop();
              })),
          SvgPicture.asset("assets/images/icon/no_wallet_found.svg",
              fit: BoxFit.fill, width: 86, height: 87),
          const SizedBox(height: 10),
          Text(
            S.of(context).send_invite_to(email),
            style: FontManager.titleHeadline(ProtonColors.textNorm),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              S.of(context).no_wallet_found_desc,
              style: FontManager.body2Regular(ProtonColors.textWeak),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          ButtonV5(
            text: S.of(context).send_invite,
            width: MediaQuery.of(context).size.width,
            backgroundColor: ProtonColors.protonBlue,
            textStyle: FontManager.body1Median(ProtonColors.white),
            height: 48,
            onPressed: () {
              callback.call();
              Navigator.of(context).pop();
              InviteSheetSuccess.show(context, email);
            },
          ),
          const SizedBox(height: 10),
        ],
      );
    }));
  }
}


class InviteSheetSuccess {
  static void show(BuildContext context, String email) {
    HomeModalBottomSheet.show(context, child:
    StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
              alignment: Alignment.centerRight,
              child: CloseButtonV1(onPressed: () {
                Navigator.of(context).pop();
              })),
          SvgPicture.asset("assets/images/icon/invite_success.svg",
              fit: BoxFit.fill, width: 86, height: 87),
          const SizedBox(height: 10),
          Text(
            S.of(context).send_invite_to_success(email),
            style: FontManager.titleHeadline(ProtonColors.textNorm),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              S.of(context).send_invite_success_desc,
              style: FontManager.body2Regular(ProtonColors.textWeak),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          ButtonV5(
            text: S.of(context).close,
            width: MediaQuery.of(context).size.width,
            backgroundColor: ProtonColors.protonBlue,
            textStyle: FontManager.body1Median(ProtonColors.white),
            height: 48,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(height: 10),
        ],
      );
    }));
  }
}