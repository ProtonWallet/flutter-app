import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/theme/theme.font.dart';
import 'package:wallet/l10n/generated/locale.dart';

class TextFieldSendBTC extends StatefulWidget {
  final double width;
  final double? height;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final FiatCurrency currency;
  final int currencyExchangeRate;
  final Color color;
  final double btcBalance;
  final ValueNotifier isBitcoinBaseValueNotifier;

  const TextFieldSendBTC({
    super.key,
    required this.width,
    this.height,
    this.focusNode,
    required this.controller,
    required this.isBitcoinBaseValueNotifier,
    required this.btcBalance,
    required this.currency,
    required this.currencyExchangeRate,
    this.color = Colors.transparent,
  });

  @override
  TextFieldTextState createState() => TextFieldTextState();
}

class TextFieldTextState extends State<TextFieldSendBTC> {
  final _decimalFormatter =
      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'));
  bool isBitcoinBase = false;
  @override
  void initState() {
    isBitcoinBase = widget.isBitcoinBaseValueNotifier
        .value; // true: is using btc as amount, need to calculate fiat currency value
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                child: TextField(
                  textAlign: TextAlign.start,
                  textAlignVertical: TextAlignVertical.center,
                  style: FontManager.body2Regular(
                      ProtonColors.textNorm),
                  maxLines: 1,
                  minLines: 1,
                  controller: widget.controller,
                  focusNode: widget.focusNode,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [_decimalFormatter],
                  decoration: InputDecoration(
                    hintText: isBitcoinBase
                        ? "Enter BTC amount"
                        : "Enter ${widget.currency.name.toUpperCase()} amount",
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: widget.color, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                          color: ProtonColors.interactionNorm, width: 2),
                    ),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                            onTap: () {
                              double estimateValue = getEstimateValue();
                              isBitcoinBase = !isBitcoinBase;
                              widget.isBitcoinBaseValueNotifier.value =
                                  isBitcoinBase;
                              if (isBitcoinBase) {
                                widget.controller.text =
                                    estimateValue.toStringAsFixed(8);
                              } else {
                                widget.controller.text =
                                    estimateValue.toStringAsFixed(3);
                              }
                              setState(() {});
                            },
                            child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 2),
                                child: Text(
                                    isBitcoinBase
                                        ? widget.currency.name.toUpperCase()
                                        : "BTC",
                                    style: FontManager.body2Regular(
                                        ProtonColors.textNorm)))),
                        const SizedBox(
                          width: 4,
                        ),
                        GestureDetector(
                            onTap: () {
                              if (isBitcoinBase) {
                                widget.controller.text =
                                    widget.btcBalance.toStringAsFixed(8);
                              } else {
                                widget.controller.text = (widget.btcBalance *
                                        widget.currencyExchangeRate /
                                        100)
                                    .toStringAsFixed(3);
                              }
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
              )),
          const SizedBox(
            height: 5,
          ),
          Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                  isBitcoinBase
                      ? "≈${getEstimateValue()} ${widget.currency.name.toUpperCase()}"
                      : S.of(context).current_balance_btc(
                          getEstimateValue().toStringAsFixed(8)),
                  textAlign: TextAlign.start,
                  style: FontManager.captionRegular(ProtonColors.textHint))),
        ]);
  }

  double getEstimateValue() {
    double amount = 0.0;
    try {
      amount = double.parse(widget.controller.text);
    } catch (e) {
      amount = 0.0;
    }
    return CommonHelper.getEstimateValue(
        amount: amount,
        isBitcoinBase: isBitcoinBase,
        currencyExchangeRate: widget.currencyExchangeRate);
  }
}
