//bitcoin.address.list
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/managers/features/models/wallet.list.dart';
import 'package:wallet/managers/features/wallet.list.bloc.dart';
import 'package:wallet/managers/features/wallet.transaction.bloc.dart';
import 'package:wallet/managers/providers/local.bitcoin.address.provider.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/home.v3/bottom.sheet/transaction.bitcoinaddress.switch.dart';
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
    return BlocBuilder<WalletListBloc, WalletListState>(
        bloc: viewModel.walletListBloc,
        builder: (context, state) {
          Map<String, String> accountID2Name = {};
          for (WalletMenuModel walletMenuModel in state.walletsModel) {
            for (AccountMenuModel accountMenuModel
                in walletMenuModel.accounts) {
              accountID2Name[accountMenuModel.accountModel.accountID] =
                  accountMenuModel.label;
            }
          }
          return BlocBuilder<WalletTransactionBloc, WalletTransactionState>(
              bloc: viewModel.walletTransactionBloc,
              builder: (context, state) {
                return Column(children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: defaultPadding,
                      right: defaultPadding,
                      top: 12,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        TransactionBitcoinAddressSwitchSheet.show(
                          context,
                          viewModel,
                        );
                      },
                      child: Row(children: [
                        Text(
                          S.of(context).bitcoin_address,
                          style: FontManager.body1Median(ProtonColors.textNorm),
                          textAlign: TextAlign.left,
                        ),
                        Icon(
                          Icons.keyboard_arrow_down_outlined,
                          size: 18,
                          color: ProtonColors.textWeak,
                        ),
                      ]),
                    ),
                  ),
                  Container(
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
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    child: Text(
                                      "index",
                                      style: FontManager.body2Regular(
                                          ProtonColors.textNorm),
                                      textAlign: TextAlign.center,
                                    )),
                                Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    child: Text(
                                      "address",
                                      style: FontManager.body2Regular(
                                          ProtonColors.textNorm),
                                      textAlign: TextAlign.center,
                                    )),
                                Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    child: Text(
                                      "used",
                                      style: FontManager.body2Regular(
                                          ProtonColors.textNorm),
                                      textAlign: TextAlign.center,
                                    )),
                                Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    child: Text(
                                      "isPool",
                                      style: FontManager.body2Regular(
                                          ProtonColors.textNorm),
                                      textAlign: TextAlign.center,
                                    )),
                                Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    child: Text(
                                      "accountID",
                                      style: FontManager.body2Regular(
                                          ProtonColors.textNorm),
                                      textAlign: TextAlign.center,
                                    )),
                                Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    child: Text(
                                      "transactions",
                                      style: FontManager.body2Regular(
                                          ProtonColors.textNorm),
                                      textAlign: TextAlign.center,
                                    )),
                              ]),
                            for (BitcoinAddressDetail bitcoinAddressDetail
                                in state.bitcoinAddresses)
                              TableRow(children: [
                                Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    child: Text(
                                      bitcoinAddressDetail.bitcoinAddressModel
                                          .bitcoinAddressIndex
                                          .toString(),
                                      style: FontManager.body2Regular(
                                          ProtonColors.textNorm),
                                      textAlign: TextAlign.center,
                                    )),
                                Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(children: [
                                      Expanded(
                                          child: Text(
                                        bitcoinAddressDetail
                                            .bitcoinAddressModel.bitcoinAddress,
                                        style: FontManager.body2Regular(
                                            ProtonColors.textNorm),
                                        textAlign: TextAlign.center,
                                      )),
                                      GestureDetector(
                                          onTap: () {
                                            Clipboard.setData(ClipboardData(
                                                    text: bitcoinAddressDetail
                                                        .bitcoinAddressModel
                                                        .bitcoinAddress))
                                                .then((_) {
                                              if (context.mounted) {
                                                CommonHelper.showSnackbar(
                                                    context,
                                                    S
                                                        .of(context)
                                                        .copied_address);
                                              }
                                            });
                                          },
                                          child: Icon(Icons.copy_rounded,
                                              size: 16,
                                              color: ProtonColors.textHint))
                                    ])),
                                Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    child: Text(
                                      (bitcoinAddressDetail
                                                  .bitcoinAddressModel.used ==
                                              1)
                                          .toString(),
                                      style: FontManager.body2Regular(
                                          ProtonColors.textNorm),
                                      textAlign: TextAlign.center,
                                    )),
                                Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    child: Text(
                                      (bitcoinAddressDetail.bitcoinAddressModel
                                                  .inEmailIntegrationPool ==
                                              1)
                                          .toString(),
                                      style: FontManager.body2Regular(
                                          ProtonColors.textNorm),
                                      textAlign: TextAlign.center,
                                    )),
                                Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    child: Text(
                                      accountID2Name[
                                              bitcoinAddressDetail.accountID] ??
                                          bitcoinAddressDetail.accountID,
                                      style: FontManager.body2Regular(
                                          ProtonColors.textNorm),
                                      textAlign: TextAlign.center,
                                    )),
                                Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    child: Column(
                                      children: [
                                        for (String txID
                                            in bitcoinAddressDetail.txIDs)
                                          GestureDetector(
                                              onTap: () async {
                                                viewModel.selectedTXID = txID;
                                                viewModel.historyAccountModel =
                                                    await DBHelper.accountDao!
                                                        .findByServerID(
                                                            bitcoinAddressDetail
                                                                .accountID);
                                                viewModel
                                                    .move(NavID.historyDetails);
                                              },
                                              child: Text(
                                                  "${txID.substring(0, 10)}..",
                                                  style:
                                                      FontManager.body2Regular(
                                                          ProtonColors
                                                              .protonBlue))),
                                      ],
                                    )),
                              ]),
                          ],
                        ),
                      )),
                ]);
              });
        });
  }
}
