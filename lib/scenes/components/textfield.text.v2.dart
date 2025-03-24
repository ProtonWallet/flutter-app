import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';

class TextFieldTextV2 extends StatefulWidget {
  final FocusNode myFocusNode;
  final TextEditingController textController;
  final String labelText;
  final TextInputType? keyboardType;
  final bool autofocus;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter> inputFormatters;
  final Function validation;
  final Function? onFinish;
  final bool checkOfErrorOnFocusChange;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool isPassword;
  final double? paddingSize;
  final bool showCounterText;
  final int? maxLines;
  final EdgeInsets? scrollPadding;
  final String? hintText;
  final int? maxLength;
  final bool? showFinishButton;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final double radius;
  final bool alwaysShowHint;
  final bool readOnly;
  final bool isLoading;

  const TextFieldTextV2({
    required this.textController,
    required this.myFocusNode,
    required this.validation,
    super.key,
    this.labelText = "",
    this.onFinish,
    this.backgroundColor,
    this.borderColor,
    this.autofocus = false,
    this.showCounterText = false,
    this.inputFormatters = const [],
    this.keyboardType,
    this.textInputAction,
    this.isPassword = false,
    this.paddingSize,
    this.maxLines = 1,
    this.checkOfErrorOnFocusChange = true,
    this.scrollPadding,
    this.hintText,
    this.maxLength,
    this.showFinishButton,
    this.prefixIcon,
    this.suffixIcon,
    this.radius = 18.0,
    this.alwaysShowHint = false,
    this.readOnly = false,
    this.isLoading = false,
  });

  @override
  State<StatefulWidget> createState() => TextFieldTextV2State();
}

class TextFieldTextV2State extends State<TextFieldTextV2> {
  bool isError = false;
  String errorString = "";
  bool isObscureText = true;

  Color getBorderColor(isFocus) {
    return isFocus
        ? ProtonColors.protonBlue
        : widget.borderColor ?? Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          FocusScope(
            child: Focus(
              onFocusChange: (focus) {
                setState(() {
                  getBorderColor(focus);
                  if (focus) {
                    // TODO(fix): remove this workaround, textfield will lose focus when ModalBottomSheet add padding for keyboard
                    Future.delayed(const Duration(milliseconds: 200), () {
                      if (!widget.myFocusNode.hasFocus) {
                        widget.myFocusNode.requestFocus();
                      }
                    });
                  }
                  if (!focus) {
                    if (widget.onFinish != null) {
                      widget.onFinish!();
                    }
                    if (widget.checkOfErrorOnFocusChange &&
                        widget
                            .validation(widget.textController.text)
                            .toString()
                            .isNotEmpty) {
                      isError = true;
                      errorString =
                          widget.validation(widget.textController.text);
                    } else {
                      isError = false;
                      errorString =
                          widget.validation(widget.textController.text);
                    }
                  }
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: widget.paddingSize ?? 12,
                ),
                decoration: BoxDecoration(
                    color: widget.backgroundColor ??
                        ProtonColors.backgroundSecondary,
                    borderRadius:
                        BorderRadius.all(Radius.circular(widget.radius)),
                    border: Border.all(
                      color: isError
                          ? ProtonColors.notificationError
                          : getBorderColor(widget.myFocusNode.hasFocus),
                    )),
                child: TextFormField(
                  enabled: !widget.isLoading,
                  readOnly: widget.readOnly,
                  scrollPadding: widget.scrollPadding ??
                      EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom + 60,
                      ),
                  obscureText: widget.isPassword ? isObscureText : false,
                  focusNode: widget.myFocusNode,
                  controller: widget.textController,
                  style: ProtonStyles.body1Medium(color: ProtonColors.textNorm),
                  autofocus: widget.autofocus,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  inputFormatters: widget.inputFormatters,
                  maxLines: widget.maxLines,
                  maxLength: widget.maxLength,
                  validator: (string) {
                    if (widget
                        .validation(widget.textController.text)
                        .toString()
                        .isNotEmpty) {
                      setState(() {
                        isError = true;
                        errorString =
                            widget.validation(widget.textController.text);
                      });
                      return "";
                    } else {
                      setState(() {
                        isError = false;
                        errorString =
                            widget.validation(widget.textController.text);
                      });
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    suffixIcon: widget.suffixIcon ??
                        (widget.isPassword
                            ? IconButton(
                                onPressed: () {
                                  setState(() {
                                    isObscureText = !isObscureText;
                                  });
                                },
                                icon: Icon(Icons.visibility_rounded,
                                    size: 20, color: ProtonColors.textWeak))
                            : widget.myFocusNode.hasFocus
                                ? widget.showFinishButton ?? true
                                    ? IconButton(
                                        onPressed: () {
                                          setState(() {
                                            widget.myFocusNode.unfocus();
                                          });
                                        },
                                        icon: Icon(
                                            Icons.check_circle_outline_rounded,
                                            size: 20,
                                            color: ProtonColors.textWeak))
                                    : null
                                : null),
                    counterText: widget.showCounterText ? null : "",
                    hintText: widget.hintText,
                    hintStyle:
                        ProtonStyles.body2Regular(color: ProtonColors.textHint),
                    labelText: widget.labelText,
                    labelStyle: isError
                        ? ProtonStyles.body2Regular(
                            color: ProtonColors.notificationError,
                            fontSize: 15.0)
                        : ProtonStyles.body2Regular(
                            color: ProtonColors.textWeak, fontSize: 15.0),
                    prefixIcon: widget.prefixIcon,
                    contentPadding: EdgeInsets.only(
                        left: 10,
                        right: 10,
                        top: 4,
                        bottom: widget.paddingSize ?? 16),
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    border: InputBorder.none,
                    errorStyle: const TextStyle(height: 0),
                    focusedErrorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
          Visibility(
              visible: isError ? true : false,
              child: Container(
                  padding: const EdgeInsets.only(left: 15.0, top: 2.0),
                  child: Text(
                    errorString,
                    style: ProtonStyles.body2Regular(
                        color: ProtonColors.notificationError),
                  ))),
        ],
      ),
    );
  }
}
