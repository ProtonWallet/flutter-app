import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/debug/websocket.coordinator.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

abstract class WebSocketViewModel extends ViewModel<WebSocketCoordinator> {
  WebSocketViewModel(super.coordinator);

  late WebSocketChannel channel;
  late TextEditingController textController;
  Future<void> sendMessage();
}

class WebSocketViewModelImpl extends WebSocketViewModel {
  WebSocketViewModelImpl(super.coordinator);

  @override
  void dispose() {
    channel.sink.close();
    textController.dispose();
    super.dispose();
  }

  @override
  Future<void> loadData() async {
    textController = TextEditingController();
    channel = WebSocketChannel.connect(
      Uri.parse('wss://echo.websocket.events'),
    );
  }

  @override
  Future<void> sendMessage() async {
    if (textController.text.isNotEmpty) {
      channel.sink.add(textController.text);
    }
  }

  @override
  Future<void> move(NavID to) async {}
}
