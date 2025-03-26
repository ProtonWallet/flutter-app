import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/extension/build.context.extension.dart';
import 'package:wallet/scenes/components/button.v5.dart';
import 'package:wallet/scenes/components/textfield.text.v2.dart';

class SignatureView extends StatelessWidget {
  const SignatureView({
    required this.onPressed,
    required this.controller,
    super.key,
  });

  final VoidCallback onPressed;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.width,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(
          context.local.message_signed,
          style: ProtonStyles.headline(color: ProtonColors.textNorm),
        ),

        Padding(
          padding: const EdgeInsets.only(
            top: 8.0,
            bottom: 24.0,
            left: 14.0,
            right: 14.0,
          ),
          child: Text(
            textAlign: TextAlign.center,
            context.local.message_signed_desc,
            style: ProtonStyles.body2Medium(color: ProtonColors.textWeak),
          ),
        ),

        ///
        SizedBoxes.box8,
        TextFieldTextV2(
          isLoading: true,
          labelText: context.local.signature,
          backgroundColor: ProtonColors.backgroundNorm,
          textController: controller,
          myFocusNode: FocusNode(),
          maxLines: null,
          showCounterText: true,
          validation: (String value) {
            return "";
          },
          borderColor: ProtonColors.appBarDividerColor,
          radius: 16,
        ),
        SizedBoxes.box24,

        ///
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: ButtonV5(
              onPressed: onPressed,
              text: context.local.copy_signature,
              width: context.width,
              backgroundColor: ProtonColors.protonBlue,
              textStyle: ProtonStyles.body1Medium(
                color: ProtonColors.backgroundSecondary,
              ),
              height: 55),
        ),
      ]),
    );
  }
}
