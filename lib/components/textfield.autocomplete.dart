import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
        optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
          return _AutocompleteOptions(
            displayStringForOption: RawAutocomplete.defaultStringForOption,
            onSelected: onSelected,
            options: options,
            maxOptionsHeight: 200,
          );
        },
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

// The default Material-style Autocomplete options.
class _AutocompleteOptions<T extends Object> extends StatelessWidget {
  const _AutocompleteOptions({
    super.key,
    required this.displayStringForOption,
    required this.onSelected,
    required this.options,
    required this.maxOptionsHeight,
  });

  final AutocompleteOptionToString<T> displayStringForOption;

  final AutocompleteOnSelected<T> onSelected;

  final Iterable<T> options;
  final double maxOptionsHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
    margin: const EdgeInsets.only(right: 52),
        child:Align(
      alignment: Alignment.topLeft,
      child: Material(
        elevation: 4.0,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxOptionsHeight),
          child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: options.length,
            itemBuilder: (BuildContext context, int index) {
              final T option = options.elementAt(index);
              return InkWell(
                onTap: () {
                  onSelected(option);
                },
                child: Builder(
                    builder: (BuildContext context) {
                      final bool highlight = AutocompleteHighlightedOption.of(context) == index;
                      if (highlight) {
                        SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
                          Scrollable.ensureVisible(context, alignment: 0.5);
                        });
                      }
                      return Container(
                        color: highlight ? Theme.of(context).focusColor : null,
                        padding: const EdgeInsets.all(16.0),
                        child: Text(displayStringForOption(option)),
                      );
                    }
                ),
              );
            },
          ),
        ),
      ),
    ));
  }
}