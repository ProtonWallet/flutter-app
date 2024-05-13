import 'dart:async';

import 'package:wallet/helper/logger.dart';

extension SafeStreamController<T> on StreamController<T> {
  void addSafe(T event) {
    if (!isClosed) {
      add(event);
    } else {
      logger.i("StreamController<$T> is closed, cannot add event of type $T.");
    }
  }

  void sinkAddSafe(T event) {
    if (!isClosed) {
      sink.add(event);
    } else {
      logger.i(
          "StreamController<$T> is closed, cannot add sink event of type $T.");
    }
  }
}
