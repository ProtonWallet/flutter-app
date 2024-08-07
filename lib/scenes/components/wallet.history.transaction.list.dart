import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/history.transaction.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/bitcoin.amount.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/scenes/components/transaction/transaction.listtitle.dart';
import 'package:wallet/theme/theme.font.dart';

typedef ShowDetailCallback = void Function(
  String txid,
  AccountModel accountModel,
);

class WalletHistoryTransactionList extends StatefulWidget {
  final List<HistoryTransaction> transactions;
  final int currentPage;
  final VoidCallback showMoreCallback;
  final ShowDetailCallback showDetailCallback;
  final List<String> selfEmailAddresses;
  final String filter;
  final String keyWord;
  final BitcoinUnit bitcoinUnit;

  const WalletHistoryTransactionList({
    required this.transactions,
    required this.currentPage,
    required this.showMoreCallback,
    required this.showDetailCallback,
    required this.selfEmailAddresses,
    required this.filter,
    required this.keyWord,
    required this.bitcoinUnit,
    super.key,
  });

  @override
  WalletHistoryTransactionListState createState() =>
      WalletHistoryTransactionListState();
}

class WalletHistoryTransactionListState
    extends State<WalletHistoryTransactionList> {
  List<HistoryTransaction> transactionsFiltered = [];

  @override
  void didUpdateWidget(WalletHistoryTransactionList oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      transactionsFiltered = applyHistoryTransactionFilterAndKeyword(
        widget.filter,
        widget.keyWord,
        widget.transactions,
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
                    transactionsFiltered.length,
                    defaultTransactionPerPage * widget.currentPage +
                        defaultTransactionPerPage);
            index++)
          TransactionListTitle(
            width: MediaQuery.of(context).size.width,
            address: CommonHelper.shorterBitcoinAddress(
                WalletManager.getEmailFromWalletTransaction(
                    transactionsFiltered[index].amountInSATS > 0
                        ? transactionsFiltered[index].sender
                        : transactionsFiltered[index].toList,
                    selfEmailAddresses: widget.selfEmailAddresses)),
            bitcoinAmount: BitcoinAmount(
              amountInSatoshi: transactionsFiltered[index].amountInSATS,
              bitcoinUnit: widget.bitcoinUnit,
              exchangeRate: transactionsFiltered[index].exchangeRate,
            ),
            note: transactionsFiltered[index].label ?? "",
            body: transactionsFiltered[index].body ?? "",
            onTap: () {
              widget.showDetailCallback(transactionsFiltered[index].txID,
                  transactionsFiltered[index].accountModel);
            },
            timestamp: transactionsFiltered[index].createTimestamp,
            isSend: transactionsFiltered[index].amountInSATS < 0,
          ),
        if (transactionsFiltered.length >
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

List<HistoryTransaction> applyHistoryTransactionFilterAndKeyword(String filter,
    String keyword, List<HistoryTransaction> historyTransactions) {
  List<HistoryTransaction> newHistoryTransactions = [];
  if (filter.isNotEmpty) {
    if (filter == "receive") {
      newHistoryTransactions =
          historyTransactions.where((t) => t.amountInSATS >= 0).toList();
    } else if (filter == "send") {
      newHistoryTransactions =
          historyTransactions.where((t) => t.amountInSATS < 0).toList();
    }
  } else {
    newHistoryTransactions = historyTransactions;
  }

  if (keyword.isNotEmpty) {
    final lowerCaseKeyword = keyword.toLowerCase();
    newHistoryTransactions = newHistoryTransactions.where((t) {
      if ((t.label ?? "").toLowerCase().contains(lowerCaseKeyword)) {
        return true;
      }
      if (t.sender.toLowerCase().contains(lowerCaseKeyword)) {
        return true;
      }
      if (t.toList.toLowerCase().contains(lowerCaseKeyword)) {
        return true;
      }
      if (t.body != null && t.body!.toLowerCase().contains(lowerCaseKeyword)) {
        return true;
      }
      return false;
    }).toList();
  }
  return newHistoryTransactions;
}
