import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/extension/build.context.extension.dart';
import 'package:wallet/helper/local_toast.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/button.v5.dart';
import 'package:wallet/scenes/components/close.button.v1.dart';

Future<void> showMnemonicDialog(
  BuildContext context,
  String mnemonic,
  VoidCallback onClick,
) async {
  return showModalBottomSheet<void>(
    context: context,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: ProtonColors.white,
    constraints: BoxConstraints(
      minWidth: MediaQuery.of(context).size.width,
      maxHeight: MediaQuery.of(context).size.height - 60,
    ),
    isScrollControlled: true,
    builder: (BuildContext context) {
      return SafeArea(
        child: Container(
          padding: const EdgeInsets.all(defaultPadding),
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              Align(
                  alignment: Alignment.centerRight,
                  child: CloseButtonV1(
                      backgroundColor: ProtonColors.backgroundNorm,
                      onPressed: () {
                        onClick();
                        Navigator.of(context).pop();
                      })),
              Transform.translate(
                offset: const Offset(0, -20),
                child: Assets.images.icon.lock.image(
                  fit: BoxFit.fitHeight,
                  width: 240,
                  height: 167,
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -30),
                child: Center(
                  child: Text(
                    S.of(context).enable_recovery_title,
                    style:
                        ProtonStyles.headline(color: ProtonColors.textNorm),
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Text(
                  S.of(context).enable_recovery_content,
                  style: ProtonStyles.body2Regular(
                    color: ProtonColors.textWeak,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Text(
                  S.of(context).enable_recovery_remind,
                  style: ProtonStyles.body2Regular(
                    color: ProtonColors.signalError,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(16),
                  ),
                  border: Border.all(
                    color: ProtonColors.backgroundNorm,
                    width: 1.6,
                  ),
                ),
                width: MediaQuery.of(context).size.width,
                child: Column(children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      S.of(context).recovery_phrase,
                      style: ProtonStyles.body2Regular(
                        color: ProtonColors.textWeak,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      Clipboard.setData(ClipboardData(text: mnemonic))
                          .then((_) {
                        if (context.mounted) {
                          LocalToast.showToast(
                            context,
                            "Recovery phrase copied to clipboard",
                            icon: null,
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
                              const SizedBox(height: 4),
                              Text(
                                mnemonic,
                                style: ProtonStyles.body1Medium(
                                  color: ProtonColors.textNorm,
                                ),
                              ),
                              const SizedBox(height: 4),
                            ],
                          ),
                        ),
                        Assets.images.icon.icSquares.svg(
                          width: 24,
                          height: 24,
                          fit: BoxFit.fill,
                        )
                      ],
                    ),
                  ),
                ]),
              ),
              const SizedBox(
                height: 40,
              ),
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
                width: MediaQuery.of(context).size.width,
                height: 55,
              ),
            ],
          ),
        ),
      );
    },
  );
}
