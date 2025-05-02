import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/extension/datetime.dart';

class DateInputV1 extends StatefulWidget {
  final FocusNode myFocusNode;
  final TextEditingController textController;
  final String labelText;
  final DateTime initialDate;

  const DateInputV1({
    required this.textController,
    required this.myFocusNode,
    required this.initialDate,
    super.key,
    this.labelText = "",
  });

  @override
  State<StatefulWidget> createState() => TextInputState();
}

class TextInputState extends State<DateInputV1> {
  late DateTime pickDate;

  @override
  void initState() {
    pickDate = widget.initialDate;
    super.initState();
  }

  Color getBorderColor(BuildContext context, isFocus) {
    return isFocus ? ProtonColors.protonBlue : Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: pickDate,
          firstDate: DateTime(1911),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context).colorScheme.copyWith(
                      primary: ProtonColors.protonBlue,
                      onPrimary: ProtonColors.textInverted,
                      onSurface: ProtonColors.textNorm,
                    ),
                datePickerTheme: DatePickerThemeData(
                  backgroundColor: ProtonColors.backgroundSecondary,
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: ProtonColors.textNorm,
                  ),
                ),
              ),
              child: child!,
            );
          },
        );

        if (picked != null && picked != pickDate) {
          setState(() {
            pickDate = picked;
            widget.textController.text = pickDate.toLocaleFormatYMD(context);
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            FocusScope(
              child: Focus(
                onFocusChange: (focus) {
                  setState(() {
                    getBorderColor(context, focus);
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 12)
                          .copyWith(bottom: 4),
                  decoration: BoxDecoration(
                      color: ProtonColors.backgroundSecondary,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(18.0)),
                      border: Border.all(
                        color: getBorderColor(
                            context, widget.myFocusNode.hasFocus),
                      )),
                  child: TextFormField(
                    scrollPadding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom + 60),
                    focusNode: widget.myFocusNode,
                    controller: widget.textController,
                    enabled: false,
                    style:
                        ProtonStyles.body1Medium(color: ProtonColors.textNorm),
                    validator: (string) {
                      return null;
                    },
                    decoration: InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      counterText: "",
                      suffixIcon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 24,
                        color: ProtonColors.textWeak,
                      ),
                      hintStyle: ProtonStyles.body2Regular(
                          color: ProtonColors.textHint),
                      labelText: widget.labelText,
                      labelStyle: ProtonStyles.body1Regular(
                          color: ProtonColors.textWeak),
                      contentPadding: const EdgeInsets.only(
                          left: 12, right: 10, top: 4, bottom: 16),
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      border: InputBorder.none,
                      errorStyle: const TextStyle(height: 0),
                      focusedErrorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
