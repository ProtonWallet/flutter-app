import 'package:flutter/cupertino.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/theme/theme.font.dart';

class LoginAndSignupBtn extends StatelessWidget {
  final VoidCallback? signinPressed;
  final VoidCallback? signupPressed;

  const LoginAndSignupBtn({
    super.key,
    this.signinPressed,
    this.signupPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
            margin:
                const EdgeInsets.symmetric(horizontal: defaultButtonPadding),
            child: ButtonV5(
                onPressed: signupPressed,
                text: S.of(context).create_new_wallet,
                width: MediaQuery.of(context).size.width,
                backgroundColor: ProtonColors.interactionNorm,
                borderColor: ProtonColors.clear,
                textStyle: FontManager.body1Median(ProtonColors.white),
                height: 48,
                maximumSize: const Size(300, 48))),
        const SizedBox(height: 4),
        CupertinoButton(
          onPressed: signinPressed,
          child: Text('Sign In',
              style: FontManager.body1Regular(ProtonColors.interactionNorm)),
        ),
      ],
    );
  }
}
