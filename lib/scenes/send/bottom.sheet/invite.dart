import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wallet/components/bottom.sheets/base.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/send/send.viewmodel.dart';
import 'package:wallet/theme/theme.font.dart';

class InviteSheet {
  static void show(BuildContext context, SendViewModel viewModel, String email) {
    HomeModalBottomSheet.show(context, child:
        StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset("assets/images/icon/no_wallet_found.svg",
              fit: BoxFit.fill, width: 86, height: 87),
          const SizedBox(height: 10),
          Text(S.of(context).no_wallet_found,
              style: FontManager.body1Median(ProtonColors.textNorm)),
          const SizedBox(height: 5),
          Text(S.of(context).no_wallet_found_desc,
              style: FontManager.body2Regular(ProtonColors.textWeak)),
          const SizedBox(height: 20),
          ButtonV5(
            text: S.of(context).send_invite,
            width: MediaQuery.of(context).size.width,
            backgroundColor: ProtonColors.protonBlue,
            textStyle: FontManager.body1Median(ProtonColors.white),
            height: 48,
            onPressed: () {
              viewModel.sendInvite(email);
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(height: 10),
        ],
      );
    }));
  }
}
