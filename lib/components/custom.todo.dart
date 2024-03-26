import 'package:flutter/material.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/theme/theme.font.dart';

class CustomTodos extends StatelessWidget {
  final String title;
  final String content;
  final double width;
  final bool checked;
  final VoidCallback? callback;

  const CustomTodos({
    super.key,
    required this.title,
    required this.content,
    this.callback,
    this.checked = false,
    this.width = 300,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
    onTap: callback,
        child:Container(
        padding: const EdgeInsets.all(defaultPadding),
        margin: const EdgeInsets.symmetric(horizontal: defaultPadding),
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              color: const Color.fromARGB(255, 226, 226, 226),
              width: 1.0,
            )),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(
              height: 40,
              width: 6,
              color: checked? ProtonColors.signalSuccess : ProtonColors.signalError,
            ),
            const SizedBox(
              width: 10,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: FontManager.body2Regular(ProtonColors.textNorm)),
                Text(content,
                    style: FontManager.body2Regular(ProtonColors.textNorm)),
              ],
            )
          ]),
          checked
              ? const Icon(Icons.check, color: ProtonColors.signalSuccess)
              : const Icon(
                  Icons.arrow_forward_ios,
                  color: ProtonColors.textNorm,
                  size: 20,
                ),
        ])));
  }
}