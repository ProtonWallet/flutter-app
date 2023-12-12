import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:flutter/services.dart';
import 'package:wallet/scenes/receive/receive.viewmodel.dart';
import 'package:share_plus/share_plus.dart';

class ReceiveView extends ViewBase<ReceiveViewModel> {
  ReceiveView(ReceiveViewModel viewModel)
      : super(viewModel, const Key("ReceiveView"));

  @override
  Widget buildWithViewModel(
      BuildContext context, ReceiveViewModel viewModel, ViewSize viewSize) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Receive"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: QrImageView(
              size: MediaQuery.of(context).size.width,
              data: viewModel.address,
              version: QrVersions.auto,
            ),
          ),
          Text(viewModel.address),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ButtonV5(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: viewModel.address));
                  const snackBar = SnackBar(
                    content: Text('Copied to Clipboard!'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
                text: "Copy",
                width: 100,
                height: 36,
              ),
              const SizedBox(width: 20),
              ButtonV5(
                onPressed: () {
                  Share.share(viewModel.address, subject: "Receive Address");
                },
                text: "Share",
                width: 100,
                height: 36,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
