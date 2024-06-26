import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wallet/components/textfield.text.dart';
import 'package:wallet/components/wallet.history.transaction.list.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/managers/features/wallet.transaction.bloc.dart';
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
    return BlocBuilder<WalletTransactionBloc, WalletTransactionState>(
        bloc: viewModel.walletTransactionBloc,
        builder: (context, state) {
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
                            bottom:
                                MediaQuery.of(context).viewInsets.bottom + 100),
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
                                  style: FontManager.body1Median(
                                      ProtonColors.textNorm),
                                  textAlign: TextAlign.left,
                                ),
                              ]),
                              Row(children: [
                                IconButton(
                                    onPressed: () {
                                      TransactionFilterSheet.show(
                                          context, viewModel);
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
            WalletHistoryTransactionList(
              transactions: state.historyTransaction,
              currentPage: viewModel.currentHistoryPage,
              showMoreCallback: () {
                viewModel.showMoreTransactionHistory();
              },
              showDetailCallback: ((txid, accountModel) {
                viewModel.selectedTXID = txid;
                viewModel.historyAccountModel = accountModel;
                viewModel.move(NavID.historyDetails);
              }),
              selfEmailAddresses:
                  viewModel.protonAddresses.map((e) => e.email).toList(),
              filter: viewModel.transactionListFilterBy,
              keyWord: viewModel.transactionSearchController.text,
              bitcoinUnit: viewModel.bitcoinUnit,
            ),
            if (state.historyTransaction.isEmpty)
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const SizedBox(
                  height: 10,
                ),
                Center(
                    child: SvgPicture.asset(
                        "assets/images/icon/do_transactions.svg",
                        fit: BoxFit.fill,
                        width: 26,
                        height: 26)),
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
        });
  }
}
