import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/components/onboarding/content.dart';
import 'package:wallet/components/textfield.2fa.dart';
import 'package:wallet/components/textfield.password.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/helper/local_toast.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/theme/theme.font.dart';
import 'package:wallet/l10n/generated/locale.dart';

import 'two.factor.auth.viewmodel.dart';

class TwoFactorAuthView extends ViewBase<TwoFactorAuthViewModel> {
  const TwoFactorAuthView(TwoFactorAuthViewModel viewModel)
      : super(viewModel, const Key("TwoFactorAuthView"));

  @override
  Widget build(BuildContext context) {
    if (viewModel.page == 0) {
      return Scaffold(body: buildMain(context));
    } else if (viewModel.page == 1) {
      return Scaffold(body: buildQRcodeForSecret(context));
    } else if (viewModel.page == 2) {
      return Scaffold(body: buildTextViewForSecret(context));
    } else if (viewModel.page == 3) {
      return Scaffold(body: build2FAConfirm(context));
    } else if (viewModel.page == 4) {
      return Scaffold(body: buildBackupPage(context));
    }
    return Scaffold(body: buildMain(context));
  }

  Widget buildMain(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 4,
          color: ProtonColors.backgroundSecondary,
          child: Stack(children: [
            Center(
                child: Container(
              constraints: const BoxConstraints(
                maxWidth: 100.0,
              ),
              child: SvgPicture.asset(
                'assets/images/wallet_creation/passphrase_icon.svg',
                fit: BoxFit.contain,
              ),
            )),
            AppBar(
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: ProtonColors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ]),
        ),
        Expanded(
          child: OnboardingContent(
              totalPages: 4,
              currentPage: 1,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 4 * 3,
              title: S.of(context).setting_2fa_setup,
              content: S.of(context).setting_2fa_guide_step1),
        ),
        Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(children: [
              ButtonV5(
                  onPressed: () {
                    viewModel.updatePage(1);
                  },
                  text: S.of(context).next,
                  width: MediaQuery.of(context).size.width,
                  textStyle: FontManager.body1Median(ProtonColors.white),
                  height: 48),
              SizedBoxes.box12,
              ButtonV5(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  text: S.of(context).cancel,
                  width: MediaQuery.of(context).size.width,
                  backgroundColor: ProtonColors.white,
                  borderColor: ProtonColors.interactionNorm,
                  textStyle:
                      FontManager.body1Median(ProtonColors.interactionNorm),
                  height: 48),
            ])),
      ],
    );
  }

  Widget buildQRcodeForSecret(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Stack(children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 4,
            color: ProtonColors.backgroundSecondary,
            child: Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 20,
                    bottom: MediaQuery.of(context).size.height / 20),
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: 100.0,
                  ),
                  child: SvgPicture.asset(
                    'assets/images/wallet_creation/passphrase_icon.svg',
                    fit: BoxFit.contain,
                  ),
                )),
          ),
        ]),
        Container(
          alignment: Alignment.topCenter,
          width: MediaQuery.of(context).size.width,
          child: OnboardingContent(
              totalPages: 4,
              currentPage: 2,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 4 * 3,
              title: S.of(context).setting_2fa_setup,
              content: S.of(context).setting_2fa_guide_step2,
              children: [
                Column(children: [
                  GestureDetector(
                      onTap: () {
                        viewModel.updatePage(2);
                      },
                      child: Text(S.of(context).setting_2fa_enter_key_manual,
                          style: FontManager.body1Median(
                              ProtonColors.interactionNorm))),
                  SizedBoxes.box18,
                  Container(
                    color: ProtonColors.white,
                    child: QrImageView(
                      size: min(MediaQuery.of(context).size.width, 200),
                      data: viewModel.otpAuthString,
                      version: QrVersions.auto,
                    ),
                  ),
                ]),
                SizedBoxes.box41,
                ButtonV5(
                    onPressed: () {
                      viewModel.updatePage(3);
                    },
                    text: S.of(context).next,
                    width: MediaQuery.of(context).size.width,
                    textStyle: FontManager.body1Median(ProtonColors.white),
                    height: 48),
                SizedBoxes.box12,
                ButtonV5(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    text: S.of(context).cancel,
                    width: MediaQuery.of(context).size.width,
                    backgroundColor: ProtonColors.white,
                    borderColor: ProtonColors.interactionNorm,
                    textStyle:
                        FontManager.body1Median(ProtonColors.interactionNorm),
                    height: 48),
              ]),
        ),
      ],
    );
  }

  Widget buildTextViewForSecret(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Stack(children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 4,
            color: ProtonColors.backgroundSecondary,
            child: Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 20,
                    bottom: MediaQuery.of(context).size.height / 20),
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: 100.0,
                  ),
                  child: SvgPicture.asset(
                    'assets/images/wallet_creation/passphrase_icon.svg',
                    fit: BoxFit.contain,
                  ),
                )),
          ),
        ]),
        Container(
          alignment: Alignment.topCenter,
          width: MediaQuery.of(context).size.width,
          child: OnboardingContent(
              totalPages: 4,
              currentPage: 2,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 4 * 3,
              title: S.of(context).setting_2fa_setup,
              content: S.of(context).setting_2fa_guide_step2,
              children: [
                Column(children: [
                  GestureDetector(
                      onTap: () {
                        viewModel.updatePage(1);
                      },
                      child: Text(S.of(context).setting_2fa_scan_qrcode,
                          style: FontManager.body1Median(
                              ProtonColors.interactionNorm))),
                  SizedBoxes.box18,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                          width: 60,
                          child: Text("Key",
                              style: FontManager.body2Regular(
                                  ProtonColors.textNorm))),
                      SizedBox(
                          width: 340,
                          child: Text(viewModel.secret,
                              style: FontManager.body2Median(
                                  ProtonColors.textNorm))),
                    ],
                  ),
                  SizedBoxes.box8,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                          width: 60,
                          child: Text("Interval",
                              style: FontManager.body2Regular(
                                  ProtonColors.textNorm))),
                      SizedBox(
                          width: 340,
                          child: Text("30",
                              style: FontManager.body2Median(
                                  ProtonColors.textNorm))),
                    ],
                  ),
                  SizedBoxes.box8,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                          width: 60,
                          child: Text("Digits",
                              style: FontManager.body2Regular(
                                  ProtonColors.textNorm))),
                      SizedBox(
                          width: 340,
                          child: Text("6",
                              style: FontManager.body2Median(
                                  ProtonColors.textNorm))),
                    ],
                  ),
                ]),
                SizedBoxes.box41,
                ButtonV5(
                    onPressed: () {
                      viewModel.updatePage(3);
                    },
                    text: S.of(context).next,
                    width: MediaQuery.of(context).size.width,
                    textStyle: FontManager.body1Median(ProtonColors.white),
                    height: 48),
                SizedBoxes.box12,
                ButtonV5(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    text: S.of(context).cancel,
                    width: MediaQuery.of(context).size.width,
                    backgroundColor: ProtonColors.white,
                    borderColor: ProtonColors.interactionNorm,
                    textStyle:
                        FontManager.body1Median(ProtonColors.interactionNorm),
                    height: 48),
              ]),
        ),
      ],
    );
  }

  Widget build2FAConfirm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Stack(children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 4,
            color: ProtonColors.backgroundSecondary,
            child: Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 20,
                    bottom: MediaQuery.of(context).size.height / 20),
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: 100.0,
                  ),
                  child: SvgPicture.asset(
                    'assets/images/wallet_creation/passphrase_icon.svg',
                    fit: BoxFit.contain,
                  ),
                )),
          ),
        ]),
        Container(
          alignment: Alignment.topCenter,
          width: MediaQuery.of(context).size.width,
          child: OnboardingContent(
              totalPages: 4,
              currentPage: 3,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 4 * 3,
              title: S.of(context).setting_2fa_setup,
              content: S.of(context).setting_2fa_code_hint,
              children: [
                Column(children: [
                  SizedBoxes.box12,
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (int i = 0; i < 6; i++)
                          TextField2FA(
                              width: 50,
                              height: 50,
                              suffixIcon: const Icon(Icons.close),
                              showSuffixIcon: false,
                              showEnabledBorder: true,
                              centerHorizontal: true,
                              maxLength: 1,
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
                              textInputAction: i == 5
                                  ? TextInputAction.done
                                  : TextInputAction.next,
                              digitOnly: true),
                      ]),
                  SizedBoxes.box18,
                  Container(
                      alignment: Alignment.centerLeft,
                      child: Text("Password",
                          style:
                              FontManager.body1Median(ProtonColors.textHint))),
                  TextFieldPassword(
                      width: MediaQuery.of(context).size.width,
                      controller: viewModel.passwordController),
                ]),
                SizedBoxes.box41,
                ButtonV5(
                    onPressed: () async {
                      bool result = await viewModel.setup2FA();
                      if (context.mounted) {
                        if (result) {
                          viewModel.updatePage(4);
                        } else {
                          LocalToast.showErrorToast(
                              context, "Something error!");
                        }
                      }
                    },
                    text: S.of(context).next,
                    width: MediaQuery.of(context).size.width,
                    textStyle: FontManager.body1Median(ProtonColors.white),
                    height: 48),
                SizedBoxes.box12,
                ButtonV5(
                    onPressed: () {
                      viewModel.updatePage(1);
                    },
                    text: S.of(context).cancel,
                    width: MediaQuery.of(context).size.width,
                    backgroundColor: ProtonColors.white,
                    borderColor: ProtonColors.interactionNorm,
                    textStyle:
                        FontManager.body1Median(ProtonColors.interactionNorm),
                    height: 48),
              ]),
        ),
      ],
    );
  }

  Widget buildBackupPage(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Stack(children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 4,
            color: ProtonColors.backgroundSecondary,
            child: Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 20,
                    bottom: MediaQuery.of(context).size.height / 20),
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: 100.0,
                  ),
                  child: SvgPicture.asset(
                    'assets/images/wallet_creation/passphrase_icon.svg',
                    fit: BoxFit.contain,
                  ),
                )),
          ),
        ]),
        Container(
          alignment: Alignment.topCenter,
          width: MediaQuery.of(context).size.width,
          child: OnboardingContent(
              totalPages: 4,
              currentPage: 4,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 4 * 3,
              title: S.of(context).setting_2fa_backup_alert_title,
              content: S.of(context).setting_2fa_backup_alert_content,
              children: [
                Column(children: [
                  SizedBoxes.box12,
                  Text(
                    viewModel.backupPhrases.join("   "),
                    style: FontManager.body2Regular(ProtonColors.textNorm),
                    textAlign: TextAlign.justify,
                  ),
                ]),
                ButtonV5(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    text: S.of(context).done,
                    width: MediaQuery.of(context).size.width,
                    textStyle: FontManager.body1Median(ProtonColors.white),
                    height: 48),
              ]),
        ),
      ],
    );
  }
}
