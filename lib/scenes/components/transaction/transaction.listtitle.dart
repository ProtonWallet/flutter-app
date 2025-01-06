import 'package:flutter/material.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/bitcoin.amount.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/l10n/generated/locale.dart';

class TransactionListTitle extends StatelessWidget {
  final double width;
  final String address;
  final BitcoinAmount bitcoinAmount;
  final bool isSend;
  final int? timestamp;
  final VoidCallback? onTap;
  final String note;
  final String? body;
  final bool displayBalance;

  const TransactionListTitle({
    required this.width,
    required this.address,
    required this.isSend,
    required this.bitcoinAmount,
    required this.displayBalance,
    super.key,
    this.timestamp,
    this.note = "",
    this.onTap,
    this.body,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(
            left: 26,
            right: 26,
          ),
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(children: [
            isSend
                ? Assets.images.icon.send.svg(
                    fit: BoxFit.fill,
                    width: 32,
                    height: 32,
                  )
                : Assets.images.icon.receive.svg(
                    fit: BoxFit.fill,
                    width: 32,
                    height: 32,
                  ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
              child: SizedBox(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        timestamp != null
                            ? Expanded(
                                child: Text(
                                CommonHelper
                                    .formatLocaleTimeWithSendOrReceiveOn(
                                        context, timestamp!,
                                        isSend: isSend),
                                style: ProtonStyles.body2Medium(
                                    color: ProtonColors.textHint),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ))
                            : Row(children: [
                                Text(
                                    isSend
                                        ? S.of(context).in_progress_broadcasted
                                        : S
                                            .of(context)
                                            .in_progress_waiting_for_confirm,
                                    style: ProtonStyles.body2Medium(
                                        color: ProtonColors.protonBlue)),
                              ]),
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Text(
                          isSend
                              ? "${S.of(context).trans_to} $address"
                              : "${S.of(context).trans_from} $address",
                          style: ProtonStyles.body2Medium(
                              color: ProtonColors.textNorm),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )),
                      ]),
                  if ((body ?? "").isNotEmpty)
                    Row(children: [
                      Expanded(
                          child: Text(
                        S.of(context).trans_body((body ?? "")
                            .replaceAll("\r", " ")
                            .replaceAll("\n", " ")),
                        style: ProtonStyles.body2Medium(
                            color: ProtonColors.textWeak),
                        overflow: TextOverflow.ellipsis,
                      ))
                    ]),
                ],
              )),
            ),
            const SizedBox(
              width: 6,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                isSend
                    ? Text(
                        bitcoinAmount.toFiatCurrencySignString(
                            displayBalance: displayBalance),
                        style: ProtonStyles.captionRegular(
                            color: ProtonColors.signalError))
                    : Text(
                        "+${bitcoinAmount.toFiatCurrencySignString(displayBalance: displayBalance)}",
                        style: ProtonStyles.captionRegular(
                            color: ProtonColors.signalSuccess)),
              ],
            ),
          ]),
        ));
  }
}
