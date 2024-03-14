import 'package:flutter/cupertino.dart';
import 'package:wallet/helper/event_loop.dart';

class EventLoopHelper {
  static final eventLoop = EventLoop();

  static void start() {
    eventLoop.start();
  }

  static void runOnce() {
    eventLoop.runOnce();
  }

  static void stop() {
    eventLoop.stop();
  }
}
