import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wallet/components/custom.loading.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/user.settings.provider.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/theme/theme.font.dart';

import '../../constants/constants.dart';

class TransactionListTitle extends StatelessWidget {
  final double width;
  final String address;
  final double amount;
  final bool isSend;
  final int? timestamp;
  final VoidCallback? onTap;
  final String note;
  final String? body;

  const TransactionListTitle({
    super.key,
    required this.width,
    required this.address,
    required this.amount,
    required this.isSend,
    this.timestamp,
    this.note = "",
    this.onTap,
    this.body,
  });

  String parsetime(int timestemp) {
    var millis = timestemp;
    var dt = DateTime.fromMillisecondsSinceEpoch(millis * 1000);

    var dformat = DateFormat('MM.dd.yyyy').format(dt);
    return dformat.toString();
  }

  @override
  Widget build(BuildContext context) {
    double notional = Provider.of<UserSettingProvider>(context)
        .getNotionalInFiatCurrency(amount.toInt());
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
              width: 0.5,
            )),
          ),
          child: Row(children: [
            SvgPicture.asset(
                isSend
                    ? "assets/images/icon/send.svg"
                    : "assets/images/icon/receive.svg",
                fit: BoxFit.fill,
                width: 32,
                height: 32),
            const SizedBox(
              width: 12,
            ),
            SizedBox(
                width: MediaQuery.of(context).size.width - 130,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(address,
                              style: FontManager.captionRegular(
                                  ProtonColors.textNorm)),
                          isSend
                              ? Text(
                                  Provider.of<UserSettingProvider>(context)
                                      .getBitcoinUnitLabel(amount.toInt()),
                                  style: FontManager.captionRegular(
                                      ProtonColors.signalError))
                              : Text(
                                  "+${Provider.of<UserSettingProvider>(context).getBitcoinUnitLabel(amount.toInt())}",
                                  style: FontManager.captionRegular(
                                      ProtonColors.signalSuccess)),
                        ]),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          timestamp != null
                              ? Text(parsetime(timestamp!),
                                  style: FontManager.captionRegular(
                                      ProtonColors.textHint))
                              : Row(children: [
                                  const CustomLoading(),
                                  const SizedBox(width: 6),
                                  Text(S.of(context).in_progress,
                                      style: FontManager.captionRegular(
                                          ProtonColors.protonBlue)),
                                ]),
                          isSend
                              ? Text(
                                  "-${Provider.of<UserSettingProvider>(context).getFiatCurrencySign()}${notional.abs().toStringAsFixed(defaultDisplayDigits)}",
                                  style: FontManager.captionRegular(
                                      ProtonColors.textHint))
                              : Text(
                                  "+${Provider.of<UserSettingProvider>(context).getFiatCurrencySign()}${notional.toStringAsFixed(defaultDisplayDigits)}",
                                  style: FontManager.captionRegular(
                                      ProtonColors.textHint))
                        ]),
                    if (note != "")
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: ProtonColors.wMajor1,
                                ),
                                margin: const EdgeInsets.only(right: 4, top: 2),
                                padding: const EdgeInsets.all(2.0),
                                child: Icon(Icons.edit_outlined,
                                    size: 10, color: ProtonColors.textHint)),
                            SizedBox(
                                width: MediaQuery.of(context).size.width - 150,
                                child: Text(
                                  S.of(context).trans_note(CommonHelper.getFirstNChar(note, 24)),
                                  style: FontManager.captionRegular(
                                      ProtonColors.textHint),
                                  overflow: TextOverflow.ellipsis,
                                ))
                          ]),
                    if ((body ?? "").isNotEmpty)
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: ProtonColors.wMajor1,
                                ),
                                margin: const EdgeInsets.only(right: 4, top: 2),
                                padding: const EdgeInsets.all(2.0),
                                child: Icon(Icons.messenger_outline,
                                    size: 10, color: ProtonColors.textHint)),
                            SizedBox(
                                width: MediaQuery.of(context).size.width - 150,
                                child: Text(
                                  S.of(context).trans_body(body ?? ""),
                                  style: FontManager.captionRegular(
                                      ProtonColors.textHint),
                                  overflow: TextOverflow.ellipsis,
                                ))
                          ]),
                  ],
                )),
          ]),
        ));
  }
}
