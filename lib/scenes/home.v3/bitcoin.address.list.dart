//bitcoin.address.list
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/managers/wallet/proton.wallet.manager.dart';
import 'package:wallet/models/bitcoin.address.model.dart';
import 'package:wallet/scenes/home.v3/home.viewmodel.dart';
import 'package:wallet/theme/theme.font.dart';

import '../core/view.navigatior.identifiers.dart';

class BitcoinAddressList extends StatelessWidget {
  final HomeViewModel viewModel;

  const BitcoinAddressList({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(defaultPadding),
        child: Center(
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(3),
              2: FlexColumnWidth(1),
              3: FlexColumnWidth(1),
              4: FlexColumnWidth(1),
              5: FlexColumnWidth(3),
            },
            border: TableBorder(
                horizontalInside: BorderSide(
                    width: 0.4,
                    color: ProtonColors.textHint,
                    style: BorderStyle.solid)),
            children: [
              if (Provider.of<ProtonWalletProvider>(context)
                  .protonWallet
                  .currentBitcoinAddresses
                  .isNotEmpty)
                TableRow(children: [
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        "index",
                        style: FontManager.body2Regular(ProtonColors.textNorm),
                        textAlign: TextAlign.center,
                      )),
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        "address",
                        style: FontManager.body2Regular(ProtonColors.textNorm),
                        textAlign: TextAlign.center,
                      )),
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        "used",
                        style: FontManager.body2Regular(ProtonColors.textNorm),
                        textAlign: TextAlign.center,
                      )),
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        "isPool",
                        style: FontManager.body2Regular(ProtonColors.textNorm),
                        textAlign: TextAlign.center,
                      )),
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        "accountID",
                        style: FontManager.body2Regular(ProtonColors.textNorm),
                        textAlign: TextAlign.center,
                      )),
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        "transactions",
                        style: FontManager.body2Regular(ProtonColors.textNorm),
                        textAlign: TextAlign.center,
                      )),
                ]),
              for (BitcoinAddressModel bitcoinAddressModel
                  in Provider.of<ProtonWalletProvider>(context)
                      .protonWallet
                      .currentBitcoinAddresses)
                TableRow(children: [
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        bitcoinAddressModel.bitcoinAddressIndex.toString(),
                        style: FontManager.body2Regular(ProtonColors.textNorm),
                        textAlign: TextAlign.center,
                      )),
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(children: [
                        Expanded(
                            child: Text(
                          bitcoinAddressModel.bitcoinAddress,
                          style:
                              FontManager.body2Regular(ProtonColors.textNorm),
                          textAlign: TextAlign.center,
                        )),
                        GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(
                                      text: bitcoinAddressModel.bitcoinAddress))
                                  .then((_) {
                                if (context.mounted) {
                                  CommonHelper.showSnackbar(
                                      context, S.of(context).copied_address);
                                }
                              });
                            },
                            child: Icon(Icons.copy_rounded,
                                size: 16, color: ProtonColors.textHint))
                      ])),
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        (bitcoinAddressModel.used == 1).toString(),
                        style: FontManager.body2Regular(ProtonColors.textNorm),
                        textAlign: TextAlign.center,
                      )),
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        (bitcoinAddressModel.inEmailIntegrationPool == 1)
                            .toString(),
                        style: FontManager.body2Regular(ProtonColors.textNorm),
                        textAlign: TextAlign.center,
                      )),
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        Provider.of<ProtonWalletProvider>(context)
                            .protonWallet
                            .getAccountName(bitcoinAddressModel.accountID),
                        style: FontManager.body2Regular(ProtonColors.textNorm),
                        textAlign: TextAlign.center,
                      )),
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        children: [
                          for (String txID
                              in Provider.of<ProtonWalletProvider>(context)
                                  .protonWallet
                                  .getTransactionIDsByBitcoinAddress(
                                      bitcoinAddressModel.bitcoinAddress))
                            GestureDetector(
                                onTap: () async {
                                  viewModel.selectedTXID = txID;
                                  viewModel.historyAccountModel = await DBHelper
                                      .accountDao!
                                      .findById(bitcoinAddressModel.accountID);
                                  viewModel.move(NavID.historyDetails);
                                },
                                child: Text(txID,
                                    style: FontManager.body2Regular(
                                        ProtonColors.protonBlue))),
                        ],
                      )),
                ]),
            ],
          ),
        ));
  }
}
