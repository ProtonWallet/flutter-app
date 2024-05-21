import 'package:flutter/material.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/theme/theme.font.dart';

class AccountInfoV2 extends StatelessWidget {
  final String displayName;
  final String userEmail;
  const AccountInfoV2(
      {super.key, required this.displayName, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return ListTileTheme(
        contentPadding: const EdgeInsets.only(left: defaultPadding, right: 10),
        child: ExpansionTile(
          title:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(displayName,
                style: FontManager.body1Median(ProtonColors.white)),
            Text(userEmail,
                style: FontManager.body2Regular(ProtonColors.textHint)),
          ]),
          iconColor: ProtonColors.textHint,
          collapsedIconColor: ProtonColors.textHint,
        ));
  }
}
