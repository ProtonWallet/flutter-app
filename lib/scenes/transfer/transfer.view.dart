import 'package:flutter/material.dart';
import 'package:wallet/scenes/core/view.dart';

import 'transfer.viewmodel.dart';

class TransferView extends ViewBase<TransferViewModel> {
  TransferView(TransferViewModel viewModel)
      : super(viewModel, const Key("TransferView"));

  @override
  Widget buildWithViewModel(
      BuildContext context, TransferViewModel viewModel, ViewSize viewSize) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("TransferView"),
      ),
      body: const Text("TransferView"),
    );
  }
}
