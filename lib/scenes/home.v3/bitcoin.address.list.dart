//bitcoin.address.list
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/managers/features/wallet.list.bloc.dart';
import 'package:wallet/managers/features/wallet.list/wallet.list.bloc.state.dart';
import 'package:wallet/managers/features/wallet.list/wallet.list.dart';
import 'package:wallet/managers/features/wallet.transaction.bloc.dart';
import 'package:wallet/scenes/components/custom.loading.with.child.dart';
import 'package:wallet/scenes/components/textfield.text.dart';
import 'package:wallet/scenes/components/wallet.bitcoin.address.list.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/home.v3/bottom.sheet/address.filter.dart';
import 'package:wallet/scenes/home.v3/home.viewmodel.dart';
import 'package:wallet/theme/theme.font.dart';

class BitcoinAddressList extends StatelessWidget {
  final HomeViewModel viewModel;

  const BitcoinAddressList({
    required this.viewModel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletListBloc, WalletListState>(
        bloc: viewModel.walletListBloc,
        builder: (context, state) {
          final Map<String, String> accountID2Name = {};
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
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: defaultPadding),
                    child: viewModel.showSearchAddressTextField
                        ? TextFieldText(
                            borderRadius: 20,
                            width: MediaQuery.of(context).size.width,
                            height: 50,
                            color: ProtonColors.backgroundSecondary,
                            suffixIcon: const Icon(Icons.close, size: 16),
                            prefixIcon: const Icon(Icons.search, size: 16),
                            suffixIconOnPressed: () {
                              viewModel.setSearchAddressTextField(show: false);
                            },
                            scrollPadding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom +
                                        100),
                            controller: viewModel.addressSearchController,
                          )
                        : Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onLongPress: () {
                                    viewModel.updateBodyListStatus(
                                        BodyListStatus.transactionList);
                                  },
                                  // onTap: () {
                                  //   TransactionBitcoinAddressSwitchSheet.show(
                                  //     context,
                                  //     viewModel,
                                  //   );
                                  // },
                                  child: Row(children: [
                                    Text(
                                      S.of(context).addresses,
                                      style: FontManager.body1Median(
                                          ProtonColors.textNorm),
                                      textAlign: TextAlign.left,
                                    ),
                                    // Icon(
                                    //   Icons.keyboard_arrow_down_outlined,
                                    //   size: 18,
                                    //   color: ProtonColors.textWeak,
                                    // ),
                                  ]),
                                ),
                                Row(children: [
                                  state.isSyncing
                                      ? state.bitcoinAddresses.isEmpty
                                          ? const SizedBox()
                                          : CustomLoadingWithChild(
                                              durationInMilliSeconds: 800,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 3),
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
                                  if (state.bitcoinAddresses.isNotEmpty)
                                    GestureDetector(
                                      onTap: () {
                                        AddressFilterSheet.show(
                                            context, viewModel);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 5),
                                        child: Assets
                                            .images.icon.setupPreference
                                            .svg(
                                                fit: BoxFit.fill,
                                                width: 16,
                                                height: 16),
                                      ),
                                    ),
                                  const SizedBox(width: 4),
                                  if (state.bitcoinAddresses.isNotEmpty)
                                    GestureDetector(
                                      onTap: () {
                                        viewModel.setSearchAddressTextField(
                                            show: true);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 5),
                                        child: Assets.images.icon.search.svg(
                                            fit: BoxFit.fill,
                                            width: 16,
                                            height: 16),
                                      ),
                                    ),
                                  const SizedBox(width: 4),
                                ]),
                              ],
                            )),
                  ),
                  WalletBitcoinAddressList(
                    addresses: state.bitcoinAddresses,
                    currentPage: viewModel.currentAddressPage,
                    showTransactionDetailCallback: ((txID, accountID) async {
                      viewModel.selectedTXID = txID;
                      viewModel.historyAccountModel =
                          await DBHelper.accountDao!.findByServerID(accountID);
                      viewModel.move(NavID.historyDetails);
                    }),
                    showMoreCallback: viewModel.showMoreAddress,
                    filter: viewModel.addressListFilterBy,
                    keyWord: viewModel.addressSearchController.text,
                    accountID2Name: accountID2Name,
                  ),
                ]);
              });
        });
  }
}
