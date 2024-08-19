import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/scenes/components/text.choices.dart';

final TextEditingController textEditingController = TextEditingController();
void main() {
  testWidgets('TextChoices', (tester) async {
    await tester.pumpWidget(const TempApp());
    expect(find.text("SAT"), findsOneWidget);
    expect(find.text("BTC"), findsOneWidget);
    expect(find.text("ETH"), findsOneWidget);
    expect(find.text("SOL"), findsOneWidget);
    expect(find.text("LTC"), findsOneWidget);

    expect(find.text("sat"), findsNothing);
    expect(find.text("btc"), findsNothing);
    expect(find.text("eth"), findsNothing);
    expect(find.text("sol"), findsNothing);
    expect(find.text("ltc"), findsNothing);

    await tester.tap(find.text("BTC"));
    await tester.pump();
    expect(textEditingController.text, equals("BTC"));

    await tester.tap(find.text("LTC"));
    await tester.pump();
    expect(textEditingController.text, equals("LTC"));

    await tester.tap(find.text("SAT"));
    await tester.pump();
    expect(textEditingController.text, equals("SAT"));
  });
}

class TempApp extends StatelessWidget {
  const TempApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: TextChoices(
      choices: const ["SAT", "BTC", "ETH", "SOL", "LTC"],
      selectedValue: "SAT",
      controller: textEditingController
    ));
  }
}
