import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/button.v5.dart';
import 'package:wallet/theme/theme.font.dart';

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
        backgroundColor: ProtonColors.backgroundProton,
        title: Center(
          child: Text(
            S.of(context).enable_recovery_title,
            style: FontManager.body1Median(ProtonColors.textNorm),
          ),
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              SizedBox(
                width: 360,
                child: Text(
                  S.of(context).enable_recovery_content,
                  style: FontManager.body2Regular(ProtonColors.textWeak),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 360,
                child: Text(
                  S.of(context).enable_recovery_remind,
                  style: FontManager.body2Regular(ProtonColors.signalError),
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
                        CommonHelper.showSnackbar(
                            context, "Recovery phrase copied to clipboard");
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
                  Share.share(
                    mnemonic,
                    subject: "Recovery phrase",
                  );
                },
                text: S.of(context).share_button,
                backgroundColor: ProtonColors.protonBlue,
                textStyle: FontManager.body1Median(ProtonColors.white),
                width: 300,
                height: 44,
                elevation: 0.0,
              ),
              const SizedBox(
                height: 8,
              ),
              ButtonV5(
                onPressed: () {
                  onClick();
                  Navigator.of(context).pop();
                },
                text: S.of(context).done,
                borderColor: ProtonColors.protonShades20,
                backgroundColor: ProtonColors.protonShades20,
                textStyle: FontManager.body1Median(ProtonColors.textNorm),
                width: 300,
                height: 44,
                elevation: 0.0,
              ),
            ],
          ),
        ],
      );
    },
  );
}
