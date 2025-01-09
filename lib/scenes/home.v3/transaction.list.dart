import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/managers/features/wallet.trans/wallet.transaction.bloc.dart';
import 'package:wallet/scenes/components/bottom.sheets/base.dart';
import 'package:wallet/scenes/components/custom.loading.dart';
import 'package:wallet/scenes/components/custom.loading.with.child.dart';
import 'package:wallet/scenes/components/custom.tooltip.dart';
import 'package:wallet/scenes/components/home/transaction.filter.dart';
import 'package:wallet/scenes/components/textfield.text.dart';
import 'package:wallet/scenes/components/wallet.history.transaction.list.dart';
import 'package:wallet/scenes/home.v3/home.viewmodel.dart';

class TransactionList extends StatelessWidget {
  final HomeViewModel viewModel;

  const TransactionList({
    required this.viewModel,
    super.key,
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
                      color: ProtonColors.backgroundNorm,
                      suffixIcon: const Icon(Icons.close, size: 16),
                      prefixIcon: const Icon(Icons.search, size: 16),
                      suffixIconOnPressed: () {
                        viewModel.setSearchHistoryTextField(show: false);
                      },
                      scrollPadding: EdgeInsets.only(
                          bottom:
                              MediaQuery.of(context).viewInsets.bottom + 100),
                      controller: viewModel.transactionSearchController,
                    )
                  : Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (viewModel.selectedAccountMenuModel != null) {
                                viewModel.coordinator
                                    .showTransactionAddressSwitch(
                                        viewModel.selectedAccountMenuModel!);
                              }
                            },
                            child: Row(children: [
                              Text(
                                S.of(context).transactions,
                                style: ProtonStyles.body1Medium(
                                    color: ProtonColors.textNorm),
                                textAlign: TextAlign.left,
                              ),

                              /// only display address list option in account view
                              if (!viewModel.isWalletView)
                                Icon(Icons.arrow_drop_down,
                                    color: ProtonColors.textNorm, size: 18),
                            ]),
                          ),
                          Row(children: [
                            state.isSyncing
                                ? state.historyTransaction.isEmpty
                                    ? const SizedBox()
                                    : CustomLoadingWithChild(
                                        durationInMilliSeconds: 800,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 3),
                                          child: Icon(
                                            Icons.refresh_rounded,
                                            size: 20,
                                            color: ProtonColors.textWeak,
                                          ),
                                        ),
                                      )
                                : GestureDetector(
                                    onTap: () {
                                      viewModel.walletTransactionBloc
                                          .syncWallet(
                                        forceSync: true,
                                        heightChanged: false,
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 3),
                                      child: Icon(
                                        Icons.refresh_rounded,
                                        size: 20,
                                        color: ProtonColors.textWeak,
                                      ),
                                    ),
                                  ),
                            const SizedBox(width: 4),
                            if (state.historyTransaction.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  HomeModalBottomSheet.show(context,
                                      child: TransactionFilterView(
                                        currentFilterBy:
                                            viewModel.transactionListFilterBy,
                                        updateFilterBy: viewModel
                                            .updateTransactionListFilterBy,
                                      ));
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 5),
                                  child: Assets.images.icon.setupPreference.svg(
                                      fit: BoxFit.fill, width: 16, height: 16),
                                ),
                              ),
                            const SizedBox(width: 4),
                            if (state.historyTransaction.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  viewModel.setSearchHistoryTextField(
                                      show: true);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 5),
                                  child: Assets.images.icon.search.svg(
                                      fit: BoxFit.fill, width: 16, height: 16),
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
              showMoreCallback: viewModel.showMoreTransactionHistory,
              showDetailCallback: viewModel.coordinator.showHistoryDetails,
              selfEmailAddresses: const [],
              filterBy: viewModel.transactionListFilterBy,
              keyWord: viewModel.transactionSearchController.text,
              bitcoinUnit: viewModel.bitcoinUnit,
              displayBalance: viewModel.displayBalance,
            ),
            if (state.historyTransaction.isEmpty)
              state.isSyncing
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CustomLoading(
                          size: 40,
                          strokeWidth: 3,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        CustomTooltip(
                          message: S.of(context).loading_transactions_desc,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  S.of(context).loading_transactions,
                                  style: ProtonStyles.body2Regular(
                                    color: ProtonColors.textWeak,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                                const SizedBox(width: 4),
                                Transform.translate(
                                  offset: const Offset(0, 1),
                                  child: Assets.images.icon.icInfoCircleDark
                                      .svg(
                                          fit: BoxFit.fill,
                                          width: 20,
                                          height: 20),
                                ),
                              ]),
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
                              child: Assets.images.icon.doTransactions.svg(
                                  fit: BoxFit.fill, width: 26, height: 26)),
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                              width: 280,
                              child: Text(
                                S.of(context).start_your_journey,
                                style: ProtonStyles.subheadline(
                                    color: ProtonColors.textNorm),
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
