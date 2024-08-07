import 'dart:async';

import 'package:sentry/sentry.dart';
import 'package:wallet/helper/logger.dart';

abstract class Service {
  bool _isRunning = false;
  bool _isPaused = false;
  bool onUpdateing = false;
  bool checkRecovery = false;
  Duration duration;

  Service({required this.duration});

  void updateDuration(Duration duration) {
    this.duration = duration;
  }

  void start() {
    if (_isRunning) return;
    _isRunning = true;
    _isPaused = false;
    _runTasks();
  }

  void pause() {
    if (!_isRunning || _isPaused) return;
    _isPaused = true;
  }

  void stop() {
    if (!_isRunning) return;
    _isRunning = false;
    _isPaused = false;
  }

  Future<void> _runTasks() async {
    while (_isRunning && !_isPaused) {
      try {
        duration = await onUpdate() ?? duration;
        onUpdateing = false;
      } catch (e, statcktrace) {
        /// Log error and continue
        logger.e('Service $runtimeType runTask: $e statcktrac: $statcktrace');
        Sentry.captureException(e, stackTrace: statcktrace);
        onUpdateing = false;
      }
      await Future.delayed(duration);
    }
  }

  Future<Duration?> onUpdate();
}
