import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/user.settings.provider.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/theme/theme.font.dart';

class TextFieldSendBTCV2 extends StatefulWidget {
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
  final FiatCurrency currency;
  final int currencyExchangeRate;
  final double btcBalance;
  final UserSettingProvider userSettingProvider;

  const TextFieldSendBTCV2(
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
      required this.currency,
      required this.currencyExchangeRate,
      required this.btcBalance,
      required this.userSettingProvider,
      this.checkOfErrorOnFocusChange = true});

  @override
  State<StatefulWidget> createState() => TextFieldSendBTCV2State();
}

class TextFieldSendBTCV2State extends State<TextFieldSendBTCV2> {
  bool isError = false;
  String errorString = "";

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
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
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
                    labelText: widget.labelText,
                    labelStyle: isError
                        ? FontManager.textFieldLabelStyle(
                            ProtonColors.signalError)
                        : FontManager.textFieldLabelStyle(
                            ProtonColors.textWeak),
                    contentPadding: const EdgeInsets.only(
                        left: 10, right: 10, top: 4, bottom: 16),
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    border: InputBorder.none,
                    errorStyle: const TextStyle(height: 0),
                    focusedErrorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                            onTap: () {
                              widget.textController.text = widget
                                  .userSettingProvider
                                  .getNotionalInFiatCurrency(
                                      (widget.btcBalance * 100000000).toInt())
                                  .toStringAsFixed(3);
                            },
                            child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 2),
                                child: Text("MAX",
                                    style: FontManager.body2Median(
                                        ProtonColors.alertWaning)))),
                        const SizedBox(
                          width: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                  widget.userSettingProvider
                      .getBitcoinUnitLabel(getEstimateSats()),
                  textAlign: TextAlign.start,
                  style: FontManager.captionRegular(ProtonColors.textWeak))),
        ],
      ),
    );
  }

  int getEstimateSats() {
    double amount = 0.0;
    try {
      amount = double.parse(widget.textController.text);
    } catch (e) {
      amount = 0.0;
    }
    double btcAmount = widget.userSettingProvider.getNotionalInBTC(amount);
    return (btcAmount * 100000000).ceil();
  }
}
