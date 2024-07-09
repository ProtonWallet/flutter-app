import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wallet/scenes/components/custom.loading.dart';
import 'package:wallet/scenes/components/custom.loading.with.child.dart';
import 'package:wallet/scenes/components/textfield.text.dart';
import 'package:wallet/scenes/components/wallet.history.transaction.list.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/managers/features/wallet.transaction.bloc.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/home.v3/bottom.sheet/transaction.bitcoinaddress.switch.dart';
import 'package:wallet/scenes/home.v3/bottom.sheet/transaction.filter.dart';
import 'package:wallet/scenes/home.v3/home.viewmodel.dart';
import 'package:wallet/theme/theme.font.dart';

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
                          GestureDetector(
                            onTap: () {
                              TransactionBitcoinAddressSwitchSheet.show(
                                context,
                                viewModel,
                              );
                            },
                            child: Row(children: [
                              Text(
                                S.of(context).transactions,
                                style: FontManager.body1Median(
                                    ProtonColors.textNorm),
                                textAlign: TextAlign.left,
                              ),
                              Icon(
                                Icons.keyboard_arrow_down_outlined,
                                size: 18,
                                color: ProtonColors.textWeak,
                              ),
                            ]),
                          ),
                          if (state.historyTransaction.isNotEmpty)
                            Row(children: [
                              state.isSyncing
                                  ? CustomLoadingWithChild(
                                      child: Padding(
                                        padding: const EdgeInsets.all(3),
                                        child: Icon(
                                          Icons.refresh_rounded,
                                          size: 20,
                                          color: ProtonColors.textWeak,
                                        ),
                                      ),
                                      durationInMilliSeconds: 800,
                                    )
                                  : GestureDetector(
                                      onTap: () {
                                        viewModel.walletTransactionBloc
                                            .syncWallet(true);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(3),
                                        child: Icon(
                                          Icons.refresh_rounded,
                                          size: 20,
                                          color: ProtonColors.textWeak,
                                        ),
                                      ),
                                    ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () {
                                  TransactionFilterSheet.show(
                                      context, viewModel);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(3),
                                  child: SvgPicture.asset(
                                      "assets/images/icon/setup-preference.svg",
                                      fit: BoxFit.fill,
                                      width: 20,
                                      height: 20),
                                ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () {
                                  viewModel.setSearchHistoryTextField(true);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(3),
                                  child: Icon(Icons.search_rounded,
                                      color: ProtonColors.textNorm, size: 20),
                                ),
                              ),
                              const SizedBox(width: 4),
                            ]),
                        ],
                      )),
            ),
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
              state.isSyncing
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomLoading(
                          size: 40,
                          durationInMilliSeconds: 1600,
                          strokeWidth: 3,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          S.of(context).loading_transactions,
                          style: FontManager.body2Regular(
                            ProtonColors.textWeak,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                                style: FontManager.titleHeadline(
                                    ProtonColors.textNorm),
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
