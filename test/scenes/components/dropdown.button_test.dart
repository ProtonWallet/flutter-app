import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/scenes/components/dropdown.button.v1.dart';

List<String> items = ["Option 1", "Banana B", "Cannon 3", "4 for Four"];
final ValueNotifier valueNotifier = ValueNotifier("Banana B");

void main() {
  testWidgets('DropdownButton', (tester) async {
    await tester.pumpWidget(const TempApp());

    // Find dropdown button
    final dropdownButtonFinder = find.byType(DropdownButton);
    expect(dropdownButtonFinder, findsOneWidget);

    // Open the DropdownButton.
    await tester.tap(dropdownButtonFinder);
    await tester.pump();

    // Check the text
    for (String item in items) {
      if (item != valueNotifier.value) {
        expect(find.text(item), findsOneWidget);
      } else {
        expect(find.text(item), findsExactly(2));
      }
      expect(find.text(item.toLowerCase()), findsNothing);
      expect(find.text(item.toUpperCase()), findsNothing);
    }
  });
}

class TempApp extends StatelessWidget {
  const TempApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Material(
            child: DropdownButtonV1(
      width: 400,
      items: items,
      valueNotifier: valueNotifier,
      itemsText: items,
    )));
  }
}
