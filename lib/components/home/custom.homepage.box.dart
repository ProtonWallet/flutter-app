import 'package:flutter/material.dart';

class CustomHomePageBox extends StatelessWidget {
  final List<Widget> children;

  const CustomHomePageBox({
    super.key,
    this.children = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Expanded(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: children,
            ),
            const SizedBox(
              height: 4,
            ),
          ],
        ),
      ),
    ]);
  }
}
