import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';

class TextFieldAutoComplete extends StatelessWidget {
  final List<String> options;
  final Color color;

  const TextFieldAutoComplete({
    super.key,
    required this.options,
    this.color = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text == '') {
            return const Iterable<String>.empty();
          }
          return options.where((String option) {
            return option.contains(textEditingValue.text.toLowerCase());
          });
        },
        onSelected: (String selection) {},
        fieldViewBuilder: (BuildContext context,
            TextEditingController textEditingController,
            FocusNode focusNode,
            VoidCallback onFieldSubmitted) {
          return Container(
              decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8.0),
          ),
          child: TextField(
              controller: textEditingController,
              focusNode: focusNode,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                      color: color, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(
                      color: ProtonColors.interactionNorm, width: 2),
                ),
              )));
        });
  }
}
