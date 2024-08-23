import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:wallet/constants/fonts.gen.dart';

import 'device.dart';

@isTest
Future<void> testAcrossAllDevices(
  WidgetTester tester,
  Widget Function() buildWidget,
  String testName,
) async {
  for (final device in devicesWithDifferentTextScales) {
    final fileName = '${testName}_${device.name}';
    await tester.pumpWidgetBuilder(
      buildWidget(),
      wrapper: materialAppWrapper(
        theme: ThemeData(
          fontFamily: FontFamily.inter,
          brightness: Brightness.light,
        ),
      ),
      surfaceSize: device.size,
    );
    await screenMatchesGolden(tester, fileName);
  }
}

/// A wrapper around [testGoldens] that sets the tags to ['snapshot'].
@isTest
void testSnapshot(
  String description,
  Future<void> Function(WidgetTester) test, {
  bool? skip,
}) {
  testGoldens(description, test, skip: skip, tags: ['snapshot']);
}
