import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/theme/theme.font.dart';

class TextFieldBigText extends StatefulWidget {
  final double width;
  final double? height;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final bool digitOnly;
  final Color color;

  const TextFieldBigText({
    super.key,
    required this.width,
    this.height,
    this.controller,
    this.focusNode,
    this.hintText,
    this.color = Colors.transparent,
    this.digitOnly = false,
  });

  @override
  TextFieldTextState createState() => TextFieldTextState();
}

class TextFieldTextState extends State<TextFieldBigText> {
  final _decimalFormatter = FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'));
  @override
  Widget build(BuildContext context) {
    return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Center(
          child: TextField(
            textAlign: TextAlign.center,
                  textAlignVertical: TextAlignVertical.center,
                  style: FontManager.sendAmount(
                      Theme.of(context).colorScheme.primary),
                  maxLines: 1,
                  minLines: 1,
                  controller: widget.controller,
                  focusNode: widget.focusNode,
                  keyboardType: widget.digitOnly
                      ? const TextInputType.numberWithOptions(decimal: true)
                      : TextInputType.text,
                  inputFormatters: widget.digitOnly
                      ? [_decimalFormatter]
                      : [],
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                          color: widget.color,
                          width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                          color: ProtonColors.interactionNorm, width: 2),
                    ),
                    suffixIcon: null,
                  ),
                ),
        ));
  }
}
