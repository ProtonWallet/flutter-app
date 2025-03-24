import 'package:flutter_test/flutter_test.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'tolerant.comparator.dart';

/// How much the golden image can differ from the test image.
///
/// It is expected to be between 0 and 1. Where 0 is no difference (the same image)
/// and 1 is the maximum difference (completely different images).
/// Example: 0.0006 => 0.06%
///          0.001 => 0.1%
///          0.01 => 1%
@isTest
void setGoldenFileComparatorWithThreshold(double threshold) {
  final previousGoldenFileComparator = goldenFileComparator;

  if (previousGoldenFileComparator is LocalFileComparator) {
    final testUrl = (goldenFileComparator as LocalFileComparator).basedir;
    final previousGoldenFileComparator = goldenFileComparator;
    goldenFileComparator = TolerantGoldenFileComparator(
      Uri.parse('$testUrl/test_with_threshold.dart'),
      threshold,
    );

    addTearDown(() => goldenFileComparator = previousGoldenFileComparator);
  } else {
    throw Exception(
      'Expected `goldenFileComparator` to be of type `LocalFileComparator`, '
      'but it is of type `${goldenFileComparator.runtimeType}`',
    );
  }
}
