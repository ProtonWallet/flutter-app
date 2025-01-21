import 'dart:async';

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:wallet/constants/fonts.gen.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/welcome/welcome.view.dart';

import '../../mocks/welcome.mocks.dart';
import '../helper/alchemist.device.dart';
import '../helper/alchemist.device.scenario.dart';
import '../helper/comparator.config.dart';

void main() {
  group('MyApp Golden Test', () {
    Widget buildMyApp() {
      final viewModel = MockWelcomeViewModel();
      when(viewModel.keepAlive).thenAnswer((_) => true);
      when(viewModel.isLoginToHomepage).thenAnswer((_) => false);
      when(viewModel.screenSizeState).thenAnswer((_) => false);
      when(viewModel.coordinator).thenAnswer((_) => MockWelcomeCoordinator());
      when(viewModel.datasourceChanged).thenAnswer(
        (_) => StreamController<MockWelcomeViewModel>.broadcast().stream,
      );
      when(viewModel.currentSize).thenAnswer((_) => ViewSize.mobile);

      final widget = WelcomeView(
        viewModel,
      );

      final app = MaterialApp(
        home: widget,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
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
      );
      return app;
    }

    final devices = Device.all;

    goldenTest('normal welcome view',
        fileName: 'welcome/welcome', tags: ['snapshot'], builder: () {
      setGoldenFileComparatorWithThreshold(0.0001);

      final children = <Widget>[];
      for (final device in devices) {
        children.add(GoldenTestDeviceScenario(
          name: device.name,
          device: device,
          builder: buildMyApp,
        ));
      }

      return GoldenTestGroup(
        columns: devices.length,
        children: children,
      );
    });
  });
}
