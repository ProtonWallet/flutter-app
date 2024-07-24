import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/helper/local_toast.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/button.v5.dart';
import 'package:wallet/scenes/components/button.v6.dart';
import 'package:wallet/scenes/components/close.button.v1.dart';
import 'package:wallet/scenes/components/page.layout.v1.dart';
import 'package:wallet/scenes/components/textfield.2fa.dart';
import 'package:wallet/scenes/components/textfield.text.v2.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/theme/theme.font.dart';

import 'two.factor.auth.viewmodel.dart';

class TwoFactorAuthView extends ViewBase<TwoFactorAuthViewModel> {
  const TwoFactorAuthView(TwoFactorAuthViewModel viewModel)
      : super(viewModel, const Key("TwoFactorAuthView"));

  @override
  Widget build(BuildContext context) {
    if (viewModel.page == 0) {
      return buildMain(context);
    } else if (viewModel.page == 1) {
      return buildQRcodeForSecret(context);
    } else if (viewModel.page == 2) {
      return buildTextViewForSecret(context);
    } else if (viewModel.page == 3) {
      return build2FAConfirm(context);
    } else if (viewModel.page == 4) {
      return buildBackupPage(context);
    }
    return buildMain(context);
  }

  Widget buildMain(BuildContext context) {
    return PageLayoutV1(
      backgroundColor: ProtonColors.white,
      headerWidget: Align(
        alignment: Alignment.centerRight,
        child: CloseButtonV1(
            backgroundColor: ProtonColors.backgroundProton,
            onPressed: () {
              Navigator.of(context).pop();
            }),
      ),
      bottomWidget: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(children: [
          ButtonV5(
            onPressed: () {
              viewModel.updatePage(1);
            },
            text: S.of(context).next,
            width: MediaQuery.of(context).size.width,
            backgroundColor: ProtonColors.protonBlue,
            borderColor: ProtonColors.protonBlue,
            elevation: 0.0,
            textStyle: FontManager.body1Median(ProtonColors.white),
            height: 48,
          ),
          SizedBoxes.box12,
          ButtonV5(
            onPressed: () {
              Navigator.pop(context);
            },
            text: S.of(context).cancel,
            width: MediaQuery.of(context).size.width,
            backgroundColor: ProtonColors.protonShades20,
            borderColor: ProtonColors.protonShades20,
            elevation: 0.0,
            textStyle: FontManager.body1Median(ProtonColors.textNorm),
            height: 48,
          ),
        ]),
      ),
      child: Transform.translate(
        offset: const Offset(0, -30),
        child: Column(
          children: [
            buildHeader(
              context,
              S.of(context).setting_2fa_guide_step1,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHeader(BuildContext context, String body) {
    return Column(
      children: [
        Assets.images.icon.lock.image(
          fit: BoxFit.fill,
          width: 240,
          height: 167,
        ),
        Text(
          S.of(context).setting_2fa_setup,
          style: FontManager.titleHeadline(ProtonColors.textNorm),
          textAlign: TextAlign.center,
        ),
        const SizedBox(
          height: 6,
        ),
        Text(
          body,
          style: FontManager.body2Regular(ProtonColors.textWeak),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget buildQRcodeForSecret(BuildContext context) {
    return PageLayoutV1(
      backgroundColor: ProtonColors.white,
      headerWidget: Align(
        alignment: Alignment.centerRight,
        child: CloseButtonV1(
            backgroundColor: ProtonColors.backgroundProton,
            onPressed: () {
              Navigator.of(context).pop();
            }),
      ),
      bottomWidget: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(children: [
          ButtonV5(
            onPressed: () {
              viewModel.updatePage(3);
            },
            text: S.of(context).next,
            width: MediaQuery.of(context).size.width,
            backgroundColor: ProtonColors.protonBlue,
            borderColor: ProtonColors.protonBlue,
            elevation: 0.0,
            textStyle: FontManager.body1Median(ProtonColors.white),
            height: 48,
          ),
          SizedBoxes.box12,
          ButtonV5(
            onPressed: () {
              viewModel.updatePage(0);
            },
            text: S.of(context).cancel,
            width: MediaQuery.of(context).size.width,
            backgroundColor: ProtonColors.protonShades20,
            borderColor: ProtonColors.protonShades20,
            elevation: 0.0,
            textStyle: FontManager.body1Median(ProtonColors.textNorm),
            height: 48,
          ),
        ]),
      ),
      child: Transform.translate(
        offset: const Offset(0, -30),
        child: Column(
          children: [
            buildHeader(
              context,
              S.of(context).setting_2fa_guide_step2,
            ),
            const SizedBox(
              height: 4,
            ),
            ColoredBox(
              color: ProtonColors.white,
              child: QrImageView(
                size: min(400, 200),
                data: viewModel.otpAuthString,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () {
                viewModel.updatePage(2);
              },
              child: Text(
                S.of(context).setting_2fa_enter_key_manual,
                style: FontManager.body1Median(
                  ProtonColors.protonBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextViewForSecret(BuildContext context) {
    return PageLayoutV1(
      backgroundColor: ProtonColors.white,
      headerWidget: Align(
        alignment: Alignment.centerRight,
        child: CloseButtonV1(
            backgroundColor: ProtonColors.backgroundProton,
            onPressed: () {
              Navigator.of(context).pop();
            }),
      ),
      bottomWidget: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(children: [
          ButtonV5(
            onPressed: () {
              viewModel.updatePage(3);
            },
            text: S.of(context).next,
            width: MediaQuery.of(context).size.width,
            backgroundColor: ProtonColors.protonBlue,
            borderColor: ProtonColors.protonBlue,
            elevation: 0.0,
            textStyle: FontManager.body1Median(ProtonColors.white),
            height: 48,
          ),
          SizedBoxes.box12,
          ButtonV5(
            onPressed: () {
              viewModel.updatePage(0);
            },
            text: S.of(context).cancel,
            width: MediaQuery.of(context).size.width,
            backgroundColor: ProtonColors.protonShades20,
            borderColor: ProtonColors.protonShades20,
            elevation: 0.0,
            textStyle: FontManager.body1Median(ProtonColors.textNorm),
            height: 48,
          ),
        ]),
      ),
      child: Transform.translate(
        offset: const Offset(0, -30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildHeader(
              context,
              S.of(context).setting_2fa_guide_step2,
            ),
            const SizedBox(
              height: 4,
            ),
            Text("Key", style: FontManager.body2Regular(ProtonColors.textNorm)),
            const SizedBox(
              height: 6,
            ),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: viewModel.secret))
                    .then((_) {
                  if (context.mounted) {
                    LocalToast.showToast(context, S.of(context).copied);
                  }
                });
              },
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(
                  viewModel.secret,
                  style: FontManager.body2Median(ProtonColors.textNorm),
                  maxLines: 4,
                ),
                const SizedBox(
                  width: 4,
                ),
                Icon(Icons.copy_rounded,
                    size: 16, color: ProtonColors.textHint),
              ]),
            ),
            const SizedBox(
              height: 10,
            ),
            const Divider(
              thickness: 0.2,
              height: 1,
            ),
            const SizedBox(
              height: 10,
            ),
            Text("Interval",
                style: FontManager.body2Regular(ProtonColors.textNorm)),
            const SizedBox(
              height: 6,
            ),
            Text(
              "30",
              style: FontManager.body2Median(ProtonColors.textNorm),
              maxLines: 4,
            ),
            const SizedBox(
              height: 10,
            ),
            const SizedBox(
              height: 10,
            ),
            const Divider(
              thickness: 0.2,
              height: 1,
            ),
            const SizedBox(
              height: 10,
            ),
            Text("Digits",
                style: FontManager.body2Regular(ProtonColors.textNorm)),
            const SizedBox(
              height: 6,
            ),
            Text(
              "6",
              style: FontManager.body2Median(ProtonColors.textNorm),
              maxLines: 4,
            ),
            const SizedBox(
              height: 10,
            ),
            const Divider(
              thickness: 0.2,
              height: 1,
            ),
            const SizedBox(
              height: 10,
            ),
            Center(
              child: GestureDetector(
                onTap: () {
                  viewModel.updatePage(1);
                },
                child: Text(
                  S.of(context).setting_2fa_scan_qrcode,
                  style: FontManager.body1Median(
                    ProtonColors.protonBlue,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget build2FAConfirm(BuildContext context) {
    return PageLayoutV1(
      backgroundColor: ProtonColors.white,
      headerWidget: Align(
        alignment: Alignment.centerRight,
        child: CloseButtonV1(
            backgroundColor: ProtonColors.backgroundProton,
            onPressed: () {
              Navigator.of(context).pop();
            }),
      ),
      bottomWidget: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(children: [
          ButtonV6(
            onPressed: () async {
              final bool result = await viewModel.setup2FA();
              if (context.mounted) {
                if (result) {
                  viewModel.updatePage(4);
                } else {
                  LocalToast.showErrorToast(context, "Something error!");
                }
              }
            },
            text: S.of(context).next,
            width: MediaQuery.of(context).size.width,
            backgroundColor: ProtonColors.protonBlue,
            borderColor: ProtonColors.protonBlue,
            textStyle: FontManager.body1Median(ProtonColors.white),
            height: 48,
          ),
          SizedBoxes.box12,
          ButtonV5(
            onPressed: () {
              viewModel.updatePage(1);
            },
            text: S.of(context).cancel,
            width: MediaQuery.of(context).size.width,
            backgroundColor: ProtonColors.protonShades20,
            borderColor: ProtonColors.protonShades20,
            elevation: 0.0,
            textStyle: FontManager.body1Median(ProtonColors.textNorm),
            height: 48,
          ),
        ]),
      ),
      child: Transform.translate(
        offset: const Offset(0, -30),
        child: Column(
          children: [
            buildHeader(
              context,
              "",
            ),
            TextFieldTextV2(
              borderColor: ProtonColors.textHint,
              labelText: S.of(context).password,
              hintText: S.of(context).password_hint,
              alwaysShowHint: true,
              textController: viewModel.passwordController,
              myFocusNode: viewModel.passphraseFocusNode,
              validation: (String _) {
                return "";
              },
              isPassword: true,
            ),
            SizedBoxes.box24,
            Text(
              S.of(context).setting_2fa_code_hint,
              style: FontManager.body2Regular(ProtonColors.textWeak),
              textAlign: TextAlign.center,
            ),
            SizedBoxes.box8,
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              for (int i = 0; i < 6; i++)
                TextField2FA(
                    width: 48,
                    controller: viewModel.digitControllers[i],
                    onChanged: (text) {
                      if (text.isNotEmpty) {
                        if (i < 5) {
                          FocusScope.of(context).nextFocus();
                        }
                      } else {
                        if (i > 0) {
                          FocusScope.of(context).previousFocus();
                        }
                      }
                    },
                    textInputAction:
                        i == 5 ? TextInputAction.done : TextInputAction.next,
                    digitOnly: true),
            ]),
          ],
        ),
      ),
    );
  }

  Widget buildBackupPage(BuildContext context) {
    return PageLayoutV1(
      backgroundColor: ProtonColors.white,
      headerWidget: Align(
        alignment: Alignment.centerRight,
        child: CloseButtonV1(
            backgroundColor: ProtonColors.backgroundProton,
            onPressed: () {
              Navigator.of(context).pop();
            }),
      ),
      bottomWidget: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(children: [
          ButtonV5(
            onPressed: () {
              Clipboard.setData(ClipboardData(
                      text: "[${viewModel.backupPhrases.join(" ")}]"))
                  .then((_) {
                if (context.mounted) {
                  LocalToast.showToast(
                      context, "Recovery codes copied to clipboard");
                }
              });
            },
            text: S.of(context).copy_button,
            width: MediaQuery.of(context).size.width,
            backgroundColor: ProtonColors.protonBlue,
            borderColor: ProtonColors.protonBlue,
            elevation: 0.0,
            textStyle: FontManager.body1Median(ProtonColors.white),
            height: 48,
          ),
          SizedBoxes.box12,
          ButtonV5(
            onPressed: () {
              Navigator.of(context).pop();
            },
            text: S.of(context).done,
            width: MediaQuery.of(context).size.width,
            backgroundColor: ProtonColors.protonShades20,
            borderColor: ProtonColors.protonShades20,
            elevation: 0.0,
            textStyle: FontManager.body1Median(ProtonColors.textNorm),
            height: 48,
          ),
        ]),
      ),
      child: Transform.translate(
        offset: const Offset(0, -20),
        child: Column(
          children: [
            Text(
              S.of(context).setting_2fa_setup,
              style: FontManager.titleHeadline(ProtonColors.textNorm),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 12,
            ),
            Text(
              S.of(context).setting_2fa_backup_alert_title,
              style: FontManager.body2Median(ProtonColors.textNorm),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: defaultPadding,
            ),
            Text(
              S.of(context).setting_2fa_backup_alert_content,
              style: FontManager.body2Regular(ProtonColors.textWeak),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 30,
            ),
            for (int i = 0; i < viewModel.backupPhrases.length; i += 2)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 250,
                    height: 30,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          viewModel.backupPhrases[i],
                          style: FontManager.body2Median(ProtonColors.textNorm),
                          textAlign: TextAlign.justify,
                        ),
                        (i + 1 < viewModel.backupPhrases.length)
                            ? Text(
                                viewModel.backupPhrases[i],
                                style: FontManager.body2Median(
                                    ProtonColors.textNorm),
                                textAlign: TextAlign.justify,
                              )
                            : const SizedBox(),
                      ],
                    ),
                  ),
                  const Divider(
                    thickness: 0.2,
                    height: 1,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
