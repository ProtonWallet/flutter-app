import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallet/constants/app.config.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/script_type.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/external.url.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/managers/features/wallet.list/wallet.list.dart';
import 'package:wallet/scenes/components/bottom.sheets/base.dart';
import 'package:wallet/scenes/components/button.v5.dart';
import 'package:wallet/scenes/components/button.v6.dart';
import 'package:wallet/scenes/components/close.button.v1.dart';
import 'package:wallet/scenes/components/dropdown.button.v2.dart';
import 'package:wallet/scenes/components/textfield.text.v2.dart';
import 'package:wallet/scenes/components/underline.dart';
import 'package:wallet/scenes/home.v3/home.viewmodel.dart';
import 'package:wallet/theme/theme.font.dart';

// TODO(fix): refactor this to a sperate view and viewmodel. dont need to share the viewmodel with the home viewmodel
class AddWalletAccountSheet {
  static Future<void> show(BuildContext context, HomeViewModel viewModel,
      WalletMenuModel walletMenuModel) async {
    final int accountIndex = await viewModel
        .dataProviderManager.walletDataProvider
        .getNewDerivationAccountIndex(
      walletMenuModel.walletModel.walletID,
      appConfig.scriptTypeInfo,
      appConfig.coinType,
    );
    final ValueNotifier newAccountScriptTypeValueNotifier =
        ValueNotifier(appConfig.scriptTypeInfo);
    final TextEditingController newAccountNameController =
        TextEditingController(text: "Account $accountIndex");
    final TextEditingController newAccountIndexController =
        TextEditingController(text: accountIndex.toString());

    final FocusNode newAccountNameFocusNode = FocusNode();
    final FocusNode newAccountIndexFocusNode = FocusNode();
    Future.delayed(const Duration(milliseconds: 100),
        newAccountNameFocusNode.requestFocus);
    bool isAdding = false;
    if (context.mounted) {
      HomeModalBottomSheet.show(context, child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
        newAccountScriptTypeValueNotifier.addListener(() async {
          final int accountIndex = await viewModel
              .dataProviderManager.walletDataProvider
              .getNewDerivationAccountIndex(
            walletMenuModel.walletModel.walletID,
            newAccountScriptTypeValueNotifier.value,
            appConfig.coinType,
          );
          newAccountIndexController.text = accountIndex.toString();
        });
        return Column(mainAxisSize: MainAxisSize.min, children: [
          Align(
              alignment: Alignment.centerRight,
              child: CloseButtonV1(onPressed: () {
                Navigator.of(context).pop();
              })),
          Column(mainAxisSize: MainAxisSize.min, children: [
            Text(S.of(context).add_wallet_account,
                style: FontManager.body1Median(ProtonColors.textNorm)),
            const SizedBox(height: 5),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: Text(
                  S.of(context).add_wallet_account_desc,
                  style: FontManager.body2Regular(ProtonColors.textWeak),
                  textAlign: TextAlign.center,
                )),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: TextFieldTextV2(
                labelText: S.of(context).name,
                maxLength: maxWalletNameSize,
                textController: newAccountNameController,
                myFocusNode: newAccountNameFocusNode,
                validation: (String newAccountName) {
                  // bool accountNameExists = false;
                  // TODO(fix): check if accountName already used
                  // if (accountNameExists) {
                  //   return S.of(context).account_name_already_used;
                  // }
                  return "";
                },
              ),
            ),
            ExpansionTile(
                shape: const Border(),
                title: Text(S.of(context).advanced_settings,
                    style: FontManager.body2Median(ProtonColors.textWeak)),
                iconColor: ProtonColors.textHint,
                collapsedIconColor: ProtonColors.textHint,
                children: [
                  // DropdownButtonV2(
                  //     labelText:
                  //         S.of(context).setting_fiat_currency_label,
                  //     width: MediaQuery.of(context).size.width -
                  //         defaultPadding * 4,
                  //     items: fiatCurrencies,
                  //     canSearch: true,
                  //     itemsText: fiatCurrencies
                  //         .map((v) => FiatCurrencyHelper.getFullName(v))
                  //         .toList(),
                  //     valueNotifier: viewModel.fiatCurrencyNotifier),
                  // const SizedBox(height: 12),
                  Text(S.of(context).script_type,
                      style: FontManager.body1Median(ProtonColors.textNorm)),
                  const SizedBox(height: 5),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: defaultPadding),
                      child: Text(
                        S.of(context).wallet_account_script_type_desc,
                        style: FontManager.body2Regular(ProtonColors.textWeak),
                        textAlign: TextAlign.center,
                      )),
                  const SizedBox(height: 20),
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: defaultPadding,
                    ),
                    child: DropdownButtonV2(
                      labelText: S.of(context).script_type,
                      width: MediaQuery.of(context).size.width -
                          defaultPadding * 4,
                      items: ScriptTypeInfo.scripts,
                      itemsText:
                          ScriptTypeInfo.scripts.map((v) => v.name).toList(),
                      itemsMoreDetail: ScriptTypeInfo.scripts.map((v) {
                        switch (v.bipVersion) {
                          case 44:
                            return S
                                .of(context)
                                .wallet_account_script_type_desc_bip44;
                          case 49:
                            return S
                                .of(context)
                                .wallet_account_script_type_desc_bip49;
                          case 84:
                            return S
                                .of(context)
                                .wallet_account_script_type_desc_bip84;
                          case 86:
                            return S
                                .of(context)
                                .wallet_account_script_type_desc_bip86;
                          default:
                            return "TODO";
                        }
                      }).toList(),
                      valueNotifier: newAccountScriptTypeValueNotifier,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Underline(
                      onTap: () {
                        ExternalUrl.shared.launchBlogAddressType();
                      },
                      color: ProtonColors.protonBlue,
                      child: Text(S.of(context).learn_more,
                          style: FontManager.body2Median(
                              ProtonColors.protonBlue))),
                  const SizedBox(height: 20),
                  Text(S.of(context).wallet_account_index,
                      style: FontManager.body1Median(ProtonColors.textNorm)),
                  const SizedBox(height: 5),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: defaultPadding),
                      child: Text(
                        S.of(context).wallet_account_index_desc,
                        style: FontManager.body2Regular(ProtonColors.textWeak),
                        textAlign: TextAlign.center,
                      )),
                  const SizedBox(height: 20),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: defaultPadding),
                    child: TextFieldTextV2(
                      labelText: S.of(context).wallet_account_index,
                      maxLength: maxWalletNameSize,
                      textController: newAccountIndexController,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^[0-9]\d*')),
                      ],
                      myFocusNode: newAccountIndexFocusNode,
                      validation: (String newAccountName) {
                        // bool accountNameExists = false;
                        // TODO(fix): check if accountName already used
                        // if (accountNameExists) {
                        //   return S
                        //       .of(context)
                        //       .account_name_already_used;
                        // }
                        return "";
                      },
                    ),
                  ),
                  Underline(
                      onTap: () {
                        ExternalUrl.shared.launchBlogAccountIndex();
                      },
                      color: ProtonColors.protonBlue,
                      child: Text(S.of(context).learn_more,
                          style: FontManager.body2Median(
                              ProtonColors.protonBlue))),
                ]),
            const SizedBox(height: 12),
            Container(
                padding: const EdgeInsets.only(top: 20),
                margin: const EdgeInsets.symmetric(
                    horizontal: defaultButtonPadding),
                child: Column(children: [
                  ButtonV6(
                      onPressed: () async {
                        if (!isAdding) {
                          isAdding = true;
                          int newAccountIndex = 0;
                          try {
                            newAccountIndex =
                                int.parse(newAccountIndexController.text);
                          } catch (e) {
                            // parse newAccountIndex failed, use default one
                          }
                          const bool accountNameExists = false;
                          if (context.mounted) {
                            // TODO(fix): check if accountName already used
                            if (!accountNameExists) {
                              final bool isSuccess =
                                  await viewModel.addWalletAccount(
                                walletMenuModel.walletModel.id,
                                walletMenuModel.walletModel.walletID,
                                newAccountScriptTypeValueNotifier.value,
                                newAccountNameController.text.isNotEmpty
                                    ? newAccountNameController.text
                                    : S.of(context).default_account,
                                newAccountIndex,
                              );
                              if (context.mounted && isSuccess) {
                                Navigator.of(context).pop();
                                if (isSuccess) {
                                  CommonHelper.showSnackbar(
                                      context, S.of(context).account_created);
                                }
                              }
                            }
                          }
                          isAdding = false;
                        }
                      },
                      backgroundColor: ProtonColors.protonBlue,
                      text: S.of(context).create_wallet_account,
                      width: MediaQuery.of(context).size.width,
                      textStyle: FontManager.body1Median(
                          ProtonColors.backgroundSecondary),
                      height: 48),
                  SizedBoxes.box8,
                  ButtonV5(
                      onPressed: () async {
                        Navigator.of(context).pop();
                      },
                      text: S.of(context).cancel,
                      width: MediaQuery.of(context).size.width,
                      textStyle: FontManager.body1Median(ProtonColors.textNorm),
                      backgroundColor: ProtonColors.textWeakPressed,
                      borderColor: ProtonColors.textWeakPressed,
                      height: 48),
                  SizedBoxes.box8,
                ])),
          ])
        ]);
      }));
    }
  }
}
