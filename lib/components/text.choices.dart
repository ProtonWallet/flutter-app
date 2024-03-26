import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/theme/theme.font.dart';

class TextChoices extends StatefulWidget {
  final List<String> choices;
  final TextEditingController? controller;
  final String selectedValue;

  TextChoices({
    super.key,
    this.controller,
    required this.choices,
    required this.selectedValue,
  }) {
    if (controller != null) {
      controller!.text = selectedValue;
    }
  }

  @override
  TextFieldTextState createState() => TextFieldTextState();
}

class TextFieldTextState extends State<TextChoices> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: const BoxConstraints.tightFor(),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: ProtonColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Wrap(
                spacing: 2.0,
                runSpacing: 2.0,
                alignment: WrapAlignment.center,
                children: List.generate(
                  widget.choices.length,
                  (index) => GestureDetector(
                      onTap: () {
                        setState(() {
                          if (widget.controller != null) {
                            widget.controller!.text = widget.choices[index];
                          }
                        });
                      },
                      child: widget.controller!.text == widget.choices[index]
                          ? Container(
                              width: 60,
                              height: 42,
                              decoration: BoxDecoration(
                                color: ProtonColors.iconWeak,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Center(
                                  child: Text(widget.choices[index],
                                      style: FontManager.body1Regular(
                                          ProtonColors.white))))
                          : Container(
                              width: 60,
                              height: 42,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Center(
                                  child: Text(widget.choices[index],
                                      style: FontManager.body1Regular(
                                          ProtonColors.textHint))))),
                )),
          ],
        ));
  }
}
