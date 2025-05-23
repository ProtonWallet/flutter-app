import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/bitcoin.amount.dart';
import 'package:wallet/helper/extension/build.context.extension.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/custom.card_loading.builder.dart';
import 'package:wallet/scenes/components/custom.tooltip.dart';

class TransactionHistoryItem extends StatelessWidget {
  final String title;
  final String content;
  final String? memo;
  final String? bitcoinAddress;
  final String? walletAccountName;
  final String? titleTooltip;
  final VoidCallback? titleOptionsCallback; // display at far right of title
  final Color? contentColor;
  final Color? backgroundColor;
  final BitcoinAmount? bitcoinAmount;
  final bool isLoading;

  const TransactionHistoryItem({
    required this.title,
    required this.content,
    super.key,
    this.memo,
    this.titleOptionsCallback,
    this.titleTooltip,
    this.contentColor,
    this.bitcoinAmount,
    this.bitcoinAddress,
    this.walletAccountName,
    this.backgroundColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: defaultPadding),
      color: backgroundColor ?? ProtonColors.backgroundNorm,
      child: isLoading
          ? const CustomCardLoadingBuilder(
              height: 50,
              borderRadius: BorderRadius.all(Radius.circular(4)),
              margin: EdgeInsets.only(top: 4),
            ).build(context)
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      titleTooltip != null
                          ? CustomTooltip(
                              message: titleTooltip ?? "",
                              child: Row(
                                children: [
                                  Text(title,
                                      style: ProtonStyles.body2Medium(
                                          color: ProtonColors.textWeak)),
                                  const SizedBox(width: 2),
                                  if (titleTooltip != null)
                                    Assets.images.icon.icInfoCircle.svg(
                                      fit: BoxFit.fill,
                                      width: 20,
                                      height: 20,
                                    ),
                                ],
                              ),
                            )
                          : Text(title,
                              style: ProtonStyles.body2Medium(
                                  color: ProtonColors.textWeak)),
                      if (titleOptionsCallback != null)
                        GestureDetector(
                            onTap: titleOptionsCallback,
                            child: Text(S.of(context).advanced_options,
                                style: ProtonStyles.body2Medium(
                                    color: ProtonColors.textWeak)))
                    ]),
                if (content.isNotEmpty || memo != null)
                  GestureDetector(
                    onLongPress: () {
                      Clipboard.setData(ClipboardData(
                        text: content.isNotEmpty ? content : memo ?? "",
                      )).then((_) {
                        if (context.mounted) {
                          context.showSnackbar(S.of(context).copied);
                        }
                      });
                    },
                    child: Text(content.isNotEmpty ? content : memo ?? "",
                        style: ProtonStyles.body1Medium(
                            color: contentColor != null
                                ? contentColor!
                                : ProtonColors.textNorm),
                        softWrap: true),
                  ),
                if (memo != null && content.isNotEmpty)
                  GestureDetector(
                      onLongPress: () {
                        Clipboard.setData(ClipboardData(text: memo ?? ""))
                            .then((_) {
                          if (context.mounted) {
                            context.showSnackbar(S.of(context).copied);
                          }
                        });
                      },
                      child: Text(memo!,
                          style: ProtonStyles.body2Regular(
                              color: ProtonColors.textHint))),
                if (walletAccountName != null)
                  GestureDetector(
                      onLongPress: () {
                        Clipboard.setData(
                          ClipboardData(text: walletAccountName ?? ""),
                        ).then((_) {
                          if (context.mounted) {
                            context.showSnackbar(S.of(context).copied);
                          }
                        });
                      },
                      child: Text(walletAccountName!,
                          style: ProtonStyles.body2Regular(
                              color: ProtonColors.textNorm))),
                if (bitcoinAddress != null)
                  GestureDetector(
                    onTap: () {
                      if (bitcoinAddress!.isNotEmpty) {
                        Clipboard.setData(ClipboardData(text: bitcoinAddress!))
                            .then((_) {
                          if (context.mounted) {
                            context.showSnackbar(S.of(context).copied_address);
                          }
                        });
                      }
                    },
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(bitcoinAddress!,
                              style: ProtonStyles.body2Medium(
                                  color: ProtonColors.textHint),
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
                          style: ProtonStyles.body2Regular(
                              color: ProtonColors.textHint)),
                      const SizedBox(width: 5),
                      Text(bitcoinAmount!.toString(),
                          style: ProtonStyles.body2Regular(
                              color: ProtonColors.textHint)),
                    ],
                  )
              ],
            ),
    );
  }
}
