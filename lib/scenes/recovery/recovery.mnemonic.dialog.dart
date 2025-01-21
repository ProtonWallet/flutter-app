import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/extension/build.context.extension.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/button.v5.dart';

Future<void> showMnemonicDialog(
  BuildContext context,
  String mnemonic,
  VoidCallback onClick,
) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: ProtonColors.backgroundNorm,
        title: Center(
          child: Text(
            S.of(context).enable_recovery_title,
            style: ProtonStyles.body1Medium(color: ProtonColors.textNorm),
          ),
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              SizedBox(
                width: 360,
                child: Text(
                  S.of(context).enable_recovery_content,
                  style: ProtonStyles.body2Regular(
                    color: ProtonColors.textWeak,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 360,
                child: Text(
                  S.of(context).enable_recovery_remind,
                  style: ProtonStyles.body2Regular(
                    color: ProtonColors.signalError,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                S.of(context).recovery_phrase,
                style: const TextStyle(
                  fontSize: 18,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: ProtonColors.white,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                width: 360,
                child: GestureDetector(
                  onTap: () async {
                    Clipboard.setData(ClipboardData(text: mnemonic)).then((_) {
                      if (context.mounted) {
                        context.showSnackbar(
                          "Recovery phrase copied to clipboard",
                        );
                      }
                    });
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            Text(mnemonic),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                      Assets.images.icon.icSquares.svg(
                        width: 32,
                        height: 32,
                        fit: BoxFit.fill,
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        actions: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ButtonV5(
                onPressed: () {
                  onClick();
                  Navigator.of(context).pop();
                },
                text: S.of(context).done,
                borderColor: ProtonColors.protonBlue,
                backgroundColor: ProtonColors.protonBlue,
                textStyle: ProtonStyles.body1Medium(
                  color: ProtonColors.textInverted,
                ),
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
