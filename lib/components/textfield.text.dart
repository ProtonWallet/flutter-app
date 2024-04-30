import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/theme/theme.font.dart';

class TextFieldText extends StatefulWidget {
  final double width;
  final double? height;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final String? labelText;
  final bool multiLine;
  final bool showSuffixIcon;
  final bool showEnabledBorder;
  final bool digitOnly;
  final VoidCallback? suffixIconOnPressed;
  final Icon suffixIcon;
  final Color color;
  final bool showMailTag;
  final double borderRadius;
  final Widget? prefixIcon;

  const TextFieldText(
      {super.key,
      required this.width,
      this.height,
      this.controller,
      this.focusNode,
      this.hintText,
      this.labelText,
      this.prefixIcon,
      this.borderRadius = 8.0,
      this.multiLine = false,
      this.suffixIconOnPressed,
      this.showSuffixIcon = true,
      this.suffixIcon = const Icon(Icons.text_fields),
      this.color = Colors.transparent,
      this.showEnabledBorder = true,
      this.digitOnly = false,
      this.showMailTag = false});

  @override
  TextFieldTextState createState() => TextFieldTextState();
}

class TextFieldTextState extends State<TextFieldText> {
  final _decimalFormatter =
      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'));

  @override
  Widget build(BuildContext context) {
    return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: Center(
          child: (widget.controller!.text.endsWith("@proton.me") &&
                  widget.showMailTag)
              ? Container(
                  alignment: Alignment.centerLeft,
                  child: buildTagWidget(widget.controller!.text))
              : TextField(
                  textAlignVertical: TextAlignVertical.center,
                  style: FontManager.captionMedian(ProtonColors.textNorm),
                  maxLines: widget.multiLine ? null : 1,
                  minLines: widget.multiLine ? 5 : 1,
                  controller: widget.controller,
                  focusNode: widget.focusNode,
                  keyboardType: widget.digitOnly
                      ? const TextInputType.numberWithOptions(decimal: true)
                      : widget.multiLine
                          ? TextInputType.multiline
                          : TextInputType.text,
                  inputFormatters: widget.digitOnly ? [_decimalFormatter] : [],
                  decoration: InputDecoration(
                    prefixIcon: widget.prefixIcon,
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    hintText: widget.hintText,
                    labelText: widget.labelText,
                    labelStyle:
                        FontManager.textFieldLabelStyle(ProtonColors.textWeak),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      borderSide: BorderSide(
                          color: widget.showEnabledBorder
                              ? Colors.transparent
                              : widget.color,
                          width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      borderSide: BorderSide(
                          color: ProtonColors.interactionNorm, width: 1),
                    ),
                    suffixIcon: widget.showSuffixIcon
                        ? IconButton(
                            icon: widget.suffixIcon,
                            onPressed: widget.suffixIconOnPressed ?? () {},
                          )
                        : null,
                  ),
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
            borderRadius: BorderRadius.circular(widget.borderRadius),
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
