import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/locale.dart';

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
          S.of(context).login,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
