import 'package:flutter/material.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/theme/theme.font.dart';

class CustomTodos extends StatelessWidget {
  final String title;
  final bool checked;
  final VoidCallback? callback;

  const CustomTodos({
    super.key,
    required this.title,
    this.callback,
    this.checked = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: callback,
        child: Container(
            padding: const EdgeInsets.all(defaultPadding),
            decoration: BoxDecoration(
              color: ProtonColors.white,
              borderRadius: BorderRadius.circular(24.0),
            ),
            child: ListTile(
              dense:true,
              leading: Radio<bool>(
                value: true,
                groupValue: checked,
                onChanged: (value) {},
                hoverColor: Colors.transparent,
                focusColor: Colors.transparent,
                activeColor: ProtonColors.protonBlue,
                fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                  if (states.contains(MaterialState.selected)) {
                    return ProtonColors.protonBlue;
                  }
                  return ProtonColors.protonBlue;
                }),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 2),
              title: Transform.translate(
                  offset: const Offset(-10, -1),
                  child: Text(
                    title,
                    style: checked? FontManager.body2MedianLineThrough(ProtonColors.protonBlue): FontManager.body2Median(ProtonColors.protonBlue),
                  )),
              trailing: checked ? null: Icon(Icons.arrow_forward_ios_rounded, color: ProtonColors.protonBlue, size: 14),
            )));
  }
}
