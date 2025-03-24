import 'package:flutter/material.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/extension/build.context.extension.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/button.v5.dart';

Future<void> showDisableDialog(
  BuildContext context,
  VoidCallback onDisable,
) async {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: ProtonColors.backgroundSecondary,
    constraints: BoxConstraints(
      minWidth: context.width,
      maxHeight: context.height - 60,
    ),
    isScrollControlled: true,
    builder: (BuildContext context) {
      return SafeArea(
        child: Container(
          padding: const EdgeInsets.all(defaultPadding),
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              const SizedBox(height: defaultPadding),
              context.images.deleteWarning.svg(
                width: 48,
                height: 48,
                fit: BoxFit.scaleDown,
              ),
              const SizedBox(height: defaultPadding),
              Center(
                child: Text(
                  S.of(context).disable_recovery_phrase_title,
                  style: ProtonStyles.headline(color: ProtonColors.textNorm),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              SizedBox(
                width: context.width,
                child: Text(
                  S.of(context).disable_recovery_phrase_content,
                  style: ProtonStyles.body2Regular(
                    color: ProtonColors.textWeak,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Text(
                  S.of(context).disable_recovery_phrase_content2,
                  style: ProtonStyles.body2Regular(
                    color: ProtonColors.textWeak,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),
              ButtonV5(
                onPressed: () {
                  onDisable();
                  Navigator.of(context).pop();
                },
                text: S.of(context).disable_recovery_phrase_button,
                backgroundColor: ProtonColors.notificationError,
                textStyle: ProtonStyles.body1Medium(
                  color: ProtonColors.white,
                ),
                width: context.width,
                height: 55,
              ),
              const SizedBox(height: 8),
              ButtonV5(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                text: S.of(context).cancel,
                borderColor: ProtonColors.interActionWeakDisable,
                backgroundColor: ProtonColors.interActionWeakDisable,
                textStyle: ProtonStyles.body1Medium(
                  color: ProtonColors.textNorm,
                ),
                width: context.width,
                height: 55,
              ),
            ],
          ),
        ),
      );
    },
  );
}
