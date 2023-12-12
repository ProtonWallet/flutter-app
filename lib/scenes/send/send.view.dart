import 'package:flutter/material.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/helper/logger.dart';
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
        title: const Text("Send"),
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              children: [
                const Text("From:"),
                TextField(
                  controller: viewModel.textController,
                  enabled: false,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Your address',
                  ),
                ),
                const Text("To Recipient:"),
                TextField(
                  controller: viewModel.recipientTextController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Recipient ...',
                  ),
                ),
                const Text("Amount:  300 sats   xxx USD"),
                const Text("Est Fees:  141 sats"),
                const Text("Total: 441 sats "),
                const Text("Notes: this is test net transaction"),
                const SizedBox(
                  height: 20,
                ),
                ButtonV5(
                  text: "Send",
                  width: 200,
                  height: 36,
                  onPressed: () async {
                    await viewModel.sendCoin();
                    viewModel.coordinator.end();
                    Navigator.of(context).popUntil((route) {
                      logger.d(route.settings.name);
                      if (route.settings.name == null) {
                        return false;
                      }
                      return route.settings.name == "[<'HomeNavigationView'>]";
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
