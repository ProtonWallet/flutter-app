import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wallet/constants/app.config.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/common.helper.dart';
import 'package:wallet/helper/exchange.caculator.dart';
import 'package:wallet/helper/extension/build.context.extension.dart';
import 'package:wallet/helper/local_toast.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/rust/api/bdk_wallet/address.dart';
import 'package:wallet/rust/api/bdk_wallet/transaction_details.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/scenes/components/button.circle.image.dart';

/// Callback functions
typedef ShowTransactionDetailCallback = void Function(
  FrbTransactionDetails frbTransactionDetails,
);
typedef ShowAddressQRcodeCallback = void Function(
  String address,
);
typedef OnSigningCallback = void Function(
  String address,
);

///
class BitcoinAddressInfoBox extends StatelessWidget {
  final FrbAddressDetails bitcoinAddressDetail;
  final ProtonExchangeRate exchangeRate;
  final ShowTransactionDetailCallback showTransactionDetailCallback;
  final ShowAddressQRcodeCallback showAddressQRcodeCallback;
  final OnSigningCallback onSigningCallback;
  final bool showMessageSigner;
  final bool inPool;
  final bool showTransactions;

  const BitcoinAddressInfoBox({
    required this.bitcoinAddressDetail,
    required this.exchangeRate,
    required this.showTransactionDetailCallback,
    required this.showAddressQRcodeCallback,
    required this.onSigningCallback,
    required this.inPool,
    required this.showMessageSigner,
    this.showTransactions = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textWidth = 120.0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      color: ProtonColors.backgroundSecondary,
      child: Column(children: [
        SizedBoxes.box8,

        /// address, copy, qr code, signing
        GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(
              text: bitcoinAddressDetail.address,
            )).then((_) {
              if (context.mounted) {
                LocalToast.showToast(
                  context,
                  S.of(context).copied_address,
                );
              }
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// address text
              Expanded(
                child: Text(
                  bitcoinAddressDetail.address,
                  style: ProtonStyles.body2Semibold(
                    color: ProtonColors.textNorm,
                  ),
                  textAlign: TextAlign.left,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),

              /// copy button
              CircleImageButton(
                icon: context.images.iconCopy.svg(),
              ),
              const SizedBox(width: 8),

              /// qr code button
              CircleImageButton(
                onTap: () {
                  showAddressQRcodeCallback(bitcoinAddressDetail.address);
                },
                backgroundColor: ProtonColors.backgroundNorm,
                icon: context.images.iconQrCode.svg(),
              ),

              /// signing button
              if (showMessageSigner) ...[
                const SizedBox(width: 8),
                CircleImageButton(
                  onTap: () {
                    onSigningCallback(bitcoinAddressDetail.address);
                  },
                  backgroundColor: ProtonColors.backgroundNorm,
                  icon: context.images.iconSign.svg(),
                ),
              ],
            ],
          ),
        ),

        /// Bve address tooltip
        if (inPool) ...[
          const SizedBox(height: 8),
          Row(children: [
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: ProtonColors.protonBlue,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: Text(
                  context.local.email_integration,
                  style: ProtonStyles.captionSemibold(
                    color: ProtonColors.textInverted,
                  ),
                ),
              ),
            ),
          ]),
        ],

        /// index row
        const SizedBox(height: 16),
        Row(children: [
          SizedBox(
            width: textWidth,
            child: Text(
              S.of(context).address_list_index,
              style: ProtonStyles.body2Medium(color: ProtonColors.textHint),
            ),
          ),
          Text(
            bitcoinAddressDetail.index.toString(),
            style: ProtonStyles.body2Medium(color: ProtonColors.textWeak),
          ),
        ]),

        /// status row
        Row(children: [
          SizedBox(
            width: textWidth,
            child: Text(
              S.of(context).address_list_status,
              style: ProtonStyles.body2Medium(color: ProtonColors.textHint),
            ),
          ),
          !bitcoinAddressDetail.isTransEmpty
              ? Text(
                  S.of(context).address_list_status_used,
                  style: ProtonStyles.body2Medium(
                    color: ProtonColors.notificationSuccess,
                  ),
                )
              : Text(
                  S.of(context).address_list_status_not_used,
                  style: ProtonStyles.body2Medium(
                    color: ProtonColors.notificationError,
                  ),
                ),
        ]),

        /// value row
        Row(children: [
          SizedBox(
            width: textWidth,
            child: Text(
              S.of(context).address_list_value,
              style: ProtonStyles.body2Medium(
                color: ProtonColors.textWeak,
              ),
            ),
          ),
          Text(
            CommonHelper.getFiatCurrencySign(exchangeRate.fiatCurrency) +
                ExchangeCalculator.getNotionalInFiatCurrency(
                  exchangeRate,
                  bitcoinAddressDetail.balance.total().toSat().toInt(),
                ).toStringAsFixed(defaultDisplayDigits),
            style: ProtonStyles.body2Medium(color: ProtonColors.textWeak),
          ),
        ]),

        /// transactions row
        if (showTransactions && !bitcoinAddressDetail.isTransEmpty)
          Row(children: [
            SizedBox(
              width: textWidth,
              child: Text(
                S.of(context).transactions,
                style: ProtonStyles.body2Medium(
                  color: ProtonColors.textWeak,
                ),
              ),
            ),
            Expanded(
              child: Column(children: [
                for (final transaction in bitcoinAddressDetail.transactions)
                  GestureDetector(
                    onTap: () {
                      showTransactionDetailCallback(transaction);
                    },
                    child: Text(
                      transaction.txid,
                      style: ProtonStyles.body2Regular(
                        color: ProtonColors.protonBlue,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ]),
            ),
          ]),

        /// View on Blockstream
        Padding(
          padding: const EdgeInsets.only(bottom: 12, top: 8),
          child: GestureDetector(
            onTap: () {
              launchUrl(
                  Uri.parse(
                    "${appConfig.esploraWebpageUrl}address/${bitcoinAddressDetail.address}",
                  ),
                  mode: LaunchMode.externalApplication);
            },
            child: Row(
              children: [
                Icon(
                  Icons.link_rounded,
                  color: ProtonColors.protonBlue,
                  size: 18,
                ),
                SizedBoxes.box8,
                Text(
                  S.of(context).view_on_blockstream,
                  style: ProtonStyles.body2Medium(
                    color: ProtonColors.protonBlue,
                  ),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        ),
        Divider(thickness: 0.2, height: 1, color: ProtonColors.textNorm),
      ]),
    );
  }
}
