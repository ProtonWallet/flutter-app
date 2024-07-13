import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/managers/providers/local.bitcoin.address.provider.dart';
import 'package:wallet/scenes/components/bitcoin.address.info.box.dart';
import 'package:wallet/theme/theme.font.dart';

typedef ShowTransactionDetailCallback = void Function(
  String txid,
  String accountID,
);

class WalletBitcoinAddressList extends StatefulWidget {
  final List<BitcoinAddressDetail> addresses;
  final int currentPage;
  final ShowTransactionDetailCallback showTransactionDetailCallback;
  final VoidCallback showMoreCallback;
  final String filter;
  final String keyWord;
  final Map<String, String> accountID2Name;

  const WalletBitcoinAddressList({
    required this.addresses,
    required this.currentPage,
    required this.showTransactionDetailCallback,
    required this.showMoreCallback,
    required this.filter,
    required this.keyWord,
    required this.accountID2Name,
    super.key,
  });

  @override
  WalletBitcoinAddressListState createState() =>
      WalletBitcoinAddressListState();
}

class WalletBitcoinAddressListState extends State<WalletBitcoinAddressList> {
  List<BitcoinAddressDetail> addressesFiltered = [];

  @override
  void didUpdateWidget(WalletBitcoinAddressList oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      addressesFiltered = applyBitcoinAddressDetailFilterAndKeyword(
        widget.filter,
        widget.keyWord,
        widget.addresses,
      );
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int index = 0;
            index <
                min(
                    addressesFiltered.length,
                    defaultTransactionPerPage * widget.currentPage +
                        defaultTransactionPerPage);
            index++)
          BitcoinAddressInfoBox(
              bitcoinAddressDetail: addressesFiltered[index],
              accountName:
                  widget.accountID2Name[addressesFiltered[index].accountID] ??
                      addressesFiltered[index].accountID,
              showTransactionDetailCallback:
                  widget.showTransactionDetailCallback),
        if (addressesFiltered.length >
            defaultTransactionPerPage * widget.currentPage +
                defaultTransactionPerPage)
          GestureDetector(
              onTap: () {
                widget.showMoreCallback.call();
              },
              child: Container(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(S.of(context).show_more,
                      style:
                          FontManager.body1Regular(ProtonColors.protonBlue)))),
      ],
    );
  }
}

List<BitcoinAddressDetail> applyBitcoinAddressDetailFilterAndKeyword(
  String filter,
  String keyword,
  List<BitcoinAddressDetail> addresses,
) {
  List<BitcoinAddressDetail> newAddresses = [];
  if (filter.isNotEmpty) {
    if (filter == "used") {
      newAddresses =
          addresses.where((t) => t.bitcoinAddressModel.used == 1).toList();
    } else if (filter == "unused") {
      newAddresses =
          addresses.where((t) => t.bitcoinAddressModel.used == 0).toList();
    }
  } else {
    newAddresses = addresses;
  }

  if (keyword.isNotEmpty) {
    final lowerCaseKeyword = keyword.toLowerCase();
    newAddresses = newAddresses.where((t) {
      if (t.bitcoinAddressModel.bitcoinAddress
          .toLowerCase()
          .contains(lowerCaseKeyword)) {
        return true;
      }
      return false;
    }).toList();
  }
  return newAddresses;
}
