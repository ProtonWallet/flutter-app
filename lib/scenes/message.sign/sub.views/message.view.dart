import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/extension/build.context.extension.dart';
import 'package:wallet/rust/common/signing_type.dart';
import 'package:wallet/scenes/components/button.v6.dart';
import 'package:wallet/scenes/components/dropdown.button.v3.dart';
import 'package:wallet/scenes/components/textfield.text.v2.dart';

class MessageView extends StatefulWidget {
  const MessageView({
    required this.onPressed,
    required this.btcAddress,
    required this.controller,
    required this.isLoading,
    super.key,
  });

  final Future<void> Function(SigningType) onPressed;
  final TextEditingController controller;
  final String btcAddress;
  final bool isLoading;

  @override
  State<MessageView> createState() => MessageViewState();
}

class MessageViewState extends State<MessageView> {
  bool _showAdvancedOptions = false;
  SigningType _selectedSigningType = SigningType.electrum;

  Future<void> _handlePressed() async {
    await widget.onPressed(_selectedSigningType);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.width,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(
          context.local.message_sign_header,
          style: ProtonStyles.headline(color: ProtonColors.textNorm),
        ),
        SizedBoxes.box8,

        ///
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          child: Text(
            widget.btcAddress,
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
          isLoading: widget.isLoading,
          labelText: context.local.message,
          hintText: context.local.message_hint,
          backgroundColor: ProtonColors.backgroundSecondary,
          textController: widget.controller,
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

        // Advanced Options
        GestureDetector(
          onTap: () {
            setState(() {
              _showAdvancedOptions = !_showAdvancedOptions;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.local.advanced_options,
                  style:
                      ProtonStyles.body2Regular(color: ProtonColors.textWeak),
                ),
                Icon(
                  _showAdvancedOptions ? Icons.expand_less : Icons.expand_more,
                  color: ProtonColors.textWeak,
                ),
              ],
            ),
          ),
        ),
        if (_showAdvancedOptions) ...[
          SizedBoxes.box24,
          Text(
            context.local.signing_method,
            style: ProtonStyles.subheadline(color: ProtonColors.textNorm),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBoxes.box16,
          Text(
            context.local.signing_method_desc,
            style: ProtonStyles.body1Regular(color: ProtonColors.textWeak),
            maxLines: 20,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBoxes.box16,
          DropdownButtonV3<SigningType>(
            width: context.width,
            items: SigningType.values,
            itemsText: SigningType.values.map((e) => e.name).toList(),
            selected: _selectedSigningType,
            onChanged: (value) {
              setState(() {
                _selectedSigningType = value;
              });
            },
            labelText: context.local.signing_type,
          ),
        ],
        SizedBoxes.box24,

        ///
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: ButtonV6(
            onPressed: _handlePressed,
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
