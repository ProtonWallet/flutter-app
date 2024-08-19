import 'package:flutter_test/flutter_test.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

/// A wrapper around [testWidgets] that sets the tags to ['ui'].
@isTest
void testUI(String description, WidgetTesterCallback callback) {
  testWidgets(description, callback, tags: ['ui']);
}

/// A wrapper around [test] that sets the tags to ['unit'].
@isTest
void testUnit(
  Object description,
  dynamic Function() body,
) {
  test(description, body, tags: ['unit']);
}
