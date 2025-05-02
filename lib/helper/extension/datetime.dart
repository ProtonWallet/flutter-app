import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// An extension on [DateTime] to get the Unix timestamp in seconds.
extension UnixTimestampExtension on DateTime {
  /// Returns the number of whole seconds since the Unix epoch (January 1, 1970).
  int secondsSinceEpoch() {
    return millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond;
  }
}

extension DateTimeExtension on DateTime {
  String toLocaleFormatYMD(BuildContext context) {
    return DateFormat.yMd(Localizations.localeOf(context).toString())
        .format(this);
  }
}

const int thirtyDaysInMilliseconds =
    30 * 24 * 60 * 60 * 1000; // 30 days in milliseconds
const int thirtyDaysInSeconds = 30 * 24 * 60 * 60; // 30 days in seconds
