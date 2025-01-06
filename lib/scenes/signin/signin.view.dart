import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/extension/build.context.extension.dart';
import 'package:wallet/helper/local_toast.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/signin/signin.viewmodel.dart';

class SigninView extends ViewBase<SigninViewModel> {
  const SigninView(SigninViewModel viewModel)
      : super(viewModel, const Key("SigninView"));

  @override
  Widget build(BuildContext context) {
    return buildWelcome(context);
  }

  Widget buildWelcome(BuildContext context) {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();

    /// This is the workaround to show the error message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (viewModel.errorMessage.isNotEmpty) {
        LocalToast.showErrorToast(context, viewModel.errorMessage);
        viewModel.errorMessage = "";
      }
    });

    return AlertDialog(
      title: SignInHeader(),
      backgroundColor: ProtonColors.backgroundNorm,
      content: SigninContentForm(
        usernameController: usernameController,
        passwordController: passwordController,
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Closes the dialog
            Navigator.of(context).pop();
          },
          child: Text(
            // cancel
            context.local.cancel,
            style: ProtonStyles.body2Regular(
              color: Colors.grey,
            ),
          ),
        ),
        TextButton(
          onPressed: () async {
            // Logic for logging in goes here
            EasyLoading.show(maskType: EasyLoadingMaskType.black);
            await viewModel.signIn(
              usernameController.text,
              passwordController.text,
            );
            EasyLoading.dismiss();
          },
          child: Text(
            // login
            context.local.login,
            style: ProtonStyles.body2Regular(),
          ),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

class SigninContentForm extends StatelessWidget {
  const SigninContentForm({
    required this.usernameController,
    required this.passwordController,
    super.key,
  });

  final TextEditingController usernameController;
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 300),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
        children: [
          Text(
            S.of(context).sign_in_username_or_email,
            style: ProtonStyles.body2Medium(color: ProtonColors.textWeak),
            textAlign: TextAlign.left,
          ),
          SizedBoxes.box8,
          CupertinoTextField.borderless(
            keyboardType: TextInputType.emailAddress,
            controller: usernameController,
            style: ProtonStyles.body1Regular(),
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(14.0),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 16.0,
            ),
          ),
          SizedBoxes.box16,
          Text(
            "Password",
            style: ProtonStyles.body2Medium(color: ProtonColors.textWeak),
            textAlign: TextAlign.left,
          ),
          SizedBoxes.box8,
          CupertinoTextField.borderless(
            keyboardType: TextInputType.visiblePassword,
            obscureText: true,
            controller: passwordController,
            style: ProtonStyles.body1Regular(),
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(14.0),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 16.0,
            ),
          ),
        ],
      ),
    );
  }
}

class SignInHeader extends StatelessWidget {
  const SignInHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 340),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        SizedBoxes.box24,
        Assets.images.logos.protonPLogo.svg(),
        SizedBoxes.box20,
        Text(
          S.of(context).sign_in_to_proton_title,
          style: ProtonStyles.hero(),
        ),
        SizedBoxes.box8,
        Text(
          S.of(context).sign_in_to_proton_subtitle,
          style: ProtonStyles.body1Regular(),
        )
      ]),
    );
  }
}
