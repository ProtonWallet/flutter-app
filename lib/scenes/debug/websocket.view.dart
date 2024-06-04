import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/debug/websocket.viewmodel.dart';

class WebSocketView extends ViewBase<WebSocketViewModel> {
  const WebSocketView(WebSocketViewModel viewModel)
      : super(viewModel, const Key("WebSocketView"));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProtonColors.backgroundProton,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("WebSocketView"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              child: TextFormField(
                controller: viewModel.textController,
                decoration: const InputDecoration(labelText: 'Send a message'),
              ),
            ),
            const SizedBox(height: 24),
            StreamBuilder(
              stream: viewModel.channel.stream,
              builder: (context, snapshot) {
                return Text(snapshot.hasData ? '${snapshot.data}' : '');
              },
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: viewModel.sendMessage,
        tooltip: 'Send message',
        child: const Icon(Icons.send),
      ), // This trailing comma makes auto
    );
  }
}
