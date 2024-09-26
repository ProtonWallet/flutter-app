import 'package:flutter/material.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';

class AccountInfoV2 extends StatelessWidget {
  final String displayName;
  final String userEmail;

  const AccountInfoV2({
    required this.displayName,
    required this.userEmail,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTileTheme(
      contentPadding: const EdgeInsets.only(
        left: defaultPadding,
        right: 10,
      ),
      child: ListTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              displayName,
              style: ProtonStyles.body1Medium(color: ProtonColors.white),
            ),
            Text(
              userEmail,
              style: ProtonStyles.body2Regular(color: ProtonColors.textHint),
            ),
          ],
        ),
      ),
    );
  }
}
