import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/button.v6.dart';
import 'package:wallet/scenes/components/close.button.v1.dart';
import 'package:wallet/scenes/components/custom.header.dart';
import 'package:wallet/scenes/components/custom.loading.dart';
import 'package:wallet/scenes/components/page.layout.v1.dart';
import 'package:wallet/scenes/components/textfield.text.dart';
import 'package:wallet/scenes/components/wallet.bitcoin.address.list.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/home.v3/sub.views/wallet.account.address.list/wallet.account.address.list.viewmodel.dart';

class WalletAccountAddressListView
    extends ViewBase<WalletAccountAddressListViewModel> {
  const WalletAccountAddressListView(
      WalletAccountAddressListViewModel viewModel)
      : super(viewModel, const Key("WalletAccountAddressListView"));

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return PageLayoutV1(
        headerWidget: CustomHeader(
          title: viewModel.addressListType == AddressListType.receiveAddress
              ? S.of(context).receive_addresses
              : S.of(context).change_addresses,
          buttonDirection: AxisDirection.left,
          padding: const EdgeInsets.all(0.0),
          button: CloseButtonV1(
              backgroundColor: ProtonColors.backgroundNorm,
              onPressed: () {
                Navigator.of(context).pop();
              }),
        ),
        backgroundColor: ProtonColors.white,
        child: Transform.translate(
          offset: const Offset(0, -10),
          child: Column(children: [
            ButtonV6(
              text: viewModel.addressListType == AddressListType.receiveAddress
                  ? S.of(context).view_change_addresses
                  : S.of(context).view_receive_addresses,
              width: min(MediaQuery.of(context).size.width, 260),
              enable: viewModel.initialized && !viewModel.loadingAddress,
              height: 48,
              backgroundColor: ProtonColors.protonBlue,
              textStyle: ProtonStyles.body1Medium(
                color: ProtonColors.textInverted,
              ),
              onPressed: () async {
                viewModel.updateAddressListType();
              },
            ),
            const SizedBox(
              height: 10,
            ),
            TextFieldText(
              borderRadius: 20,
              width: MediaQuery.of(context).size.width,
              height: 50,
              color: ProtonColors.backgroundNorm,
              prefixIcon: const Icon(Icons.search, size: 16),
              showSuffixIcon: false,
              scrollPadding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 100),
              controller: viewModel.searchTextEditingController,
            ),
            if (!viewModel.loadingAddress || viewModel.initialized)
              WalletBitcoinAddressList(
                addresses: viewModel.searchTextEditingController.text.isNotEmpty
                    ? viewModel.searchedAddress != null
                        ? [viewModel.searchedAddress!]
                        : []
                    : viewModel.addressListType ==
                            AddressListType.receiveAddress
                        ? viewModel.receiveAddresses
                        : viewModel.changeAddresses,
                addressesInPool: viewModel.addressesInPool,
                exchangeRate: viewModel.exchangeRate,
                showTransactionDetailCallback: viewModel.showTransactionDetail,
                showAddressQRcodeCallback: viewModel.showAddressQRcode,
              ),
            if (viewModel.loadingAddress)
              const Align(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 10,
                  ),
                  child: CustomLoading(
                    size: 28,
                  ),
                ),
              ),
            if (!viewModel.loadingAddress &&
                viewModel.searchTextEditingController.text.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                ),
                child: GestureDetector(
                  onTap: viewModel.showMoreCallback,
                  child: Container(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      S.of(context).show_more,
                      style: ProtonStyles.body1Regular(
                          color: ProtonColors.protonBlue),
                    ),
                  ),
                ),
              ),
          ]),
        ),
      );
    });
  }
}
