import 'package:test/test.dart';
import 'package:wallet/helper/extension/datetime.dart';

import '../../helper.dart';

void main() {
  testUnit('Epoch time should return 0', () {
    final epoch = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    expect(epoch.secondsSinceEpoch(), equals(0));
  });

  testUnit('A known timestamp should return the correct seconds', () {
    // For example, July 20, 1969, 20:17:40 UTC (Apollo 11 landing moment)
    // Unix timestamp (in seconds): -14182940
    // This date is before Unix epoch, so it's negative.
    final knownDate = DateTime.utc(1969, 7, 20, 20, 17, 40);
    expect(knownDate.secondsSinceEpoch(), equals(-14182940));
  });

  testUnit('Recent date should return a positive value', () {
    // For a recent timestamp, let's pick a random date:
    // January 1, 2020 00:00:00 UTC → 1577836800 seconds since epoch
    final recentDate = DateTime.utc(2020);
    expect(recentDate.secondsSinceEpoch(), equals(1577836800));
  });

  testUnit('Round-trip conversion from seconds to DateTime', () {
    // Take a given number of seconds, convert to DateTime, and back.
    const originalSeconds = 1672531200; // Example: Jan 1, 2023 UTC
    final date = DateTime.fromMillisecondsSinceEpoch(originalSeconds * 1000,
        isUtc: true);
    expect(date.secondsSinceEpoch(), equals(originalSeconds));
  });
}
