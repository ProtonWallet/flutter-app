extension DateTimeExtension on DateTime {
  int secondsSinceEpoch() {
    return DateTime.now().millisecondsSinceEpoch ~/
        Duration.millisecondsPerSecond;
  }
}
