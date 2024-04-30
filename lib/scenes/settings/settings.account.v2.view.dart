import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/user.session.dart';
import 'package:wallet/provider/theme.provider.dart';
import 'package:wallet/theme/theme.font.dart';

class AccountInfoV2 extends StatelessWidget {
  const AccountInfoV2({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTileTheme(
        contentPadding: const EdgeInsets.only(left: defaultPadding, right: 10),
        child: ExpansionTile(
          title:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
                Provider.of<UserSessionProvider>(context)
                    .userSession
                    .userDisplayName,
                style: FontManager.body1Median(ProtonColors.white)),
            Text(Provider.of<UserSessionProvider>(context).userSession.userMail,
                style: FontManager.body2Regular(ProtonColors.textHint)),
          ]),
          iconColor: ProtonColors.textHint,
          collapsedIconColor: ProtonColors.textHint,
        ));
  }
}
