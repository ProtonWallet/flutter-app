import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/extension/enum.extension.dart';
import 'package:wallet/helper/external.url.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/rust/proton_api/payment_gateway.dart';
import 'package:wallet/scenes/components/bottom.sheets/base.dart';
import 'package:wallet/scenes/components/button.v5.dart';
import 'package:wallet/scenes/components/button.v6.dart';

class OnRampTCSheetModel {
  final GatewayProvider provider;
  final String providerUrl;
  final String termsUrl;
  final String privacyUrl;
  final String contacts;

  OnRampTCSheetModel(
    this.provider,
    this.providerUrl,
    this.termsUrl,
    this.privacyUrl,
    this.contacts,
  );
}

class OnRampTCSheet {
  static void show(
    BuildContext context,
    OnRampTCSheetModel model, {
    required VoidCallback onCancel,
    required VoidCallback onConfirm,
  }) {
    HomeModalBottomSheet.show(context,
        isDismissible: false,
        enableDrag: false,
        backgroundColor: ProtonColors.backgroundSecondary, child:
            StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
      return Column(mainAxisSize: MainAxisSize.min, children: [
        Transform.translate(
            offset: const Offset(0, -20),
            child: Column(children: [
              const SizedBox(height: 40),
              Text(
                S.of(context).disclaimer,
                style: ProtonStyles.headline(color: ProtonColors.textNorm),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              SizedBox(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text:
                            'You are now leaving Proton Wallet for ${model.provider.enumToString()} ',
                        style: ProtonStyles.body2Regular(
                          color: ProtonColors.textNorm,
                        ),
                      ),
                      TextSpan(
                        text: "(${model.providerUrl})",
                        style: ProtonStyles.body2Regular(
                          color: ProtonColors.protonBlue,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            ExternalUrl.shared.launchString(model.providerUrl);
                          },
                      ),
                      TextSpan(
                        text:
                            ". Services related to card payments, bank transfers, and any other fiat transactions are provided by ${model.provider.enumToString()}, a separate third-party platform. By proceeding and procuring services from ${model.provider.enumToString()}, you acknowledge that you have read and agreed to ${model.provider.enumToString()}'s Terms of Use ",
                        style: ProtonStyles.body2Regular(
                          color: ProtonColors.textNorm,
                        ),
                      ),
                      TextSpan(
                        text: "(${model.termsUrl})",
                        style: ProtonStyles.body2Regular(
                          color: ProtonColors.protonBlue,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            ExternalUrl.shared.launchString(model.termsUrl);
                          },
                      ),
                      TextSpan(
                        text: ' and Privacy and Cookies Policy ',
                        style: ProtonStyles.body2Regular(
                          color: ProtonColors.textNorm,
                        ),
                      ),
                      TextSpan(
                        text: "(${model.privacyUrl})",
                        style: ProtonStyles.body2Regular(
                          color: ProtonColors.protonBlue,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            ExternalUrl.shared.launchString(model.privacyUrl);
                          },
                      ),
                      TextSpan(
                        text:
                            ". For any questions related to ${model.provider.enumToString()}'s services, please contact ${model.provider.enumToString()} at ",
                        style: ProtonStyles.body2Regular(
                          color: ProtonColors.textNorm,
                        ),
                      ),
                      TextSpan(
                        text: "(${model.contacts})",
                        style: ProtonStyles.body2Regular(
                          color: ProtonColors.protonBlue,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            ExternalUrl.shared.launchString(model.privacyUrl);
                          },
                      ),
                      TextSpan(
                        text: '.',
                        style: ProtonStyles.body2Regular(
                          color: ProtonColors.textNorm,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: defaultPadding),
                  child: Column(children: [
                    ButtonV5(
                        onPressed: () async {
                          onConfirm.call();
                          Navigator.of(context).pop();
                        },
                        text: "Agree and confirm",
                        width: MediaQuery.of(context).size.width,
                        textStyle: ProtonStyles.body1Medium(
                            color: ProtonColors.textInverted),
                        backgroundColor: ProtonColors.protonBlue,
                        borderColor: ProtonColors.protonBlue,
                        height: 55),
                    const SizedBox(
                      height: 12,
                    ),
                    ButtonV6(
                        onPressed: () async {
                          onCancel.call();
                          Navigator.of(context).pop();
                        },
                        text: S.of(context).cancel,
                        width: MediaQuery.of(context).size.width,
                        textStyle: ProtonStyles.body1Medium(
                            color: ProtonColors.textNorm),
                        backgroundColor: ProtonColors.interActionWeak,
                        borderColor: ProtonColors.interActionWeak,
                        height: 55),
                    const SizedBox(
                      height: 12,
                    ),
                  ])),
            ]))
      ]);
    }));
  }
}
