import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/managers/providers/local.bitcoin.address.provider.dart';
import 'package:wallet/theme/theme.font.dart';

typedef ShowTransactionDetailCallback = void Function(
  String txid,
  String accountID,
);

class BitcoinAddressInfoBox extends StatelessWidget {
  final BitcoinAddressDetail bitcoinAddressDetail;
  final String accountName;
  final ShowTransactionDetailCallback showTransactionDetailCallback;

  const BitcoinAddressInfoBox({
    required this.bitcoinAddressDetail,
    required this.accountName,
    required this.showTransactionDetailCallback,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(0),
      padding: const EdgeInsets.symmetric(
        horizontal: defaultPadding,
      ),
      color:
          bitcoinAddressDetail.bitcoinAddressModel.inEmailIntegrationPool == 1
              ? ProtonColors.yellow1Background
              : ProtonColors.white,
      child: Column(
        children: [
          const SizedBox(
            height: 6,
          ),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(
                      text: bitcoinAddressDetail
                          .bitcoinAddressModel.bitcoinAddress))
                  .then((_) {
                if (context.mounted) {
                  CommonHelper.showSnackbar(
                      context, S.of(context).copied_address);
                }
              });
            },
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    bitcoinAddressDetail.bitcoinAddressModel.bitcoinAddress,
                    style: FontManager.body1Median(ProtonColors.textNorm),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(
                  width: 2,
                ),
                Transform.translate(
                  offset: const Offset(0, 2),
                  child: Icon(Icons.copy_rounded,
                      color: ProtonColors.textWeak, size: 14),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          Row(
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  "Index",
                  style: FontManager.body2Regular(ProtonColors.textWeak),
                ),
              ),
              Text(
                bitcoinAddressDetail.bitcoinAddressModel.bitcoinAddressIndex
                    .toString(),
                style: FontManager.body2Regular(ProtonColors.textWeak),
              ),
            ],
          ),
          Row(
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  "Account",
                  style: FontManager.body2Regular(ProtonColors.textWeak),
                ),
              ),
              Expanded(
                child: Text(
                  accountName,
                  style: FontManager.body2Regular(ProtonColors.textWeak),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Row(
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  "Use for",
                  style: FontManager.body2Regular(ProtonColors.textWeak),
                ),
              ),
              Expanded(
                child: Text(
                  bitcoinAddressDetail
                              .bitcoinAddressModel.inEmailIntegrationPool ==
                          1
                      ? "BvE pool"
                      : "Manual generated",
                  style: FontManager.body2Regular(ProtonColors.textWeak),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Row(
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  "Status",
                  style: FontManager.body2Regular(ProtonColors.textWeak),
                ),
              ),
              bitcoinAddressDetail.bitcoinAddressModel.used == 1
                  ? Text(
                      "Used",
                      style:
                          FontManager.body2Regular(ProtonColors.signalSuccess),
                    )
                  : Text(
                      "Unused",
                      style: FontManager.body2Regular(ProtonColors.signalError),
                    ),
            ],
          ),
          if (bitcoinAddressDetail.txIDs.isNotEmpty)
            Row(children: [
              SizedBox(
                width: 120,
                child: Text(
                  S.of(context).transactions,
                  style: FontManager.body2Regular(ProtonColors.textWeak),
                ),
              ),
              Expanded(
                child: Column(children: [
                  for (String txID in bitcoinAddressDetail.txIDs)
                    GestureDetector(
                      onTap: () {
                        showTransactionDetailCallback(
                            txID, bitcoinAddressDetail.accountID);
                      },
                      child: Text(
                        txID,
                        style:
                            FontManager.body2Regular(ProtonColors.protonBlue),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ]),
              ),
            ]),
          const SizedBox(
            height: 10,
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
