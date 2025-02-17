import 'package:flutter/material.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/extension/asset.gen.image.extension.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/button.v6.dart';
import 'package:wallet/scenes/components/close.button.v1.dart';
import 'package:wallet/scenes/components/custom.header.dart';
import 'package:wallet/scenes/components/page.layout.v1.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/home.v3/sub.views/import.success/import.success.viewmodel.dart';

class ImportSuccessView extends ViewBase<ImportSuccessViewModel> {
  const ImportSuccessView(ImportSuccessViewModel viewModel)
      : super(viewModel, const Key("ImportSuccessView"));

  @override
  Widget build(BuildContext context) {
    return PageLayoutV1(
      headerWidget: CustomHeader(
        buttonDirection: AxisDirection.right,
        padding: const EdgeInsets.all(0.0),
        button: CloseButtonV1(
            backgroundColor: ProtonColors.backgroundNorm,
            onPressed: () {
              Navigator.of(context).pop();
            }),
      ),
      backgroundColor: ProtonColors.backgroundSecondary,
      child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
        return Column(mainAxisSize: MainAxisSize.min, children: [
          Transform.translate(
              offset: const Offset(0, -20),
              child: Column(children: [
                Assets.images.icon.bitcoinBigIcon
                    .applyThemeIfNeeded(context)
                    .image(
                      fit: BoxFit.fill,
                      width: 240,
                      height: 167,
                    ),
                Text(
                  S.of(context).welcome_to,
                  style: ProtonStyles.headline(color: ProtonColors.textNorm),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  S.of(context).import_success_welcome,
                  style:
                      ProtonStyles.body2Regular(color: ProtonColors.textWeak),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: defaultPadding),
                    child: Column(children: [
                      ButtonV6(
                          onPressed: () async {
                            await viewModel.userSettingsDataProvider
                                .acceptTermsAndConditions();
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                          text: S.of(context).continue_buttion,
                          width: MediaQuery.of(context).size.width,
                          textStyle: ProtonStyles.body1Medium(
                              color: ProtonColors.textInverted),
                          backgroundColor: ProtonColors.protonBlue,
                          borderColor: ProtonColors.protonBlue,
                          height: 55),
                    ])),
              ]))
        ]);
      }),
    );
  }
}
