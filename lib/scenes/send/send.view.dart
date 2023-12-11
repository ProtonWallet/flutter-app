import 'package:flutter/material.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/send/send.viewmodel.dart';

class SendView extends ViewBase<SendViewModel> {
  SendView(SendViewModel viewModel) : super(viewModel, const Key("SendView"));

  @override
  Widget buildWithViewModel(
      BuildContext context, SendViewModel viewModel, ViewSize viewSize) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("SendView"),
      ),
      body: const Text("SendView"),
    );
  }
}
