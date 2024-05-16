import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:wallet/components/add.button.v1.dart';
import 'package:wallet/components/alert.custom.dart';
import 'package:wallet/components/bottom.sheets/placeholder.dart';
import 'package:wallet/components/close.button.v1.dart';
import 'package:wallet/components/dropdown.button.v2.dart';
import 'package:wallet/components/textfield.text.v2.dart';
import 'package:wallet/components/underline.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/fiat.currency.helper.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/provider/proton.wallet.provider.dart';
import 'package:wallet/scenes/home.v3/bottom.sheet/advance.wallet.account.setting.dart';
import 'package:wallet/scenes/home.v3/bottom.sheet/advance.wallet.setting.dart';
import 'package:wallet/components/bottom.sheets/base.dart';
import 'package:wallet/scenes/home.v3/bottom.sheet/email.integration.dropdown.dart';
import 'package:wallet/scenes/home.v3/home.viewmodel.dart';
import 'package:wallet/theme/theme.font.dart';

class WalletSettingSheet {
  static void show(BuildContext context, HomeViewModel viewModel) {
    List<AccountModel> userAccounts =
        Provider.of<ProtonWalletProvider>(context, listen: false)
            .protonWallet
            .currentAccounts;

    Map<int, TextEditingController> accountNameControllers =
        viewModel.getAccountNameControllers(userAccounts);

    ScrollController scrollController = ScrollController();
    Map<int, FocusNode> accountNameFocusNodes = {
      for (var item in userAccounts) item.id!: FocusNode()
    };
    for (AccountModel item in userAccounts) {
      accountNameFocusNodes[item.id!]!.addListener(() {
        if (accountNameFocusNodes[item.id!]!.hasFocus) {
          scrollController.jumpTo(scrollController.offset +
              MediaQuery.of(context).viewInsets.bottom);
        }
      });
    }
    Map<int, bool> emailIntegrationEnables = {
      for (var accountModel in userAccounts)
        accountModel.id!:
            Provider.of<ProtonWalletProvider>(context, listen: false)
                .protonWallet
                .getIntegratedEmailIDs(accountModel)
                .isNotEmpty
    };
    Map<int, ValueNotifier> _ = {
      for (var item in userAccounts)
        item.id!: ValueNotifier(viewModel.protonAddresses.firstOrNull)
    };
    HomeModalBottomSheet.show(context,
        scrollController: scrollController, child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CloseButtonV1(onPressed: () {
            Navigator.of(context).pop();
          }),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20,
              ),
              TextFieldTextV2(
                labelText: S.of(context).wallet_name,
                textController: viewModel.walletNameController,
                myFocusNode: viewModel.walletNameFocusNode,
                onFinish: () async {
                  await viewModel.updateWalletName(
                      Provider.of<ProtonWalletProvider>(context, listen: false)
                          .protonWallet
                          .currentWallet!
                          .serverWalletID,
                      viewModel.walletNameController.text);
                  if (context.mounted) {
                    await DBHelper.walletDao!.update(
                        Provider.of<ProtonWalletProvider>(context,
                                listen: false)
                            .protonWallet
                            .currentWallet!);
                  }
                },
                validation: (String value) {
                  if (value.isEmpty) {
                    return "Required";
                  }
                  return "";
                },
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: ProtonColors.white,
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  child: Column(children: [
                    const SizedBox(
                      height: 10,
                    ),
                    DropdownButtonV2(
                        labelText: S.of(context).setting_bitcoin_unit_label,
                        width: MediaQuery.of(context).size.width -
                            defaultPadding * 2,
                        items: bitcoinUnits,
                        itemsText: bitcoinUnits
                            .map((v) => v.name.toUpperCase())
                            .toList(),
                        valueNotifier: viewModel.bitcoinUnitNotifier),
                    const SizedBox(
                      height: 10,
                    ),
                  ])),
              Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: ProtonColors.white,
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  child: Column(children: [
                    const SizedBox(
                      height: 10,
                    ),
                    DropdownButtonV2(
                        labelText: S.of(context).setting_fiat_currency_label,
                        width: MediaQuery.of(context).size.width -
                            defaultPadding * 2,
                        items: fiatCurrencies,
                        itemsText: fiatCurrencies
                            .map((v) => FiatCurrencyHelper.getName(v))
                            .toList(),
                        valueNotifier: viewModel.fiatCurrencyNotifier),
                    const SizedBox(
                      height: 10,
                    ),
                  ])),
              const SizedBox(
                height: defaultPadding,
              ),
              Text(S.of(context).accounts,
                  style: FontManager.body2Median(ProtonColors.textNorm)),
              const SizedBox(
                height: defaultPadding,
              ),
              AlertCustom(
                content: S.of(context).receive_email_integration_alert_content,
                learnMore: Underline(
                    onTap: () {
                      CustomPlaceholder.show(context);
                    },
                    color: ProtonColors.orange1Text,
                    child: Text(S.of(context).learn_more,
                        style:
                            FontManager.body2Median(ProtonColors.orange1Text))),
                leadingWidget: SvgPicture.asset("assets/images/icon/send_2.svg",
                    fit: BoxFit.fill, width: 30, height: 30),
                border: Border.all(
                  color: Colors.transparent,
                  width: 0,
                ),
                backgroundColor: ProtonColors.orange1Background,
                color: ProtonColors.orange1Text,
              ),
              const SizedBox(
                height: defaultPadding,
              ),
              for (AccountModel userAccount
                  in Provider.of<ProtonWalletProvider>(context)
                      .protonWallet
                      .currentAccounts)
                Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: ProtonColors.white,
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    child: Column(children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                                width: MediaQuery.of(context).size.width -
                                    defaultPadding * 2 -
                                    50,
                                child: TextFieldTextV2(
                                  labelText: S.of(context).account_label,
                                  textController:
                                      accountNameControllers[userAccount.id!]!,
                                  myFocusNode:
                                      accountNameFocusNodes[userAccount.id!]!,
                                  onFinish: () async {
                                    viewModel.renameAccount(
                                        userAccount,
                                        accountNameControllers[userAccount.id!]!
                                            .text);
                                  },
                                  validation: (String value) {
                                    if (value.isEmpty) {
                                      return "Required";
                                    }
                                    return "";
                                  },
                                )),
                            Container(
                                width: 50,
                                padding: const EdgeInsets.only(right: 10),
                                child: CircleAvatar(
                                    radius: 30,
                                    backgroundColor:
                                        ProtonColors.backgroundProton,
                                    child: IconButton(
                                      onPressed: () {
                                        AdvanceWalletAccountSettingSheet.show(
                                            context,
                                            viewModel,
                                            userAccount,
                                            userAccounts.length > 1);
                                      },
                                      icon: Icon(Icons.more_horiz_rounded,
                                          size: 20,
                                          color: ProtonColors.textNorm),
                                    )))
                          ]),
                      const Divider(
                        thickness: 0.2,
                        height: 1,
                      ),
                      const SizedBox(height: 10),
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: defaultPadding),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(S.of(context).email_integration,
                                    style: FontManager.body2Regular(
                                        ProtonColors.textNorm)),
                                CupertinoSwitch(
                                  value: emailIntegrationEnables[
                                          userAccount.id!] ??
                                      false,
                                  activeColor: ProtonColors.protonBlue,
                                  onChanged: (bool newValue) {
                                    setState(() {
                                      emailIntegrationEnables[userAccount.id!] =
                                          newValue;
                                    });
                                  },
                                )
                              ])),
                      const SizedBox(height: 10),
                      if (emailIntegrationEnables[userAccount.id!]!)
                        for (String addressID
                            in Provider.of<ProtonWalletProvider>(context)
                                .protonWallet
                                .getIntegratedEmailIDs(userAccount))
                          Container(
                              margin: const EdgeInsets.only(bottom: 5),
                              child: ListTile(
                                title: Text(
                                    viewModel
                                        .getProtonAddressByID(addressID)!
                                        .email,
                                    style: FontManager.body2Regular(
                                        ProtonColors.textNorm)),
                                trailing: IconButton(
                                  onPressed: () async {
                                    await viewModel.removeEmailAddress(
                                        Provider.of<ProtonWalletProvider>(
                                                context,
                                                listen: false)
                                            .protonWallet
                                            .currentWallet!
                                            .serverWalletID,
                                        userAccount.serverAccountID,
                                        addressID);
                                  },
                                  icon: const Icon(Icons.close),
                                ),
                              )),
                      if (emailIntegrationEnables[userAccount.id!]!)
                        GestureDetector(
                            onTap: () {
                              EmailIntegrationDropdownSheet.show(
                                  context, viewModel, userAccount);
                            },
                            child: Row(children: [
                              const SizedBox(width: defaultPadding),
                              const AddButtonV1(),
                              const SizedBox(width: 5),
                              Text(S.of(context).add,
                                  style: FontManager.body2Regular(
                                      ProtonColors.protonBlue)),
                            ])),
                      // if (emailIntegrationEnables[userAccount.id!]! &&
                      //     viewModel.protonAddresses.isNotEmpty)
                      //   Row(
                      //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //       children: [
                      //         DropdownButtonV2(
                      //           labelText: S.of(context).add_email_to_account,
                      //           items: viewModel.protonAddresses,
                      //           itemsText: viewModel.protonAddresses
                      //               .map((e) => e.email)
                      //               .toList(),
                      //           valueNotifier:
                      //               emailIntegrationNotifiers[userAccount.id!],
                      //           width: MediaQuery.of(context).size.width - 120,
                      //         ),
                      //         GestureDetector(
                      //             onTap: () async {
                      //               await viewModel
                      //                   .addEmailAddressToWalletAccount(
                      //                       Provider.of<ProtonWalletProvider>(
                      //                               context,
                      //                               listen: false)
                      //                           .protonWallet
                      //                           .currentWallet!
                      //                           .serverWalletID,
                      //                       userAccount.serverAccountID,
                      //                       emailIntegrationNotifiers[
                      //                               userAccount.id!]!
                      //                           .value
                      //                           .id);
                      //             },
                      //             child: Padding(
                      //                 padding: const EdgeInsets.only(
                      //                     right: defaultPadding),
                      //                 child: Container(
                      //                   width: 60,
                      //                   height: 40,
                      //                   alignment: Alignment.center,
                      //                   decoration: BoxDecoration(
                      //                     color: ProtonColors.protonBlue,
                      //                     borderRadius:
                      //                         BorderRadius.circular(20.0),
                      //                   ),
                      //                   child: Text(S.of(context).add,
                      //                       style: FontManager.body2Regular(
                      //                           ProtonColors.white)),
                      //                 ))),
                      //       ]),
                      const SizedBox(height: 20),
                    ])),
              const SizedBox(
                height: defaultPadding,
              ),
              ListTile(
                shape: const Border(),
                leading: SvgPicture.asset("assets/images/icon/ic-cog-wheel.svg",
                    fit: BoxFit.fill, width: 20, height: 20),
                title: Text(S.of(context).advanced_options,
                    style: FontManager.body2Median(ProtonColors.textNorm)),
                onTap: () {
                  AdvanceWalletSettingSheet.show(context, viewModel);
                },
                iconColor: ProtonColors.textHint,
              ),
              const SizedBox(
                height: defaultPadding,
              ),
            ],
          )
        ],
      );
    }));
  }
}
