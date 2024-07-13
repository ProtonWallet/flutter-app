import 'dart:async';

import 'package:wallet/helper/extension/stream.controller.dart';
import 'package:wallet/helper/logger.dart';

abstract class Service<T> {
  final _dataController = StreamController<T>.broadcast();
  Stream<T> get dataStream => _dataController.stream;

  bool _isRunning = false;
  bool _isPaused = false;
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
        await onUpdate().then(_dataController.sinkAddSafe);
      } catch (e, statcktrace) {
        logger.e('Service $runtimeType runTask: $e statcktrac: $statcktrace');
      }

      await Future.delayed(duration);
    }
  }

  void dispose() {
    _dataController.close();
    this.stop();
  }

  Future<T> onUpdate();
}
