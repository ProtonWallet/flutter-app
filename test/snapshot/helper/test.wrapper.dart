import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:wallet/constants/fonts.gen.dart';
import 'package:wallet/l10n/generated/locale.dart';

import 'golden.device.dart';

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
        localizations: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeOverrides: const [
          Locale('en', ''),
          ...S.supportedLocales,
        ],
        theme: ThemeData(
          fontFamily: FontFamily.inter,
          brightness: Brightness.light,
          pageTransitionsTheme: const PageTransitionsTheme(builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
          }),
        ),
      ),
      surfaceSize: device.size,
    );

    await screenMatchesGolden(tester, fileName, customPump: (tester) async {
      await tester.pumpAndSettle(const Duration(seconds: 10));
    });
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

/// A wrapper around [testGoldens] that sets the tags to ['snapshot'].
@isTest
void testGolden(String description, ValueGetter<Widget> test) {
  goldenTest(description,
      fileName: "test_file_welcome", builder: test, tags: ['snapshot']);
}
