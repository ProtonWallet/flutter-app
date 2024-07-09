//bitcoin.address.list
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/managers/features/models/wallet.list.dart';
import 'package:wallet/managers/features/wallet.list.bloc.dart';
import 'package:wallet/managers/features/wallet.transaction.bloc.dart';
import 'package:wallet/managers/providers/local.bitcoin.address.provider.dart';
import 'package:wallet/scenes/components/custom.loading.with.child.dart';
import 'package:wallet/scenes/components/textfield.text.dart';
import 'package:wallet/scenes/components/wallet.bitcoin.address.list.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/home.v3/bottom.sheet/address.filter.dart';
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
                            showSuffixIcon: true,
                            suffixIconOnPressed: () {
                              viewModel.setSearchAddressTextField(false);
                            },
                            scrollPadding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom +
                                        100),
                            controller: viewModel.addressSearchController,
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
                                      S.of(context).addresses,
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
                                if (state.bitcoinAddresses.isNotEmpty)
                                  Row(children: [
                                    state.isSyncing
                                        ? CustomLoadingWithChild(
                                            durationInMilliSeconds: 800,
                                            child: Padding(
                                              padding: const EdgeInsets.all(3),
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
                                        AddressFilterSheet.show(
                                            context, viewModel);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: SvgPicture.asset(
                                            "assets/images/icon/setup-preference.svg",
                                            fit: BoxFit.fill,
                                            width: 16,
                                            height: 16),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    GestureDetector(
                                      onTap: () {
                                        viewModel
                                            .setSearchAddressTextField(true);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(3),
                                        child: Icon(Icons.search_rounded,
                                            color: ProtonColors.textNorm,
                                            size: 20),
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
                    showMoreCallback: () {
                      viewModel.showMoreAddress();
                    },
                    filter: viewModel.addressListFilterBy,
                    keyWord: viewModel.addressSearchController.text,
                    accountID2Name: accountID2Name,
                  ),
                ]);
              });
        });
  }
}
