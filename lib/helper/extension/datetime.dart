/// An extension on [DateTime] to get the Unix timestamp in seconds.
extension UnixTimestampExtension on DateTime {
  /// Returns the number of whole seconds since the Unix epoch (January 1, 1970).
  int secondsSinceEpoch() {
    return millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond;
  }
}
