import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/extension/asset.gen.image.extension.dart';
import 'package:wallet/helper/extension/build.context.extension.dart';
import 'package:wallet/helper/extension/svg.gen.image.extension.dart';
import 'package:wallet/scenes/core/responsive.dart';

class WelcomeImage extends StatelessWidget {
  const WelcomeImage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: Responsive.isDesktop(context)
              ? null
              : BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      ProtonColors.backgroundWelcomePage,
                      ProtonColors.backgroundSecondary,
                    ],
                  ),
                ),
          height: context.multHeight(0.4),
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(child: (SizedBox())),
                  Center(
                    child: Assets.images.welcome.walletWelcomeHeadPng
                        .applyThemeIfNeeded(context)
                        .image(
                          fit: BoxFit.fitWidth,
                          width: min(context.width, 610),
                        ),
                  ),
                  SizedBoxes.box2,
                ],
              ),
              // Gradient overlay
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ProtonColors.backgroundSecondary.withOpacity(0.0),
                        ProtonColors.backgroundSecondary.withOpacity(1.0),
                        ProtonColors.backgroundSecondary.withOpacity(0.0),
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
          child: Assets.images.walletCreation.protonWalletLogoLight
              .applyThemeIfNeeded(context)
              .svg(
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
                style: ProtonStyles.body1Regular(color: ProtonColors.textWeak),
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
