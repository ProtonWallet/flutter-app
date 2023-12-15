import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

abstract class WebSocketViewModel extends ViewModel {
  WebSocketViewModel(super.coordinator);

  late WebSocketChannel channel;
  late TextEditingController textController;
  Future<void> sendMessage();
}

class WebSocketViewModelImpl extends WebSocketViewModel {
  WebSocketViewModelImpl(super.coordinator);
  final datasourceChangedStreamController =
      StreamController<WebSocketViewModel>.broadcast();
  @override
  void dispose() {
    channel.sink.close();
    textController.dispose();
    datasourceChangedStreamController.close();
  }

  @override
  Future<void> loadData() async {
    textController = TextEditingController();
    channel = WebSocketChannel.connect(
      Uri.parse('wss://echo.websocket.events'),
    );
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  @override
  Future<void> sendMessage() async {
    if (textController.text.isNotEmpty) {
      channel.sink.add(textController.text);
    }
  }
}
