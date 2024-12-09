import 'package:flutter_test/flutter_test.dart';

import 'tolerant.comparator.dart';

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
