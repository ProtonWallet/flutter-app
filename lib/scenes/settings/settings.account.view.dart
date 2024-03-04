import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/locale.dart';
import 'package:provider/provider.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/user.session.dart';

class AccountInfo extends StatelessWidget {
  const AccountInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(top: 80, bottom: 50),
      child: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor,
        radius: 50,
        child: Text(
          Provider.of<UserSessionProvider>(context)
              .userSession
              .userDisplayName
              .split(' ')
              .map((str) => str.substring(0, 1))
              .join(''),
          style: const TextStyle(fontSize: 40, color: ProtonColors.white),
        ),
      ),
    );
  }
}
