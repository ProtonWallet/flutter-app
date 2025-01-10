import 'package:flutter/material.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/extension/build.context.extension.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/bottom.sheets/base.dart';
import 'package:wallet/scenes/components/button.v5.dart';
import 'package:wallet/scenes/components/close.button.v1.dart';

class InfoBottomSheet {
  static void show(
    BuildContext context,
    String errorMessage,
    VoidCallback? callback,
  ) {
    HomeModalBottomSheet.show(
      context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: CloseButtonV1(onPressed: () {
              callback?.call();
              Navigator.of(context).pop();
            }),
          ),
          Transform.translate(
            offset: const Offset(0, -20),
            child: Column(children: [
              Assets.images.icon.icInfoCircle.svg(
                fit: BoxFit.fill,
                width: 52,
                height: 52,
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 10,
                        left: 6,
                        right: 6,
                      ),
                      child: Text(
                        errorMessage,
                        style: ProtonStyles.body2Medium(
                          color: ProtonColors.textNorm,
                          fontSize: 15.0,
                        ),
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
                      backgroundColor: ProtonColors.protonBlue,
                      text: callback != null
                          ? S.of(context).report_a_problem
                          : S.of(context).close,
                      width: context.width,
                      textStyle: ProtonStyles.body1Medium(
                        color: ProtonColors.textInverted,
                      ),
                      height: 48,
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
