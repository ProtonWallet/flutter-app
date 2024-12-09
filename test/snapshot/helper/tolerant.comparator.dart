import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class TolerantGoldenFileComparator extends LocalFileComparator {
  TolerantGoldenFileComparator(
    super.testFile,
    this.threshold,
  );

  /// How much the golden image can differ from the test image.
  ///
  /// It is expected to be between 0 and 1. Where 0 is no difference (the same image)
  /// and 1 is the maximum difference (completely different images).
  /// Example: 0.0006 => 0.06%
  ///          0.001 => 0.1%
  ///          0.01 => 1%
  final double threshold;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );

    final passed = result.passed || result.diffPercent <= threshold;
    if (passed) {
      result.dispose();
      return true;
    }

    final error = await generateFailureOutput(result, golden, basedir);
    result.dispose();
    throw FlutterError(error);
  }
}
