import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/exchange.caculator.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';

class TextFieldSendBTCV2 extends StatefulWidget {
  final FocusNode myFocusNode;
  final TextEditingController textController;
  final String labelText;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool autofocus;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter> inputFormatters;
  final Function validation;
  final Function? onFinish;
  final bool checkOfErrorOnFocusChange;
  final Color? backgroundColor;
  final BitcoinUnit bitcoinUnit;
  final ProtonExchangeRate exchangeRate;
  final bool bitcoinBase;

  const TextFieldSendBTCV2({
    required this.textController,
    required this.myFocusNode,
    required this.validation,
    required this.bitcoinUnit,
    required this.exchangeRate,
    required this.bitcoinBase,
    super.key,
    this.labelText = "",
    this.onFinish,
    this.backgroundColor,
    this.autofocus = false,
    this.inputFormatters = const [],
    this.keyboardType,
    this.textInputAction,
    this.checkOfErrorOnFocusChange = true,
    this.hintText,
  });

  @override
  State<StatefulWidget> createState() => TextFieldSendBTCV2State();
}

class TextFieldSendBTCV2State extends State<TextFieldSendBTCV2> {
  bool isError = false;
  String errorString = "";
  int estimatedSATS = 0;
  double estimatedFiatAmount = 0.0;

  Color getBorderColor(isFocus) {
    return isFocus ? ProtonColors.protonBlue : Colors.transparent;
  }

  @override
  void didUpdateWidget(covariant TextFieldSendBTCV2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exchangeRate.id != widget.exchangeRate.id ||
        oldWidget.bitcoinUnit.name != widget.bitcoinUnit.name ||
        oldWidget.bitcoinBase != widget.bitcoinBase) {
      setState(updateEstimateValue);
    }
  }

  @override
  void initState() {
    super.initState();
    updateEstimateValue();
    widget.textController.addListener(updateEstimateValue);
  }

  @override
  void dispose() {
    widget.textController.removeListener(updateEstimateValue);
    super.dispose();
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
              child: TextFormField(
                  scrollPadding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom + 60),
                  focusNode: widget.myFocusNode,
                  controller: widget.textController,
                  style: ProtonWalletStyles.textAmount(
                      color: ProtonColors.textNorm),
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
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    hintText: widget.hintText,
                    prefixIcon: Text(
                        widget.bitcoinBase
                            ? widget.bitcoinUnit == BitcoinUnit.sats
                                ? "SATS"
                                : "₿"
                            : CommonHelper.getFiatCurrencySign(
                                widget.exchangeRate.fiatCurrency),
                        style: ProtonWalletStyles.textAmount(
                            color: ProtonColors.textWeak,
                            fontVariation: 400.0)),
                    prefixIconConstraints: const BoxConstraints(),
                    hintStyle: ProtonWalletStyles.textAmount(
                        color: ProtonColors.textHint),
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    border: InputBorder.none,
                    errorStyle: const TextStyle(height: 0),
                    focusedErrorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    suffixIcon: widget.myFocusNode.hasFocus
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                widget.myFocusNode.unfocus();
                              });
                            },
                            icon: Icon(Icons.check_circle_outline_rounded,
                                size: 20, color: ProtonColors.textWeak))
                        : null,
                  )),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
              widget.bitcoinBase
                  ? "${CommonHelper.getFiatCurrencySymbol(widget.exchangeRate.fiatCurrency)} ${estimatedFiatAmount.toStringAsFixed(ExchangeCalculator.getDisplayDigit(widget.exchangeRate))}"
                  : ExchangeCalculator.getBitcoinUnitLabel(
                      widget.bitcoinUnit, estimatedSATS),
              textAlign: TextAlign.start,
              style: ProtonStyles.captionRegular(color: ProtonColors.textWeak)),
        ],
      ),
    );
  }

  void updateEstimateValue() {
    double amount = 0.0;
    if (widget.bitcoinBase) {
      try {
        amount = double.parse(widget.textController.text);
      } catch (e) {
        amount = 0.0;
      }
      final amountInSatoshi = widget.bitcoinUnit == BitcoinUnit.sats
          ? amount.toInt()
          : (amount * btc2satoshi).ceil();
      final double fiatAmount = ExchangeCalculator.getNotionalInFiatCurrency(
          widget.exchangeRate, amountInSatoshi);
      setState(() {
        estimatedFiatAmount = fiatAmount;
      });
    } else {
      try {
        amount = double.parse(widget.textController.text);
      } catch (e) {
        amount = 0.0;
      }
      final double btcAmount =
          ExchangeCalculator.getNotionalInBTC(widget.exchangeRate, amount);
      setState(() {
        estimatedSATS = (btcAmount * btc2satoshi).ceil();
      });
    }
  }
}
