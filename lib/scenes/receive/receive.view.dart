import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/receive/receive.viewmodel.dart';

class ReceiveView extends ViewBase<ReceiveViewModel> {
  ReceiveView(ReceiveViewModel viewModel)
      : super(viewModel, const Key("ReceiveView"));

  @override
  Widget buildWithViewModel(
      BuildContext context, ReceiveViewModel viewModel, ViewSize viewSize) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("ReceiveView"),
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40.0),
            child: QrImageView(
              size: MediaQuery.of(context).size.width * 0.8,
              data: 'sdlfkjsklkljsdklfjskldjflksdjfklsdjfklsdjf',
              version: QrVersions.auto,
            ),
          )
        ],
      ),
    );
  }
}
