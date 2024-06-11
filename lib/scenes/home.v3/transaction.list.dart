import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:wallet/components/textfield.text.dart';
import 'package:wallet/components/transaction/transaction.listtitle.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/managers/wallet/proton.wallet.manager.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/scenes/home.v3/bottom.sheet/transaction.filter.dart';
import 'package:wallet/scenes/home.v3/home.viewmodel.dart';
import 'package:wallet/theme/theme.font.dart';

import '../core/view.navigatior.identifiers.dart';

class TransactionList extends StatelessWidget {
  final HomeViewModel viewModel;

  const TransactionList({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          child: viewModel.showSearchHistoryTextField
              ? TextFieldText(
                  borderRadius: 20,
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  color: ProtonColors.backgroundSecondary,
                  suffixIcon: const Icon(Icons.close, size: 16),
                  prefixIcon: const Icon(Icons.search, size: 16),
                  showSuffixIcon: true,
                  suffixIconOnPressed: () {
                    viewModel.setSearchHistoryTextField(false);
                  },
                  scrollPadding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom + 100),
                  controller: viewModel.transactionSearchController,
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          Text(
                            S.of(context).transactions,
                            style:
                                FontManager.body1Median(ProtonColors.textNorm),
                            textAlign: TextAlign.left,
                          ),
                        ]),
                        Row(children: [
                          IconButton(
                              onPressed: () {
                                TransactionFilterSheet.show(context, viewModel);
                              },
                              icon: SvgPicture.asset(
                                  "assets/images/icon/setup-preference.svg",
                                  fit: BoxFit.fill,
                                  width: 16,
                                  height: 16)),
                          IconButton(
                              onPressed: () {
                                viewModel.setSearchHistoryTextField(true);
                              },
                              icon: Icon(Icons.search_rounded,
                                  color: ProtonColors.textNorm, size: 16))
                        ]),
                      ]))),
      for (int index = 0;
          index <
              min(
                  Provider.of<ProtonWalletProvider>(context)
                      .protonWallet
                      .historyTransactionsAfterFilter
                      .length,
                  defaultTransactionPerPage * viewModel.currentHistoryPage +
                      defaultTransactionPerPage);
          index++)
        TransactionListTitle(
            width: MediaQuery.of(context).size.width,
            address: WalletManager.getEmailFromWalletTransaction(
                Provider.of<ProtonWalletProvider>(context).protonWallet.historyTransactionsAfterFilter[index].amountInSATS > 0
                    ? Provider.of<ProtonWalletProvider>(context)
                        .protonWallet
                        .historyTransactionsAfterFilter[index]
                        .sender
                    : Provider.of<ProtonWalletProvider>(context)
                        .protonWallet
                        .historyTransactionsAfterFilter[index]
                        .toList,
                selfEmailAddresses:
                    viewModel.protonAddresses.map((e) => e.email).toList()),
            amount: Provider.of<ProtonWalletProvider>(context)
                .protonWallet
                .historyTransactionsAfterFilter[index]
                .amountInSATS
                .toDouble(),
            note: Provider.of<ProtonWalletProvider>(context)
                    .protonWallet
                    .historyTransactionsAfterFilter[index]
                    .label ??
                "",
            body: Provider.of<ProtonWalletProvider>(context)
                    .protonWallet
                    .historyTransactionsAfterFilter[index]
                    .body ??
                "",
            onTap: () {
              viewModel.selectedTXID =
                  Provider.of<ProtonWalletProvider>(context, listen: false)
                      .protonWallet
                      .historyTransactionsAfterFilter[index]
                      .txID;
              viewModel.historyAccountModel =
                  Provider.of<ProtonWalletProvider>(context, listen: false)
                      .protonWallet
                      .historyTransactionsAfterFilter[index]
                      .accountModel;
              viewModel.move(NavID.historyDetails);
            },
            timestamp: Provider.of<ProtonWalletProvider>(context)
                .protonWallet
                .historyTransactionsAfterFilter[index]
                .createTimestamp,
            isSend: Provider.of<ProtonWalletProvider>(context).protonWallet.historyTransactionsAfterFilter[index].amountInSATS < 0,
            exchangeRate: Provider.of<ProtonWalletProvider>(context).protonWallet.historyTransactionsAfterFilter[index].exchangeRate),
      if (Provider.of<ProtonWalletProvider>(context)
              .protonWallet
              .historyTransactionsAfterFilter
              .length >
          defaultTransactionPerPage * viewModel.currentHistoryPage +
              defaultTransactionPerPage)
        GestureDetector(
            onTap: () {
              viewModel.showMoreTransactionHistory();
            },
            child: Container(
                padding: const EdgeInsets.only(top: 10),
                child: Text("Show more",
                    style: FontManager.body1Regular(ProtonColors.protonBlue)))),
      if (Provider.of<ProtonWalletProvider>(context)
          .protonWallet
          .historyTransactionsAfterFilter
          .isEmpty)
        Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const SizedBox(
            height: 10,
          ),
          Center(
              child: SvgPicture.asset("assets/images/icon/do_transactions.svg",
                  fit: BoxFit.fill, width: 26, height: 26)),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
              width: 280,
              child: Text(
                "Send and receive Bitcoin with your email.",
                style: FontManager.titleHeadline(ProtonColors.textNorm),
                textAlign: TextAlign.center,
              )),
          const SizedBox(
            height: 10,
          ),
        ]),
    ]);
  }
}
