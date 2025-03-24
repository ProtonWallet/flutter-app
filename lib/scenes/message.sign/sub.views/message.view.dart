import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/extension/build.context.extension.dart';
import 'package:wallet/scenes/components/button.v6.dart';
import 'package:wallet/scenes/components/textfield.text.v2.dart';

class MessageView extends StatelessWidget {
  const MessageView({
    required this.onPressed,
    required this.btcAddress,
    required this.controller,
    required this.isLoading,
    super.key,
  });

  final FutureCallback onPressed;
  final TextEditingController controller;
  final String btcAddress;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.width,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(
          context.local.authenticate,
          style: ProtonStyles.headline(color: ProtonColors.textNorm),
        ),
        SizedBoxes.box8,

        ///
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          child: Text(
            '"$btcAddress"',
            style: ProtonStyles.body1Regular(color: ProtonColors.textNorm),
            maxLines: 3,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBoxes.box24,

        ///
        SizedBoxes.box8,
        TextFieldTextV2(
          isLoading: isLoading,
          labelText: context.local.message,
          hintText: context.local.message_hint,
          backgroundColor: ProtonColors.backgroundSecondary,
          textController: controller,
          myFocusNode: FocusNode(),
          maxLines: null,
          showCounterText: true,
          maxLength: maxMemoTextCharSize,
          inputFormatters: [
            LengthLimitingTextInputFormatter(maxMemoTextCharSize)
          ],
          validation: (String value) {
            return "";
          },
          borderColor: ProtonColors.interActionWeakPressed,
          radius: 16,
        ),
        SizedBoxes.box24,

        ///
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: ButtonV6(
            onPressed: onPressed,
            text: context.local.generate_signature,
            width: context.width,
            backgroundColor: ProtonColors.protonBlue,
            textStyle: ProtonStyles.body1Medium(
              color: ProtonColors.backgroundSecondary,
            ),
            height: 55,
          ),
        ),
      ]),
    );
  }
}
