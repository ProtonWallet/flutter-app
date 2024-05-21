import 'package:flutter/material.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';

class WelcomeImage extends StatelessWidget {
  const WelcomeImage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 46),
        Assets.images.welcome.walletWelcomeHeadPng.image(),
        const SizedBox(height: defaultPadding),
        SizedBox(
          width: 220,
          height: 45,
          child: Assets.images.walletCreation.protonWalletLogoLight
              .svg(fit: BoxFit.fitHeight),
        ),
        const SizedBox(height: defaultPadding),
        const SizedBox(
          width: 280,
          child: Text(
              "Please Mister Postman, look and see! Is there's a letter in your bag for me?"),
        ),
        const SizedBox(height: defaultPadding * 2),
      ],
    );
  }
}
