import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/extension/build.context.extension.dart';
import 'package:wallet/provider/theme.provider.dart';

class WelcomBackground extends StatelessWidget {
  final Widget child;
  final AlignmentGeometry alignment;

  const WelcomBackground({
    required this.child,
    super.key,
    this.alignment = Alignment.topCenter,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProtonColors.backgroundSecondary,
      resizeToAvoidBottomInset: false,
      body: SizedBox(
        width: double.infinity,
        height: context.height,
        child: Stack(
          alignment: alignment,
          children: <Widget>[
            if (!Provider.of<ThemeProvider>(context, listen: false)
                .isDarkMode())
              Positioned(
                top: 0,
                left: 0,
                child: SizedBox(
                  width: context.width,
                  height: context.height / 2, // 350,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x99FCC49C), // RGBA(252, 196, 156, 0.6) as ARGB
                          Color(0x00FFFFFF) // Fully transparent white
                        ],
                        stops: [
                          -0.1263,
                          // Adjusted for Flutter, might need further calibration
                          0.8896
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: 50,
              child: SizedBox(
                width: context.width,
                height: 20,
                child: Assets.images.welcome.protonPrivacyByDefaultFooter
                    .svg(fit: BoxFit.fitHeight),
              ),
            ),
            SafeArea(child: child),
          ],
        ),
      ),
    );
  }
}
