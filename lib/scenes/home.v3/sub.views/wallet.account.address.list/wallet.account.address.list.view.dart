import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/extension/build.context.extension.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/btc.address/wallet.bitcoin.address.list.dart';
import 'package:wallet/scenes/components/button.v6.dart';
import 'package:wallet/scenes/components/custom.loading.dart';
import 'package:wallet/scenes/components/page.layout.v2.dart';
import 'package:wallet/scenes/components/textfield.text.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/home.v3/sub.views/wallet.account.address.list/wallet.account.address.list.viewmodel.dart';

class WalletAccountAddressListView
    extends ViewBase<WalletAccountAddressListViewModel> {
  const WalletAccountAddressListView(
      WalletAccountAddressListViewModel viewModel)
      : super(viewModel, const Key("WalletAccountAddressListView"));

  @override
  Widget build(BuildContext context) {
    return PageLayoutV2(
      title: viewModel.addressListType == AddressListType.receiveAddress
          ? S.of(context).receive_addresses
          : S.of(context).change_addresses,
      titleStyle: ProtonStyles.headline(color: ProtonColors.textNorm),
      child: Transform.translate(
        offset: const Offset(0, 12),
        child: Column(children: [
          /// switch between receive and change addresses
          ButtonV6(
            text: viewModel.addressListType == AddressListType.receiveAddress
                ? S.of(context).view_change_addresses
                : S.of(context).view_receive_addresses,
            width: min(context.width, 260),
            enable: viewModel.initialized && !viewModel.loadingAddress,
            height: 55,
            backgroundColor: ProtonColors.protonBlue,
            textStyle: ProtonStyles.body1Medium(
              color: ProtonColors.textInverted,
            ),
            onPressed: () async {
              viewModel.updateAddressListType();
            },
          ),
          const SizedBox(height: 12),
          TextFieldText(
            borderRadius: 16,
            width: MediaQuery.of(context).size.width,
            height: 50,
            color: ProtonColors.backgroundNorm,
            prefixIcon: const Icon(Icons.search, size: 16),
            showSuffixIcon: false,
            scrollPadding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 100),
            controller: viewModel.searchTextEditingController,
          ),
          const SizedBox(height: 12),
          if (!viewModel.loadingAddress || viewModel.initialized)
            WalletBitcoinAddressList(
              addresses: viewModel.searchTextEditingController.text.isNotEmpty
                  ? viewModel.searchedAddress != null
                      ? [viewModel.searchedAddress!]
                      : []
                  : viewModel.addressListType == AddressListType.receiveAddress
                      ? viewModel.receiveAddresses
                      : viewModel.changeAddresses,
              addressesInPool: viewModel.addressesInPool,
              exchangeRate: viewModel.exchangeRate,
              showTransactionDetailCallback: viewModel.showTransactionDetail,
              showAddressQRcodeCallback: viewModel.showAddressQRcode,
              onSigningCallback: viewModel.showSigningTool,
              showMessageSigner: viewModel.showMessageSigner,
            ),
          if (viewModel.loadingAddress)
            const Align(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: CustomLoading(size: 28),
              ),
            ),
          if (!viewModel.loadingAddress &&
              viewModel.searchTextEditingController.text.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: GestureDetector(
                onTap: viewModel.showMoreCallback,
                child: Container(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    S.of(context).show_more,
                    style: ProtonStyles.body1Regular(
                      color: ProtonColors.protonBlue,
                    ),
                  ),
                ),
              ),
            ),

          ///
          const SizedBox(height: 12),
        ]),
      ),
    );
  }
}
