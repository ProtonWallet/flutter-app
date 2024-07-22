import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/theme/theme.font.dart';

class TextField2FA extends StatefulWidget {
  final double width;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final bool showEnabledBorder;
  final bool digitOnly;
  final void Function(String)? onChanged;
  final Color color;
  final TextInputAction? textInputAction;

  const TextField2FA({
    required this.width,
    super.key,
    this.controller,
    this.focusNode,
    this.hintText,
    this.color = Colors.transparent,
    this.showEnabledBorder = true,
    this.digitOnly = false,
    this.textInputAction,
    this.onChanged,
  });

  @override
  TextFieldTextState createState() => TextFieldTextState();
}

class TextFieldTextState extends State<TextField2FA> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: widget.width,
        child: Center(
          child: TextField(
            textAlignVertical: TextAlignVertical.center,
            textAlign: TextAlign.center,
            style: FontManager.twoFACode(Theme.of(context).colorScheme.primary),
            textInputAction: widget.textInputAction,
            onChanged: widget.onChanged,
            minLines: 1,
            maxLength: 1,
            controller: widget.controller,
            focusNode: widget.focusNode,
            keyboardType: TextInputType.number,
            inputFormatters: widget.digitOnly
                ? [FilteringTextInputFormatter.digitsOnly]
                : [],
            decoration: InputDecoration(
                hintText: widget.hintText,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: ProtonColors.textHint,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide:
                      BorderSide(color: ProtonColors.protonBlue, width: 2),
                ),
                counterStyle: const TextStyle(
                  height: double.minPositive,
                ),
                counterText: ""),
          ),
        ));
  }

  Widget buildTagWidget(String tag) {
    return Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Chip(
          backgroundColor: ProtonColors.backgroundProton,
          label: Text(tag,
              style: FontManager.body2Median(ProtonColors.interactionNorm)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: ProtonColors.backgroundProton),
          ),
          onDeleted: () {
            setState(() {
              widget.controller!.text = "";
            });
          },
        ));
  }
}
