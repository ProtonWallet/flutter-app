import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/bitcoin.amount.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/theme/theme.font.dart';

class TransactionHistoryItem extends StatelessWidget {
  final String title;
  final String content;
  final String? memo;
  final String? bitcoinAddress;
  final String? walletAccountName;
  final VoidCallback? titleCallback; // display after title
  final VoidCallback? titleOptionsCallback; // display at far right of title
  final Color? contentColor;
  final BitcoinAmount? bitcoinAmount;

  const TransactionHistoryItem({
    super.key,
    required this.title,
    required this.content,
    this.memo,
    this.titleOptionsCallback,
    this.titleCallback,
    this.contentColor,
    this.bitcoinAmount,
    this.bitcoinAddress,
    this.walletAccountName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      color: ProtonColors.backgroundProton,
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
          if (content.isNotEmpty || memo != null)
            GestureDetector(
                onLongPress: () {
                  Clipboard.setData(ClipboardData(
                          text: content.isNotEmpty ? content : memo ?? ""))
                      .then((_) {
                    if (context.mounted) {
                      CommonHelper.showSnackbar(context, S.of(context).copied);
                    }
                  });
                },
                child: Row(children: [
                  Expanded(
                      child: Text(content.isNotEmpty ? content : memo ?? "",
                          style: FontManager.body2Median(contentColor != null
                              ? contentColor!
                              : ProtonColors.textNorm),
                          softWrap: true)),
                  const SizedBox(width: 2),
                ])),
          if (memo != null && content.isNotEmpty)
            GestureDetector(
                onLongPress: () {
                  Clipboard.setData(ClipboardData(text: memo ?? "")).then((_) {
                    if (context.mounted) {
                      CommonHelper.showSnackbar(context, S.of(context).copied);
                    }
                  });
                },
                child: Text(memo!,
                    style: FontManager.body2Regular(ProtonColors.textHint))),
          if (walletAccountName != null)
            GestureDetector(
                onLongPress: () {
                  Clipboard.setData(
                          ClipboardData(text: walletAccountName ?? ""))
                      .then((_) {
                    if (context.mounted) {
                      CommonHelper.showSnackbar(context, S.of(context).copied);
                    }
                  });
                },
                child: Text(walletAccountName!,
                    style: FontManager.body2Regular(ProtonColors.textNorm))),
          if (bitcoinAddress != null)
            GestureDetector(
              onTap: () {
                if (bitcoinAddress!.isNotEmpty) {
                  Clipboard.setData(ClipboardData(text: bitcoinAddress!))
                      .then((_) {
                    if (context.mounted) {
                      CommonHelper.showSnackbar(
                          context, S.of(context).copied_address);
                    }
                  });
                }
              },
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(bitcoinAddress!,
                        style: FontManager.body2Median(ProtonColors.textHint),
                        softWrap: true),
                    const SizedBox(width: 4),
                    Icon(Icons.copy_rounded,
                        size: 16,
                        color: contentColor != null
                            ? contentColor!
                            : ProtonColors.textHint),
                  ]),
            ),
          if (bitcoinAmount != null)
            Row(
              children: [
                Text(bitcoinAmount!.toFiatCurrencyString(),
                    style: FontManager.body2Regular(ProtonColors.textHint)),
                const SizedBox(width: 5),
                Text(bitcoinAmount!.toString(),
                    style: FontManager.body2Regular(ProtonColors.textHint)),
              ],
            )
        ],
      ),
    );
  }
}
