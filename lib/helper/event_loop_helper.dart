import 'package:wallet/helper/event_loop.dart';

class EventLoopHelper {
  static final eventLoop = EventLoop();

  static void start() {
    eventLoop.start();
  }

  static Future<void> runOnce() async {
    await eventLoop.runOnce();
  }

  static void stop() {
    eventLoop.stop();
  }
}
