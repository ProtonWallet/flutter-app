import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';

class TextFieldPassword extends StatefulWidget {
  final double width;
  final TextEditingController? controller;
  final String? hintText;

  const TextFieldPassword({
    required this.width,
    super.key,
    this.controller,
    this.hintText,
  });

  @override
  TextFieldPasswordState createState() => TextFieldPasswordState();
}

class TextFieldPasswordState extends State<TextFieldPassword> {
  bool isTextVisible = true;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: widget.width,
        child: Center(
          child: TextField(
            style: ProtonStyles.body2Regular(color: ProtonColors.textNorm),
            controller: widget.controller,
            obscureText: isTextVisible,
            decoration: InputDecoration(
              hintText: widget.hintText,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: ProtonColors.textNorm),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide:
                    BorderSide(color: ProtonColors.interactionNorm, width: 2),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.visibility),
                onPressed: () {
                  setState(() {
                    isTextVisible = !isTextVisible;
                  });
                },
              ),
            ),
          ),
        ));
  }
}
