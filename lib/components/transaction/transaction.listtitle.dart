import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/theme/theme.font.dart';

class TransactionListTitle extends StatelessWidget {
  final double width;
  final String address;
  final String coin;
  final double amount;
  final double notional;
  final bool isSend;
  final int timestamp;
  final VoidCallback? onTap;
  final String note;

  const TransactionListTitle({
    super.key,
    required this.width,
    required this.address,
    required this.coin,
    required this.amount,
    required this.notional,
    required this.isSend,
    required this.timestamp,
    this.note = "",
    this.onTap,
  });

  String parsetime(int timestemp) {
    var millis = timestemp;
    var dt = DateTime.fromMillisecondsSinceEpoch(millis * 1000);

    var dformat = DateFormat('MM.dd.yyyy').format(dt);
    return dformat.toString();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(left: 26, right: 26, top: 10),
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          width: width,
          decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
              color: ProtonColors.wMajor1,
              width: 1,
            )),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(address,
                    style: FontManager.body2Regular(
                        ProtonColors.textNorm)),
                isSend
                    ? Text("$amount $coin",
                        style:
                            FontManager.body2Regular(ProtonColors.signalError))
                    : Text("+$amount $coin",
                        style: FontManager.body2Regular(
                            ProtonColors.signalSuccess)),
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(
                  children: [
                    Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ProtonColors.wMajor1,
                        ),
                        margin: const EdgeInsets.only(right: 4, top: 2),
                        padding: const EdgeInsets.all(2.0),
                        child: Icon(
                            isSend ? Icons.arrow_upward : Icons.arrow_downward,
                            size: 10,
                            color: ProtonColors.textHint)),
                    Text(
                        isSend
                            ? "Send‧${parsetime(timestamp)}"
                            : "Receive‧${parsetime(timestamp)}",
                        style:
                            FontManager.captionRegular(ProtonColors.textHint))
                  ],
                ),
                isSend
                    ? Text("-\$${notional.toStringAsFixed(3)}",
                        style: FontManager.body2Regular(ProtonColors.textHint))
                    : Text("+\$${notional.toStringAsFixed(3)}",
                        style: FontManager.body2Regular(ProtonColors.textHint))
              ]),
              if (note != "")
                Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ProtonColors.wMajor1,
                      ),
                      margin: const EdgeInsets.only(right: 4, top: 2),
                      padding: const EdgeInsets.all(2.0),
                      child: Icon(Icons.edit_outlined,
                          size: 10, color: ProtonColors.textHint)),
                  Text(S.of(context).trans_note(note),
                      style: FontManager.captionRegular(ProtonColors.textHint))
                ]),
            ],
          ),
        ));
  }
}
