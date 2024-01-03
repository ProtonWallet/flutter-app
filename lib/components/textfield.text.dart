import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/theme/theme.font.dart';

class TextFieldText extends StatefulWidget {
  final double width;
  TextEditingController? controller;
  String? hintText = "";

  TextFieldText({
    super.key,
    required this.width,
    this.controller,
    this.hintText,
  });

  @override
  _TextFieldTextState createState() => _TextFieldTextState();
}

class _TextFieldTextState extends State<TextFieldText> {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: widget.width,
        child: Center(
          child: TextField(
            controller: widget.controller,
            decoration: InputDecoration(
              hintText: widget.hintText,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide:
                    const BorderSide(color: ProtonColors.interactionNorm, width: 2),
              ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.text_fields),
                  onPressed: () {

                  },
                ),
            ),
          ),
        ));
  }
}
