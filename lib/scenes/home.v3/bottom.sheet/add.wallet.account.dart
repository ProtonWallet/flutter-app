import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet/components/bottom.sheets/placeholder.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/components/close.button.v1.dart';
import 'package:wallet/components/dropdown.button.v2.dart';
import 'package:wallet/components/textfield.text.v2.dart';
import 'package:wallet/components/underline.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/script_type.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/fiat.currency.helper.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/components/bottom.sheets/base.dart';
import 'package:wallet/managers/wallet/proton.wallet.manager.dart';
import 'package:wallet/scenes/home.v3/home.viewmodel.dart';
import 'package:wallet/theme/theme.font.dart';

class AddWalletAccountSheet {
  static void show(
      BuildContext context, HomeViewModel viewModel, WalletModel walletModel) {
    Future.delayed(const Duration(milliseconds: 100), () {
      viewModel.newAccountNameFocusNode.requestFocus();
    });
    HomeModalBottomSheet.show(context,
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                  alignment: Alignment.centerRight,
                  child: CloseButtonV1(onPressed: () {
                    Navigator.of(context).pop();
                  })),
              Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: defaultPadding),
                      child: TextFieldTextV2(
                        labelText: S.of(context).account_label,
                        maxLength: maxWalletNameSize,
                        textController: viewModel.newAccountNameController,
                        myFocusNode: viewModel.newAccountNameFocusNode,
                        validation: (String newAccountName) {
                          bool accountNameExists = false;
                          for (AccountModel accountModel
                              in Provider.of<ProtonWalletProvider>(context,
                                      listen: false)
                                  .protonWallet
                                  .getAccounts(walletModel)) {
                            if (accountModel.labelDecrypt == newAccountName) {
                              accountNameExists = true;
                            }
                          }
                          if (accountNameExists) {
                            return S.of(context).account_name_already_used;
                          }
                          return "";
                        },
                      ),
                    ),
                    ExpansionTile(
                        shape: const Border(),
                        initiallyExpanded: false,
                        title: Text(S.of(context).advanced_options,
                            style:
                                FontManager.body2Median(ProtonColors.textWeak)),
                        iconColor: ProtonColors.textHint,
                        collapsedIconColor: ProtonColors.textHint,
                        children: [
                          DropdownButtonV2(
                              labelText:
                                  S.of(context).setting_fiat_currency_label,
                              width: MediaQuery.of(context).size.width -
                                  defaultPadding * 4,
                              items: fiatCurrencies,
                              itemsText: fiatCurrencies
                                  .map((v) => FiatCurrencyHelper.getFullName(v))
                                  .toList(),
                              valueNotifier: viewModel.fiatCurrencyNotifier),
                          const SizedBox(height: 12),
                          DropdownButtonV2(
                              labelText: S.of(context).script_type,
                              width: MediaQuery.of(context).size.width -
                                  defaultPadding * 4,
                              items: ScriptType.scripts,
                              itemsText: ScriptType.scripts
                                  .map((v) => v.name)
                                  .toList(),
                              valueNotifier:
                                  viewModel.newAccountScriptTypeValueNotifier),
                          const SizedBox(height: 4),
                          Underline(
                              onTap: () {
                                CustomPlaceholder.show(context);
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
                        child: ButtonV5(
                            onPressed: () async {
                              String newAccountName = viewModel
                                      .newAccountNameController.text.isNotEmpty
                                  ? viewModel.newAccountNameController.text
                                  : S.of(context).default_account;
                              bool accountNameExists = false;
                              if (context.mounted) {
                                for (AccountModel accountModel
                                    in Provider.of<ProtonWalletProvider>(
                                            context,
                                            listen: false)
                                        .protonWallet
                                        .getAccounts(walletModel)) {
                                  if (accountModel.labelDecrypt ==
                                      newAccountName) {
                                    accountNameExists = true;
                                  }
                                }
                                if (accountNameExists == false) {
                                  await viewModel.addWalletAccount(
                                      walletModel.id!,
                                      viewModel
                                          .newAccountScriptTypeValueNotifier
                                          .value,
                                      viewModel.newAccountNameController.text
                                              .isNotEmpty
                                          ? viewModel
                                              .newAccountNameController.text
                                          : S.of(context).default_account);
                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                    CommonHelper.showSnackbar(
                                        context, S.of(context).account_created);
                                  }
                                }
                              }
                            },
                            backgroundColor: ProtonColors.protonBlue,
                            text: S.of(context).add_account,
                            width: MediaQuery.of(context).size.width,
                            textStyle: FontManager.body1Median(
                                ProtonColors.backgroundSecondary),
                            height: 48)),
                  ])
            ]));
  }
}
