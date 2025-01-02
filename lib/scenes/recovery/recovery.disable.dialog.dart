import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/button.v5.dart';

Future<void> showDisableDialog(
  BuildContext context,
  VoidCallback onDisable,
) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: ProtonColors.white,
        title: Center(
          child: Text(
            S.of(context).disable_recovery_phrase_title,
            style: ProtonStyles.body1Medium(color: ProtonColors.textNorm),
          ),
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              SizedBox(
                width: 300,
                child: Text(
                  S.of(context).disable_recovery_phrase_content,
                  style:
                      ProtonStyles.body2Regular(color: ProtonColors.textWeak),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 300,
                child: Text(
                  S.of(context).disable_recovery_phrase_content2,
                  style:
                      ProtonStyles.body2Regular(color: ProtonColors.textWeak),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          Column(
            children: [
              ButtonV5(
                onPressed: () {
                  onDisable();
                  Navigator.of(context).pop();
                },
                text: S.of(context).disable_recovery_phrase_button,
                backgroundColor: ProtonColors.signalError,
                textStyle: ProtonStyles.body1Medium(color: ProtonColors.white),
                width: 300,
                height: 44,
              ),
              const SizedBox(
                height: 8,
              ),
              ButtonV5(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                text: S.of(context).cancel,
                borderColor: ProtonColors.protonShades20,
                backgroundColor: ProtonColors.protonShades20,
                textStyle:
                    ProtonStyles.body1Medium(color: ProtonColors.textNorm),
                width: 300,
                height: 44,
              ),
            ],
          ),
        ],
      );
    },
  );
}
