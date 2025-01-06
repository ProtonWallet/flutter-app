import 'package:flutter/cupertino.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/extension/build.context.extension.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/button.v5.dart';

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
        ButtonV5(
            onPressed: signupPressed,
            text: S.of(context).create_new_proton_account,
            width: MediaQuery.of(context).size.width,
            backgroundColor: ProtonColors.protonBlue,
            borderColor: ProtonColors.clear,
            textStyle: ProtonStyles.body1Medium(color: ProtonColors.textInverted),
            height: 48,
            maximumSize: const Size(560, 48)),
        const SizedBox(height: 4),
        CupertinoButton(
          onPressed: signinPressed,
          child: Text(
            context.local.sign_in,
            style: ProtonStyles.body1Regular(
              color: ProtonColors.protonBlue,
            ),
          ),
        ),
      ],
    );
  }
}
