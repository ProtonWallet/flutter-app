import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/user.session.dart';
import 'package:wallet/provider/theme.provider.dart';
import 'package:wallet/theme/theme.font.dart';

class AccountInfo extends StatelessWidget {
  const AccountInfo({super.key});

  @override
  Widget build(BuildContext context) {
    Provider.of<ThemeProvider>(context);
    return Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
      return Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: Column(children: [
            CircleAvatar(
              backgroundColor: ProtonColors.primaryColor,
              radius: 36,
              child: Text(
                "He",
                style: TextStyle(
                    fontSize: 30, color: ProtonColors.backgroundSecondary),
              ),
            ),
            Text(
                Provider.of<UserSessionProvider>(context)
                    .userSession
                    .userDisplayName,
                style: FontManager.body2Median(ProtonColors.textNorm)),
            Text(Provider.of<UserSessionProvider>(context).userSession.userMail,
                style: FontManager.captionRegular(ProtonColors.textNorm)),
          ]));
    });
  }
}
