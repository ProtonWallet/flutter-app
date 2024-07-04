import 'package:flutter/material.dart';
import 'package:wallet/scenes/components/bottom.sheets/recipient.detail.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/bitcoin.amount.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/theme/theme.font.dart';

class TransactionHistorySendItem extends StatelessWidget {
  final String content;
  final String bitcoinAddress;
  final String? walletAccountName;
  final BitcoinAmount? bitcoinAmount;

  const TransactionHistorySendItem({
    super.key,
    required this.content,
    required this.bitcoinAddress,
    this.walletAccountName,
    this.bitcoinAmount,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        RecipientDetailSheet.show(
          context,
          content,
          content,
          bitcoinAddress,
          bitcoinAddress == content,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(defaultPadding),
        color: ProtonColors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(S.of(context).trans_to,
                        style: FontManager.body2Median(ProtonColors.textWeak)),
                    SizedBox(
                        width: 180,
                        child: Text(
                          content,
                          style: FontManager.body2Median(ProtonColors.textNorm),
                          overflow: TextOverflow.ellipsis,
                        )),
                    if (walletAccountName != null &&
                        walletAccountName != content)
                      SizedBox(
                          width: 180,
                          child: Text(
                            walletAccountName!,
                            style:
                                FontManager.body2Median(ProtonColors.textWeak),
                            overflow: TextOverflow.ellipsis,
                          )),
                  ],
                ),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  if (bitcoinAmount != null)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(bitcoinAmount!.toFiatCurrencyString(),
                            style: FontManager.body2Regular(
                                ProtonColors.textNorm)),
                        Text(bitcoinAmount!.toString(),
                            style: FontManager.body2Regular(
                                ProtonColors.textHint)),
                      ],
                    ),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_forward_ios_rounded,
                      color: ProtonColors.textWeak, size: 14),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
