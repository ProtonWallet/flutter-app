import 'package:flutter/material.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/components/dropdown.button.v2.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/helper/fiat.currency.helper.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/components/bottom.sheets/base.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/home.v3/home.viewmodel.dart';
import 'package:wallet/theme/theme.font.dart';

class OnboardingGuideSheet {
  static void show(BuildContext context, HomeViewModel viewModel) {
    HomeModalBottomSheet.show(context, child:
        StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12),
            Text(S.of(context).wallet_setup, style: FontManager.titleHeadline(ProtonColors.textNorm)),
            Text(S.of(context).wallet_setup_desc, style: FontManager.body2Regular(ProtonColors.textWeak), textAlign: TextAlign.center,),
            const SizedBox(height: 30),
            DropdownButtonV2(
                labelText: S.of(context).setting_fiat_currency_label,
                width: MediaQuery.of(context).size.width -
                    defaultPadding * 2,
                items: fiatCurrencies,
                itemsText: fiatCurrencies
                    .map((v) => FiatCurrencyHelper.getName(v))
                    .toList(),
                valueNotifier: viewModel.fiatCurrencyNotifier),
            const SizedBox(height: 30),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal:   defaultPadding),
                child: Column(children: [
                  ButtonV5(
                      onPressed: () {
                        viewModel.move(NavID.setupCreate);
                      },
                      text: S.of(context).create_new_wallet,
                      width: MediaQuery.of(context).size.width,
                      textStyle: FontManager.body1Median(ProtonColors.white),
                      backgroundColor: ProtonColors.protonBlue,
                      height: 48),
                  SizedBoxes.box12,
                  GestureDetector(
                    onTap: () {
                      viewModel.move(NavID.importWallet);
                    },
                    child: Container(
                        margin: const EdgeInsets.only(top: 5),
                        width: MediaQuery.of(context).size.width,
                        height: 48,
                        child: Text(
                          S.of(context).import_your_wallet,
                          style: FontManager.body1Median(
                              ProtonColors.textWeak),
                          textAlign: TextAlign.center,
                        )),
                  ),
                ])),
          ]);
    }));
  }
}
