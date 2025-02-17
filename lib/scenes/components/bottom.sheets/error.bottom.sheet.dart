import 'package:flutter/material.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/bottom.sheets/base.dart';
import 'package:wallet/scenes/components/button.v5.dart';
import 'package:wallet/scenes/components/close.button.v1.dart';

class ErrorBottomSheet {
  static List<String> existingSheets = [];

  static void show(
    BuildContext context,
    String errorMessage,
    VoidCallback? callback,
  ) {
    /// use errorMessage as unique id
    final id = errorMessage;

    /// avoid to display same errorMessage twice
    if (existingSheets.contains(id)) {
      return;
    }

    /// add id to cached list
    existingSheets.add(id);

    HomeModalBottomSheet.show(context, onFinish: () {
      /// remove id from cached list
      existingSheets.remove(id);
    },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
                alignment: Alignment.centerRight,
                child: CloseButtonV1(onPressed: () {
                  callback?.call();
                  Navigator.of(context).pop();
                })),
            Transform.translate(
                offset: const Offset(0, -20),
                child: Column(children: [
                  Assets.images.icon.errorMessage.svg(
                    fit: BoxFit.fill,
                    width: 48,
                    height: 48,
                  ),
                  const SizedBox(height: defaultPadding),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: defaultPadding),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              S.of(context).something_went_wrong,
                              style: ProtonStyles.headline(
                                  color: ProtonColors.textNorm),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                errorMessage,
                                style: ProtonStyles.body2Medium(
                                    color: ProtonColors.notificationError,
                                    fontSize: 15.0),
                                maxLines: 10,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ButtonV5(
                                onPressed: () async {
                                  callback?.call();
                                  Navigator.of(context).pop();
                                },
                                backgroundColor: ProtonColors.interActionWeak,
                                text: callback != null
                                    ? S.of(context).report_a_problem
                                    : S.of(context).close,
                                width: MediaQuery.of(context).size.width,
                                textStyle: ProtonStyles.body1Medium(
                                  color: ProtonColors.textNorm,
                                ),
                                height: 55),
                          ])),
                ])),
          ],
        ));
  }
}
