import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/alert.custom.dart';
import 'package:wallet/scenes/components/bottom.sheets/base.dart';
import 'package:wallet/scenes/components/button.v5.dart';
import 'package:wallet/scenes/components/close.button.v1.dart';
import 'package:wallet/theme/theme.font.dart';

class ErrorBottomSheet {
  static void show(
    BuildContext context,
    String errorMessage,
    VoidCallback? callback,
  ) {
    HomeModalBottomSheet.show(context,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
                alignment: Alignment.centerRight,
                child: CloseButtonV1(onPressed: () {
                  Navigator.of(context).pop();
                })),
            Transform.translate(
                offset: const Offset(0, -20),
                child: Column(children: [
                  SvgPicture.asset("assets/images/icon/delete_warning.svg",
                      fit: BoxFit.fill, width: 52, height: 52),
                  const SizedBox(height: 10),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: defaultPadding),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              S.of(context).something_went_wrong,
                              style: FontManager.titleHeadline(
                                  ProtonColors.textNorm),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: AlertCustom(
                                  content: errorMessage,
                                  canClose: false,
                                  border: Border.all(
                                    color: Colors.transparent,
                                    width: 0,
                                  ),
                                  backgroundColor: ProtonColors.errorBackground,
                                  color: ProtonColors.signalError,
                                )),
                            const SizedBox(height: 20),
                            ButtonV5(
                                onPressed: () async {
                                  callback?.call();
                                  Navigator.of(context).pop();
                                },
                                backgroundColor: ProtonColors.signalError,
                                text: callback != null
                                    ? S.of(context).report_a_problem
                                    : S.of(context).close,
                                width: MediaQuery.of(context).size.width,
                                textStyle: FontManager.body1Median(
                                    ProtonColors.backgroundSecondary),
                                height: 48),
                          ])),
                ])),
          ],
        ));
  }
}
