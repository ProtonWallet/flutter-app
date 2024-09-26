import 'package:flutter/material.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/helper/extension/build.context.extension.dart';
import 'package:wallet/theme/theme.font.dart';

class WelcomeImage extends StatelessWidget {
  const WelcomeImage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: context.multHeight(0.4),
          child: Stack(
            children: [
              Column(
                children: [
                  const Expanded(child: SizedBox()),
                  Center(
                    child: Assets.images.welcome.walletWelcomeHeadPng.image(
                      fit: BoxFit.fill,
                    ),
                  ),
                  SizedBoxes.box2,
                ],
              ),

              /// Gradient overlay
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 110,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFFFFFF).withOpacity(0.0),
                        const Color(0xFFFFFFFF).withOpacity(1.0),
                        const Color(0xFFFFFFFF).withOpacity(0.0),
                      ],
                      stops: const [0.0, 0.0, 1.0],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBoxes.box30,
        SizedBox(
          width: 264,
          height: 54,
          child: Assets.images.walletCreation.protonWalletLogoLight.svg(
            fit: BoxFit.fitHeight,
          ),
        ),
        SizedBoxes.box24,
        SizedBox(
          width: context.maxWidth(450),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: Text(
                context.local.welcome_desc,
                style: FontManager.body1Regular(ProtonColors.textWeak),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        const SizedBox(height: defaultPadding * 2),
      ],
    );
  }
}
