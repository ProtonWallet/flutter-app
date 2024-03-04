import 'package:flutter/material.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/components/text.choices.dart';
import 'package:wallet/components/textfield.text.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/settings/settings.account.view.dart';
import 'package:wallet/scenes/settings/settings.common.view.dart';
import 'package:wallet/scenes/settings/settings.viewmodel.dart';
import 'package:flutter_gen/gen_l10n/locale.dart';
import 'package:wallet/theme/theme.font.dart';

class SettingsView extends ViewBase<SettingsViewModel> {
  SettingsView(SettingsViewModel viewModel)
      : super(viewModel, const Key("SettingsView"));

  @override
  Widget buildWithViewModel(
      BuildContext context, SettingsViewModel viewModel, ViewSize viewSize) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.account_balance_wallet),
            onPressed: () {
              logger.d("appBar icon butttion clicked");
            },
          ),
          // Theme.of(context).colorScheme.inversePrimary,
          backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
          forceMaterialTransparency: true,
          title: Text(S.of(context).settings_title,
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const AccountInfo(),
                  const SizedBox(
                    height: 5,
                  ),
                  const CommonSettings(),
                  Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      margin: const EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(S.of(context).setting_bitcoin_unit_label,
                              style: FontManager.body1Regular(
                                  ProtonColors.textNorm)),
                          TextChoices(
                              choices: [
                                CommonBitcoinUnit.sats.name.toUpperCase(),
                                CommonBitcoinUnit.mbtc.name.toUpperCase(),
                                CommonBitcoinUnit.btc.name.toUpperCase(),
                              ],
                              selectedValue:
                                  viewModel.bitcoinUnitController.text,
                              controller: viewModel.bitcoinUnitController),
                        ],
                      )),
                  Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      margin: const EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(S.of(context).setting_fiat_currency_label,
                              style: FontManager.body1Regular(
                                  ProtonColors.textNorm)),
                          TextChoices(
                              choices: [
                                ApiFiatCurrency.usd.name.toUpperCase(),
                                ApiFiatCurrency.eur.name.toUpperCase(),
                                ApiFiatCurrency.chf.name.toUpperCase(),
                              ],
                              selectedValue:
                                  viewModel.faitCurrencyController.text,
                              controller: viewModel.faitCurrencyController),
                        ],
                      )),
                  Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      margin: const EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              S
                                  .of(context)
                                  .setting_hide_empty_used_address_label,
                              style: FontManager.body1Regular(
                                  ProtonColors.textNorm)),
                          TextChoices(
                              choices: [
                                S.of(context).setting_option_off,
                                S.of(context).setting_option_on
                              ],
                              selectedValue: viewModel.hideEmptyUsedAddresses
                                  ? S.of(context).setting_option_on
                                  : S.of(context).setting_option_off,
                              controller:
                                  viewModel.hideEmptyUsedAddressesController),
                        ],
                      )),
                  Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      margin: const EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(S.of(context).setting_2fa_amount_threshold_label,
                              style: FontManager.body1Regular(
                                  ProtonColors.textNorm)),
                          TextFieldText(
                            width: 200,
                            height: 50,
                            color: ProtonColors.backgroundSecondary,
                            showSuffixIcon: false,
                            showEnabledBorder: false,
                            controller:
                                viewModel.twoFactorAmountThresholdController,
                            digitOnly: true,
                          ),
                        ],
                      )),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 26.0),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: ButtonV5(
                        onPressed: () {
                          viewModel.getUserSettings();
                        },
                        text: "Refresh Setting",
                        width: MediaQuery.of(context).size.width,
                        textStyle: FontManager.body1Median(ProtonColors.white),
                        height: 48),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 26.0),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: ButtonV5(
                        onPressed: () {
                          viewModel.saveUserSettings();
                        },
                        text: "Save Setting",
                        width: MediaQuery.of(context).size.width,
                        textStyle: FontManager.body1Median(ProtonColors.white),
                        height: 48),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 26.0),
                    margin: const EdgeInsets.symmetric(vertical: 30),
                    child: ButtonV5(
                        onPressed: () {
                          viewModel.coordinator
                              .move(ViewIdentifiers.welcome, context);
                        },
                        text: S.of(context).logout.toUpperCase(),
                        width: MediaQuery.of(context).size.width,
                        textStyle: FontManager.body1Median(ProtonColors.white),
                        height: 48),
                  ),
                ]),
          ),
        ));
  }
}
