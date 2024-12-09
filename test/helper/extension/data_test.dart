import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/helper/extension/data.dart';

import '../../helper.dart';

void main() {
  testUnit('Empty list should return empty string', () {
    final bytes = <int>[];
    final result = bytes.toBase64();
    expect(result, equals(''));
  });

  testUnit('Encoding ASCII text', () {
    final input = 'Hello World';
    final bytes = input.codeUnits;
    final result = bytes.toBase64();

    // 'Hello World' in Base64 is 'SGVsbG8gV29ybGQ='
    expect(result, equals('SGVsbG8gV29ybGQ='));
  });

  testUnit('Encoding binary data', () {
    // Example bytes: [0x00, 0xFF, 0x10, 0x20]
    final bytes = [0x00, 0xFF, 0x10, 0x20];
    final result = bytes.toBase64();

    // To verify this, we can use an online encoder, or a manual check:
    // Using Dart: base64Encode([0x00, 0xFF, 0x10, 0x20]) gives 'AP8QIA=='
    expect(result, equals('AP8QIA=='));
  });
}
