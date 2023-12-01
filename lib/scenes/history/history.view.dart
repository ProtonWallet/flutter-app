import 'package:flutter/material.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/history/history.viewmodel.dart';

class HistoryView extends ViewBase<HistoryViewModel> {
  HistoryView(HistoryViewModel viewModel)
      : super(viewModel, const Key("HistoryView"));

  @override
  Widget buildWithViewModel(
      BuildContext context, HistoryViewModel viewModel, ViewSize viewSize) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Payment History"),
      ),
      body: Center(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: viewModel.updateStringValue,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6D4AFF), elevation: 0),
                child: Text(
                  "Create Wallet".toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                viewModel.mnemonicString,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ]),
      ),
    );
  }
}
