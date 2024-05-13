import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/rust/api/api2.dart';
import 'package:wallet/scenes/core/view.dart';

import 'transfer.viewmodel.dart';

class TransferView extends ViewBase<TransferViewModel> {
  const TransferView(TransferViewModel viewModel)
      : super(viewModel, const Key("TransferView"));

  @override
  Widget buildWithViewModel(
      BuildContext context, TransferViewModel viewModel, ViewSize viewSize) {
    return Scaffold(
      backgroundColor: ProtonColors.backgroundProton,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("TransferView"),
      ),
      body: Column(
        children: [
          Text("Test Greet Fn: `${greet(name: "World!!!")}`"),
          Text("Test helloworld Fn: `${helloworld()}`"),
          Text("AuthInfo-Code: `${viewModel.testCode}`"),
          Text("WalletsResponse-Code: `${viewModel.testCodeTwo}`")
        ],
      ),
    );
  }
}
