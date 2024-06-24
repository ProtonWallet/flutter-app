//bitcoin.address.list
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/managers/features/wallet.transaction.bloc.dart';
import 'package:wallet/models/bitcoin.address.model.dart';
import 'package:wallet/scenes/home.v3/home.viewmodel.dart';
import 'package:wallet/theme/theme.font.dart';

class BitcoinAddressList extends StatelessWidget {
  final HomeViewModel viewModel;

  const BitcoinAddressList({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletTransactionBloc, WalletTransactionState>(
        bloc: viewModel.walletTransactionBloc,
        builder: (context, state) {
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
                    if (state.bitcoinAddresses.isNotEmpty)
                      TableRow(children: [
                        Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              "index",
                              style: FontManager.body2Regular(
                                  ProtonColors.textNorm),
                              textAlign: TextAlign.center,
                            )),
                        Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              "address",
                              style: FontManager.body2Regular(
                                  ProtonColors.textNorm),
                              textAlign: TextAlign.center,
                            )),
                        Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              "used",
                              style: FontManager.body2Regular(
                                  ProtonColors.textNorm),
                              textAlign: TextAlign.center,
                            )),
                        Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              "isPool",
                              style: FontManager.body2Regular(
                                  ProtonColors.textNorm),
                              textAlign: TextAlign.center,
                            )),
                        Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              "accountID",
                              style: FontManager.body2Regular(
                                  ProtonColors.textNorm),
                              textAlign: TextAlign.center,
                            )),
                        Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              "transactions",
                              style: FontManager.body2Regular(
                                  ProtonColors.textNorm),
                              textAlign: TextAlign.center,
                            )),
                      ]),
                    for (BitcoinAddressModel bitcoinAddressModel
                        in state.bitcoinAddresses)
                      TableRow(children: [
                        Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              bitcoinAddressModel.bitcoinAddressIndex
                                  .toString(),
                              style: FontManager.body2Regular(
                                  ProtonColors.textNorm),
                              textAlign: TextAlign.center,
                            )),
                        Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(children: [
                              Expanded(
                                  child: Text(
                                bitcoinAddressModel.bitcoinAddress,
                                style: FontManager.body2Regular(
                                    ProtonColors.textNorm),
                                textAlign: TextAlign.center,
                              )),
                              GestureDetector(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(
                                            text: bitcoinAddressModel
                                                .bitcoinAddress))
                                        .then((_) {
                                      if (context.mounted) {
                                        CommonHelper.showSnackbar(context,
                                            S.of(context).copied_address);
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
                              style: FontManager.body2Regular(
                                  ProtonColors.textNorm),
                              textAlign: TextAlign.center,
                            )),
                        Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              (bitcoinAddressModel.inEmailIntegrationPool == 1)
                                  .toString(),
                              style: FontManager.body2Regular(
                                  ProtonColors.textNorm),
                              textAlign: TextAlign.center,
                            )),
                        Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              "TODO:: actual account Name here",
                              style: FontManager.body2Regular(
                                  ProtonColors.textNorm),
                              textAlign: TextAlign.center,
                            )),
                        const Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Column(
                              children: [
                                /// TODO:: get transaction ID from bitcoinaddress
                                // for (String txID
                                //     in Provider.of<ProtonWalletProvider>(context)
                                //         .protonWallet
                                //         .getTransactionIDsByBitcoinAddress(
                                //             bitcoinAddressModel.bitcoinAddress))
                                //   GestureDetector(
                                //       onTap: () async {
                                //         viewModel.selectedTXID = txID;
                                //         viewModel.historyAccountModel = await DBHelper
                                //             .accountDao!
                                //             .findById(bitcoinAddressModel.accountID);
                                //         viewModel.move(NavID.historyDetails);
                                //       },
                                //       child: Text(txID,
                                //           style: FontManager.body2Regular(
                                //               ProtonColors.protonBlue))),
                              ],
                            )),
                      ]),
                  ],
                ),
              ));
        });
  }
}
