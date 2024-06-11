import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wallet/components/bottom.sheets/base.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/components/close.button.v1.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/home.v3/home.viewmodel.dart';
import 'package:wallet/theme/theme.font.dart';

class UpgradeIntroSheet {
  static void show(BuildContext context, HomeViewModel viewModel) {
    HomeModalBottomSheet.show(context, child:
        StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
                alignment: Alignment.centerRight,
                child: CloseButtonV1(onPressed: () {
                  Navigator.of(context).pop();
                })),
            Transform.translate(
                offset: const Offset(0, -20),
                child: Column(children: [
                  SvgPicture.asset(
                      "assets/images/icon/upgrade_intro.svg",
                      fit: BoxFit.fill,
                      width: 240,
                      height: 240),
                  const SizedBox(height: 20),
                  Text(
                    S.of(context).upgrade_intro_title,
                    style: FontManager.titleHeadline(ProtonColors.textNorm),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    S.of(context).upgrade_intro_content,
                    style: FontManager.body2Regular(ProtonColors.textWeak),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: defaultPadding),
                      child: Column(children: [
                        ButtonV5(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              EasyLoading.show(
                                  status: "child session..",
                                  maskType: EasyLoadingMaskType.black);
                              await viewModel.move(NavID.nativeUpgrade);
                              EasyLoading.dismiss();
                            },
                            text: S.of(context).upgrade_now,
                            width: MediaQuery.of(context).size.width,
                            textStyle:
                                FontManager.body1Median(ProtonColors.white),
                            backgroundColor: ProtonColors.protonBlue,
                            borderColor: ProtonColors.protonBlue,
                            height: 48),
                      ])),
                ]))
          ]);
    }));
  }
}
