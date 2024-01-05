import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallet/components/transaction/transaction.listtitle.dart';
import 'package:wallet/helper/currency_helper.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/history/history.viewmodel.dart';
import 'package:wallet/theme/theme.font.dart';

class HistoryView extends ViewBase<HistoryViewModel> {
  HistoryView(HistoryViewModel viewModel)
      : super(viewModel, const Key("HistoryView"));

  Future<void> goDetails(BuildContext context) async {
    viewModel.coordinator.move(ViewIdentifiers.historyDetails, context);
  }

  @override
  Widget buildWithViewModel(
      BuildContext context, HistoryViewModel viewModel, ViewSize viewSize) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
          statusBarBrightness: Brightness.light, // For iOS (dark icons)
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        title: const Text("Transactions"),
        scrolledUnderElevation:
        0.0, // don't change background color when scroll down
      ),
      body: viewModel.hasHistory()
          ? buildHistory(context, viewModel, viewSize)
          : buildNoHistory(context, viewModel, viewSize),
    );
  }

  Widget buildNoHistory(
      BuildContext context, HistoryViewModel viewModel, ViewSize viewSize) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                "No data",
                style: FontManager.titleHeadline(
                    Theme.of(context).colorScheme.primary),
              ),
            ]));
  }

  Widget buildHistory(
      BuildContext context, HistoryViewModel viewModel, ViewSize viewSize) {
    return ListView.builder(
        itemCount: viewModel.history.length,
        itemBuilder: (context, index) {
          return TransactionListTitle(
            width: MediaQuery.of(context).size.width - 80,
            address: viewModel.history[index].txid.substring(0, 10) +
                "***" +
                viewModel.history[index].txid.substring(64 - 6),
            coin: "Sat",
            amount: (viewModel.getAmount(index)).toDouble(),
            notional: CurrencyHelper.sat2usdt(
                (viewModel.getAmount(index)).abs().toDouble()),
            isSend: viewModel.history[index].sent >
                viewModel.history[index].received,
            timestamp: viewModel.history[index].confirmationTime!.timestamp,
            onTap: () {
              viewModel.selectedTXID = viewModel.history[index].txid;
              goDetails(context);
            },
          );
        });
  }
}
