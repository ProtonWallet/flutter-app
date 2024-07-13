import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/theme/theme.font.dart';

class TextField2FA extends StatefulWidget {
  final double width;
  final double? height;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final bool multiLine;
  final bool showSuffixIcon;
  final bool showEnabledBorder;
  final bool digitOnly;
  final VoidCallback? suffixIconOnPressed;
  final void Function(String)? onChanged;
  final Icon suffixIcon;
  final Color color;
  final bool showMailTag;
  final bool centerHorizontal;
  final int? maxLength;
  final TextInputAction? textInputAction;

  const TextField2FA({
    required this.width,
    super.key,
    this.height,
    this.controller,
    this.focusNode,
    this.hintText,
    this.multiLine = false,
    this.suffixIconOnPressed,
    this.showSuffixIcon = true,
    this.suffixIcon = const Icon(Icons.text_fields),
    this.color = Colors.transparent,
    this.showEnabledBorder = true,
    this.digitOnly = false,
    this.showMailTag = false,
    this.centerHorizontal = false,
    this.maxLength,
    this.textInputAction,
    this.onChanged,
  });

  @override
  TextFieldTextState createState() => TextFieldTextState();
}

class TextFieldTextState extends State<TextField2FA> {
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
          child: (widget.controller!.text.endsWith("@proton.me") &&
                  widget.showMailTag)
              ? Container(
                  alignment: Alignment.centerLeft,
                  child: buildTagWidget(widget.controller!.text))
              : TextField(
                  textAlignVertical: TextAlignVertical.center,
                  textAlign: widget.centerHorizontal
                      ? TextAlign.center
                      : TextAlign.left,
                  style: FontManager.body2Regular(
                      Theme.of(context).colorScheme.primary),
                  textInputAction: widget.textInputAction,
                  onChanged: widget.onChanged,
                  maxLines: widget.multiLine ? null : 1,
                  minLines: widget.multiLine ? 5 : 1,
                  maxLength: widget.maxLength,
                  controller: widget.controller,
                  focusNode: widget.focusNode,
                  keyboardType: widget.digitOnly
                      ? TextInputType.number
                      : widget.multiLine
                          ? TextInputType.multiline
                          : TextInputType.text,
                  inputFormatters: widget.digitOnly
                      ? [FilteringTextInputFormatter.digitsOnly]
                      : [],
                  decoration: InputDecoration(
                      hintText: widget.hintText,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                            color: widget.showEnabledBorder
                                ? Theme.of(context).colorScheme.primary
                                : widget.color),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                            color: ProtonColors.interactionNorm, width: 2),
                      ),
                      suffixIcon: widget.showSuffixIcon
                          ? IconButton(
                              icon: widget.suffixIcon,
                              onPressed: widget.suffixIconOnPressed ?? () {},
                            )
                          : null,
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
