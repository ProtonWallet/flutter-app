import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wallet/constants/app.config.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/exchange.caculator.dart';
import 'package:wallet/helper/local_toast.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/rust/api/bdk_wallet/address.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/scenes/components/custom.tooltip.dart';
import 'package:wallet/scenes/components/wallet.bitcoin.address.list.dart';

class BitcoinAddressInfoBox extends StatelessWidget {
  final FrbAddressDetails bitcoinAddressDetail;
  final ProtonExchangeRate exchangeRate;
  final ShowTransactionDetailCallback showTransactionDetailCallback;
  final bool inPool;
  final bool showTransactions;

  const BitcoinAddressInfoBox({
    required this.bitcoinAddressDetail,
    required this.exchangeRate,
    required this.showTransactionDetailCallback,
    required this.inPool,
    this.showTransactions = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(0),
      padding: const EdgeInsets.symmetric(
        horizontal: defaultPadding,
      ),
      color: ProtonColors.white,
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          GestureDetector(
            onTap: () {
              Clipboard.setData(
                      ClipboardData(text: bitcoinAddressDetail.address))
                  .then((_) {
                if (context.mounted) {
                  LocalToast.showToast(
                    context,
                    S.of(context).copied_address,
                    icon: null,
                  );
                }
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    CommonHelper.shorterBitcoinAddress(
                      bitcoinAddressDetail.address,
                      leftLength: 12,
                      rightLength: 12,
                    ),
                    style: ProtonStyles.body1Medium(
                      color: inPool
                          ? ProtonColors.protonBlue
                          : ProtonColors.textNorm,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(
                  width: 2,
                ),
                Icon(Icons.copy_rounded,
                    color: ProtonColors.textWeak, size: 18),
              ],
            ),
          ),
          if (inPool)
            CustomTooltip(
              preferredDirection: AxisDirection.down,
              message: S.of(context).bve_address_tooltip,
              child: Assets.images.icon.icInfoCircleDark
                  .svg(fit: BoxFit.fill, width: 20, height: 20),
            ),
          const SizedBox(
            height: 4,
          ),
          Row(
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  S.of(context).address_list_index,
                  style:
                      ProtonStyles.body2Regular(color: ProtonColors.textWeak),
                ),
              ),
              Text(
                bitcoinAddressDetail.index.toString(),
                style: ProtonStyles.body2Regular(color: ProtonColors.textWeak),
              ),
            ],
          ),
          Row(
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  S.of(context).address_list_status,
                  style:
                      ProtonStyles.body2Regular(color: ProtonColors.textWeak),
                ),
              ),
              bitcoinAddressDetail.transactions.isNotEmpty
                  ? Text(
                      S.of(context).address_list_status_used,
                      style: ProtonStyles.body2Regular(
                          color: ProtonColors.signalSuccess),
                    )
                  : Text(
                      S.of(context).address_list_status_not_used,
                      style: ProtonStyles.body2Regular(
                          color: ProtonColors.signalError),
                    ),
            ],
          ),
          Row(
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  S.of(context).address_list_value,
                  style:
                      ProtonStyles.body2Regular(color: ProtonColors.textWeak),
                ),
              ),
              Text(
                CommonHelper.getFiatCurrencySign(exchangeRate.fiatCurrency) +
                    ExchangeCalculator.getNotionalInFiatCurrency(
                      exchangeRate,
                      bitcoinAddressDetail.balance.total().toSat().toInt(),
                    ).toStringAsFixed(defaultDisplayDigits),
                style: ProtonStyles.body2Regular(color: ProtonColors.textWeak),
              ),
            ],
          ),
          if (showTransactions && bitcoinAddressDetail.transactions.isNotEmpty)
            Row(children: [
              SizedBox(
                width: 120,
                child: Text(
                  S.of(context).transactions,
                  style:
                      ProtonStyles.body2Regular(color: ProtonColors.textWeak),
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
                            color: ProtonColors.protonBlue),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ]),
              ),
            ]),
          Align(
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 10,
              ),
              child: GestureDetector(
                onTap: () {
                  launchUrl(Uri.parse(
                      "${appConfig.esploraWebpageUrl}address/${bitcoinAddressDetail.address}"));
                },
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.link_rounded,
                      color: ProtonColors.protonBlue, size: 18),
                  const SizedBox(
                    width: 2,
                  ),
                  Text(
                    S.of(context).view_on_blockstream,
                    style: ProtonStyles.body2Regular(
                        color: ProtonColors.protonBlue),
                    textAlign: TextAlign.left,
                  ),
                ]),
              ),
            ),
          ),
          const Divider(
            thickness: 0.2,
            height: 1,
          ),
        ],
      ),
    );
  }
}
