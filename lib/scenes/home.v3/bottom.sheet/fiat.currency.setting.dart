import 'package:flutter/material.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/components/dropdown.button.v2.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/fiat.currency.helper.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/home.v3/bottom.sheet/base.dart';
import 'package:wallet/scenes/home.v3/home.viewmodel.dart';
import 'package:wallet/theme/theme.font.dart';

class FiatCurrencySettingSheet {
  static void show(BuildContext context, HomeViewModel viewModel) {
    HomeModalBottomSheet.show(context, viewModel, child:
        StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12),
            DropdownButtonV2(
                labelText: S.of(context).setting_fiat_currency_label,
                width: MediaQuery.of(context).size.width -
                    defaultPadding * 2,
                items: fiatCurrencies,
                itemsText: fiatCurrencies
                    .map((v) => FiatCurrencyHelper.getText(v))
                    .toList(),
                valueNotifier: viewModel.fiatCurrencyNotifier),
            Container(
                padding: const EdgeInsets.only(top: 20),
                margin: const EdgeInsets.symmetric(
                    horizontal: defaultButtonPadding),
                child: ButtonV5(
                    onPressed: () {
                      viewModel.updateFiatCurrency(
                          viewModel.fiatCurrencyNotifier.value);
                      viewModel.saveUserSettings();
                      Navigator.pop(context);
                    },
                    backgroundColor: ProtonColors.protonBlue,
                    text: S.of(context).save,
                    width: MediaQuery.of(context).size.width,
                    textStyle: FontManager.body1Median(
                        ProtonColors.backgroundSecondary),
                    height: 48)),
          ]);
    }));
  }
}
