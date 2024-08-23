import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/managers/providers/mock/mock.price.graph.data.provider.dart';
import 'package:wallet/scenes/components/bitcoin.price.chart.dart';

void main() {
  testWidgets('BitcoinPriceChart', (tester) async {
    await tester.pumpWidget(const TempApp());
    await tester.pumpAndSettle(const Duration(milliseconds: 200));

    // Find dropdown button
    final widgetFinder = find.byType(BitcoinPriceChart);
    expect(widgetFinder, findsOneWidget);

    /// default in 1D chart view
    expect(find.text("BTC price"), findsOneWidget);
    expect(find.text("1D"), findsOneWidget);
    expect(find.text("7D"), findsOneWidget);
    expect(find.text("1M"), findsOneWidget);
    expect(find.byType(AnimatedFlipCounter), findsExactly(2));
    expect(find.text("600000"), findsOneWidget); // lowest price
    expect(find.text("670000"), findsOneWidget); // highest price

    await tester.tap(find.text("7D"));
    await tester.pumpAndSettle(const Duration(milliseconds: 200));
    expect(find.text("BTC price"), findsOneWidget);
    expect(find.text("1D"), findsOneWidget);
    expect(find.text("7D"), findsOneWidget);
    expect(find.text("1M"), findsOneWidget);
    expect(find.byType(AnimatedFlipCounter), findsExactly(2));
    expect(find.text("1610000"), findsOneWidget); // lowest price
    expect(find.text("1700000"), findsOneWidget); // highest price


    await tester.tap(find.text("1M"));
    await tester.pumpAndSettle(const Duration(milliseconds: 200));
    expect(find.text("BTC price"), findsOneWidget);
    expect(find.text("1D"), findsOneWidget);
    expect(find.text("7D"), findsOneWidget);
    expect(find.text("1M"), findsOneWidget);
    expect(find.byType(AnimatedFlipCounter), findsExactly(2));
    expect(find.text("2600000"), findsOneWidget); // lowest price
    expect(find.text("2670000"), findsOneWidget); // highest price

    // Open the DropdownButton.
    await tester.tap(widgetFinder);
    await tester.pump();
  });
}

class TempApp extends StatelessWidget {
  const TempApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: Material(
        child: BitcoinPriceChart(
          exchangeRate: defaultExchangeRate,
          priceGraphDataProvider: MockPriceGraphDataProvider(),
        ),
      ),
    );
  }
}
