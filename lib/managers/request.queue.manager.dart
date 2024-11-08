import 'dart:math';

import 'package:wallet/helper/exceptions.dart';
import 'package:wallet/rust/api/errors.dart';

Future<T> retry<T>(
  Future<T> Function() action, {
  int retries = 2,
  Duration delay = const Duration(seconds: 2),
  double backoffFactor = 2.0,
  Duration maxDelay = const Duration(seconds: 30),
}) async {
  int attempt = 0;
  Duration currentDelay = delay;

  while (true) {
    try {
      return await action();
    } on BridgeError catch (e) {
      if (ifMuonClientError(e)) {
        attempt++;
        if (attempt >= retries) {
          rethrow;
        }
        await Future.delayed(currentDelay);
        currentDelay = Duration(
          milliseconds: min(
            (currentDelay.inMilliseconds * backoffFactor).toInt(),
            maxDelay.inMilliseconds,
          ),
        );
      } else {
        rethrow;
      }
    } catch (e) {
      rethrow;
    }
  }
}
