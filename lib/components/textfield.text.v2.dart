import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/theme/theme.font.dart';

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
  final bool isPassword;
  final double? paddingSize;

  const TextFieldTextV2(
      {super.key,
      this.labelText = "",
      this.onFinish,
      this.backgroundColor,
      this.autofocus = false,
      required this.textController,
      required this.myFocusNode,
      this.inputFormatters = const [],
      this.keyboardType,
      this.textInputAction,
      required this.validation,
      this.isPassword = false,
      this.paddingSize,
      this.checkOfErrorOnFocusChange = true});

  @override
  State<StatefulWidget> createState() => TextFieldTextV2State();
}

class TextFieldTextV2State extends State<TextFieldTextV2> {
  bool isError = false;
  String errorString = "";
  bool isObscureText = true;

  getBorderColor(isFocus) {
    return isFocus ? ProtonColors.interactionNorm : Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          FocusScope(
            child: Focus(
              onFocusChange: (focus) {
                setState(() {
                  getBorderColor(focus);
                  if (focus) {
                    // TODO:: remove this workaround, textfield will lose focus when ModalBottomSheet add padding for keyboard
                    Future.delayed(const Duration(milliseconds: 200), () {
                      if (widget.myFocusNode.hasFocus == false) {
                        widget.myFocusNode.requestFocus();
                      }
                    });
                  }
                  if (focus == false) {
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
                    horizontal: 4, vertical: widget.paddingSize ?? 12),
                decoration: BoxDecoration(
                    color: widget.backgroundColor ?? ProtonColors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(18.0)),
                    border: Border.all(
                      width: 1,
                      style: BorderStyle.solid,
                      color: isError
                          ? ProtonColors.signalError
                          : getBorderColor(widget.myFocusNode.hasFocus),
                    )),
                child: TextFormField(
                  obscureText: widget.isPassword ? isObscureText : false,
                  focusNode: widget.myFocusNode,
                  controller: widget.textController,
                  style: FontManager.body1Median(ProtonColors.textNorm),
                  autofocus: widget.autofocus,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  inputFormatters: widget.inputFormatters,
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
                    suffixIcon: widget.isPassword
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                isObscureText = !isObscureText;
                              });
                            },
                            icon: Icon(Icons.visibility_rounded,
                                size: 20, color: ProtonColors.textWeak))
                        : null,
                    labelText: widget.labelText,
                    labelStyle: isError
                        ? FontManager.textFieldLabelStyle(
                            ProtonColors.signalError)
                        : FontManager.textFieldLabelStyle(
                            ProtonColors.textWeak),
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
                    style: FontManager.body2Regular(ProtonColors.signalError),
                  ))),
        ],
      ),
    );
  }
}