import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wallet/constants/constants.dart';

class WelcomeImage extends StatelessWidget {
  const WelcomeImage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 250,
          height: 56,
          child: SvgPicture.asset(
            'assets/images/frame_word_logo.svg',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: defaultPadding * 2),
        const Row(
          children: [
            Spacer(),
            Expanded(
                flex: 8,
                child: Text(
                  "Privacy. Security. Convenience. Encrypted email that gives you full control of your personal data.",
                  textAlign: TextAlign.center,
                )),
            Spacer(),
          ],
        ),
        const SizedBox(height: defaultPadding * 2),
      ],
    );
  }
}
