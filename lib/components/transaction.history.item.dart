import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/user.settings.provider.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/theme/theme.font.dart';

class TransactionHistoryItem extends StatelessWidget {
  final String title;
  final String content;
  final String? memo;
  final VoidCallback? titleCallback; // display after title
  final VoidCallback? titleOptionsCallback; // display at far right of title
  final Color? contentColor;
  final bool copyContent;
  final int? amountInSATS;
  final ProtonExchangeRate? exchangeRate;

  const TransactionHistoryItem({
    super.key,
    required this.title,
    required this.content,
    this.memo,
    this.titleOptionsCallback,
    this.titleCallback,
    this.contentColor,
    this.copyContent = false,
    this.amountInSATS,
    this.exchangeRate,
  });

  @override
  Widget build(BuildContext context) {
    String fiatCurrencyName =
        Provider.of<UserSettingProvider>(context).getFiatCurrencyName();
    if (exchangeRate != null) {
      fiatCurrencyName = Provider.of<UserSettingProvider>(context)
          .getFiatCurrencyName(fiatCurrency: exchangeRate!.fiatCurrency);
    }
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(defaultPadding),
      color: ProtonColors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(title,
                          style:
                              FontManager.body2Median(ProtonColors.textWeak)),
                      const SizedBox(width: 2),
                      if (titleCallback != null)
                        GestureDetector(
                            onTap: titleCallback,
                            child: Icon(Icons.info_rounded,
                                color: ProtonColors.textHint, size: 14))
                    ]),
                if (titleOptionsCallback != null)
                  GestureDetector(
                      onTap: titleOptionsCallback,
                      child: Text(S.of(context).advanced_options,
                          style:
                              FontManager.body2Median(ProtonColors.textWeak)))
              ]),
          Row(children: [
            SizedBox(
                width: MediaQuery.of(context).size.width - 110,
                child: Text(content.isNotEmpty ? content : memo ?? "",
                    style: FontManager.body2Median(contentColor != null
                        ? contentColor!
                        : ProtonColors.textNorm),
                    maxLines: 3,
                    softWrap: true)),
            const SizedBox(width: 2),
            if (copyContent)
              GestureDetector(
                onTap: () {
                  // TODO:: fix me
                  String bitcoinAddress = "";
                  if (CommonHelper.isBitcoinAddress(content)) {
                    bitcoinAddress = content;
                  } else if (CommonHelper.isBitcoinAddress(memo ?? "")) {
                    bitcoinAddress = memo ?? "";
                  }
                  if (bitcoinAddress.isNotEmpty) {
                    Clipboard.setData(ClipboardData(text: bitcoinAddress))
                        .then((_) {
                      if (context.mounted) {
                        CommonHelper.showSnackbar(
                            context, S.of(context).copied_address);
                      }
                    });
                  }
                },
                child: Icon(Icons.copy_rounded,
                    size: 16,
                    color: contentColor != null
                        ? contentColor!
                        : ProtonColors.textHint),
              )
          ]),
          if (memo != null && content.isNotEmpty)
            Text(memo!, style: FontManager.body2Regular(ProtonColors.textHint)),
          if (amountInSATS != null)
            Row(
              children: [
                Text(
                    "$fiatCurrencyName ${Provider.of<UserSettingProvider>(context).getNotionalInFiatCurrency(amountInSATS!, exchangeRate: exchangeRate).abs().toStringAsFixed(defaultDisplayDigits)}",
                    style: FontManager.body2Regular(ProtonColors.textHint)),
                const SizedBox(width: 5),
                Text(
                    "(${Provider.of<UserSettingProvider>(context).getBitcoinUnitLabel(amountInSATS!)})",
                    style: FontManager.body2Regular(ProtonColors.textHint)),
              ],
            )
        ],
      ),
    );
  }
}
