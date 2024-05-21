import 'package:flutter/material.dart';
import 'package:wallet/constants/assets.gen.dart';

class WelcomBackground extends StatelessWidget {
  final Widget child;
  final AlignmentGeometry alignment;
  const WelcomBackground({
    super.key,
    required this.child,
    this.alignment = Alignment.topCenter,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SizedBox(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          alignment: alignment,
          children: <Widget>[
            Positioned(
              top: 0,
              left: 0,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 2, // 350,
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
                        -0.1263, // Adjusted for Flutter, might need further calibration
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
                width: MediaQuery.of(context).size.width,
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
