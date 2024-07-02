import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wallet/components/add.button.v1.dart';
import 'package:wallet/components/alert.custom.dart';
import 'package:wallet/components/bottom.sheets/placeholder.dart';
import 'package:wallet/components/close.button.v1.dart';
import 'package:wallet/components/dropdown.button.v2.dart';
import 'package:wallet/components/textfield.text.v2.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/avatar.color.helper.dart';
import 'package:wallet/helper/fiat.currency.helper.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/managers/features/models/wallet.list.dart';
import 'package:wallet/managers/features/wallet.list.bloc.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/scenes/home.v3/bottom.sheet/advance.wallet.account.setting.dart';
import 'package:wallet/scenes/home.v3/bottom.sheet/advance.wallet.setting.dart';
import 'package:wallet/components/bottom.sheets/base.dart';
import 'package:wallet/scenes/home.v3/bottom.sheet/email.integration.dropdown.dart';
import 'package:wallet/scenes/home.v3/home.viewmodel.dart';
import 'package:wallet/theme/theme.font.dart';

class WalletSettingSheet {
  static void show(BuildContext context, HomeViewModel viewModel,
      WalletMenuModel walletMenuModel) {
    ScrollController scrollController = ScrollController();
    bool hasEmailIntegration = false;
    Map<String, bool> emailIntegrationEnables = {
      for (var accountMenuModel in walletMenuModel.accounts)
        accountMenuModel.accountModel.serverAccountID:
            accountMenuModel.emailIds.isNotEmpty
    };
    for (var accountMenuModel in walletMenuModel.accounts) {
      if (emailIntegrationEnables[
              accountMenuModel.accountModel.serverAccountID] ??
          false) {
        hasEmailIntegration = true;
        break;
      }
    }
    HomeModalBottomSheet.show(context, scrollController: scrollController,
        child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
      return BlocBuilder<WalletListBloc, WalletListState>(
          bloc: viewModel.walletListBloc,
          builder: (context, state) {
            /// TODO:: change to walletMenuModel

            for (WalletMenuModel walletMenuModel2 in state.walletsModel) {
              if (walletMenuModel.walletModel.serverWalletID ==
                  walletMenuModel2.walletModel.serverWalletID) {
                walletMenuModel =
                    walletMenuModel2; // TODO:: fix this workaround, or the value is old one
                break;
              }
            }
            TextEditingController walletNameController =
                TextEditingController(text: walletMenuModel.walletName);
            FocusNode walletNameFocusNode = FocusNode();
            WalletModel userWallet = walletMenuModel.walletModel;
            List<AccountModel> userAccounts =
                walletMenuModel.accounts.map((e) => e.accountModel).toList();
            Map<String, TextEditingController> accountNameControllers = {
              for (var accountMenuModel in walletMenuModel.accounts)
                accountMenuModel.accountModel.serverAccountID:
                    TextEditingController(text: accountMenuModel.label)
            };
            Map<String, ValueNotifier> accountFiatCurrencyNotifier =
                viewModel.getAccountFiatCurrencyNotifiers(userAccounts);
            Map<String, FocusNode> accountNameFocusNodes = {
              for (var item in userAccounts) item.serverAccountID: FocusNode()
            };
            for (AccountModel item in userAccounts) {
              accountNameFocusNodes[item.serverAccountID]!.addListener(() {
                if (accountNameFocusNodes[item.serverAccountID]!.hasFocus) {
                  scrollController.jumpTo(scrollController.offset +
                      MediaQuery.of(context).viewInsets.bottom);
                }
              });
            }
            Map<String, ValueNotifier> _ = {
              for (var item in userAccounts)
                item.serverAccountID:
                    ValueNotifier(viewModel.protonAddresses.firstOrNull)
            };
            int indexOfWallet = walletMenuModel.currentIndex;
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
                      prefixIcon: Padding(
                          padding: const EdgeInsets.all(4),
                          child: CircleAvatar(
                              backgroundColor:
                                  AvatarColorHelper.getBackgroundColor(
                                      indexOfWallet % 4),
                              radius: 10,
                              child: SvgPicture.asset(
                                "assets/images/icon/wallet-${indexOfWallet % 4}.svg",
                                fit: BoxFit.scaleDown,
                                width: 16,
                                height: 16,
                              ))),
                      labelText: S.of(context).wallet_name,
                      textController: walletNameController,
                      myFocusNode: walletNameFocusNode,
                      maxLength: maxWalletNameSize,
                      onFinish: () async {
                        viewModel.updateWalletName(
                            userWallet, walletNameController.text);
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
                              labelText:
                                  S.of(context).setting_bitcoin_unit_label,
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
                    const SizedBox(
                      height: defaultPadding,
                    ),
                    Text(S.of(context).accounts,
                        style: FontManager.body2Median(ProtonColors.textNorm)),
                    const SizedBox(
                      height: defaultPadding,
                    ),
                    hasEmailIntegration
                        ? AlertCustom(
                            content: S.of(context).bitcoin_via_email_desc,
                            learnMore: GestureDetector(
                                onTap: () {
                                  CustomPlaceholder.show(context);
                                },
                                child: Text(S.of(context).learn_more,
                                    style: FontManager.body2Median(
                                        ProtonColors.textNorm))),
                            leadingWidget: SvgPicture.asset(
                                "assets/images/icon/send_2.svg",
                                fit: BoxFit.fill,
                                width: 30,
                                height: 30),
                            border: Border.all(
                              color: Colors.transparent,
                              width: 0,
                            ),
                            backgroundColor: ProtonColors.alertEnableBackground,
                            color: ProtonColors.textNorm,
                          )
                        : AlertCustom(
                            content:
                                S.of(context).bitcoin_via_email_not_active_desc,
                            learnMore: GestureDetector(
                                onTap: () {
                                  CustomPlaceholder.show(context);
                                },
                                child: Text(S.of(context).learn_more,
                                    style: FontManager.body2Median(
                                        ProtonColors.textNorm))),
                            leadingWidget: SvgPicture.asset(
                                "assets/images/icon/send_2.svg",
                                fit: BoxFit.fill,
                                width: 30,
                                height: 30),
                            border: Border.all(
                              color: Colors.transparent,
                              width: 0,
                            ),
                            backgroundColor:
                                ProtonColors.alertDisableBackground,
                            color: ProtonColors.textNorm,
                          ),
                    const SizedBox(
                      height: defaultPadding,
                    ),
                    BlocBuilder<WalletListBloc, WalletListState>(
                        bloc: viewModel.walletListBloc,
                        builder: (context, state) {
                          return Column(children: [
                            for (WalletMenuModel walletMenuModel2
                                in state.walletsModel)
                              if (walletMenuModel2.walletModel.serverWalletID ==
                                  walletMenuModel.walletModel.serverWalletID)
                                for (AccountMenuModel accountMenuModel
                                    in walletMenuModel2.accounts)
                                  Container(
                                      width: MediaQuery.of(context).size.width,
                                      margin: const EdgeInsets.only(bottom: 10),
                                      decoration: BoxDecoration(
                                        color: ProtonColors.white,
                                        borderRadius:
                                            BorderRadius.circular(18.0),
                                      ),
                                      child: Column(children: [
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                  child: SizedBox(
                                                      child: TextFieldTextV2(
                                                labelText:
                                                    S.of(context).account_label,
                                                maxLength: maxAccountNameSize,
                                                textController:
                                                    accountNameControllers[
                                                        accountMenuModel
                                                            .accountModel
                                                            .serverAccountID]!,
                                                myFocusNode:
                                                    accountNameFocusNodes[
                                                        accountMenuModel
                                                            .accountModel
                                                            .serverAccountID]!,
                                                onFinish: () async {
                                                  viewModel.renameAccount(
                                                      userWallet,
                                                      accountMenuModel
                                                          .accountModel,
                                                      accountNameControllers[
                                                              accountMenuModel
                                                                  .accountModel
                                                                  .serverAccountID]!
                                                          .text);
                                                },
                                                scrollPadding: EdgeInsets.only(
                                                    bottom:
                                                        MediaQuery.of(context)
                                                                .viewInsets
                                                                .bottom +
                                                            80),
                                                validation: (String value) {
                                                  if (value.isEmpty) {
                                                    return "Required";
                                                  }
                                                  return "";
                                                },
                                              ))),
                                              Container(
                                                  width: 50,
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 10),
                                                  child: CircleAvatar(
                                                      radius: 30,
                                                      backgroundColor:
                                                          ProtonColors
                                                              .backgroundProton,
                                                      child: IconButton(
                                                        onPressed: () {
                                                          AdvanceWalletAccountSettingSheet
                                                              .show(
                                                            context,
                                                            viewModel,
                                                            userWallet,
                                                            accountMenuModel,
                                                          );
                                                        },
                                                        icon: Icon(
                                                            Icons
                                                                .more_horiz_rounded,
                                                            size: 20,
                                                            color: ProtonColors
                                                                .textNorm),
                                                      )))
                                            ]),
                                        const Divider(
                                          thickness: 0.2,
                                          height: 1,
                                        ),
                                        DropdownButtonV2(
                                            labelText: S
                                                .of(context)
                                                .setting_fiat_currency_label,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                defaultPadding * 2,
                                            items: fiatCurrencies,
                                            canSearch: true,
                                            itemsText: fiatCurrencies
                                                .map((v) => FiatCurrencyHelper
                                                    .getFullName(v))
                                                .toList(),
                                            valueNotifier:
                                                accountFiatCurrencyNotifier[
                                                    accountMenuModel
                                                        .accountModel
                                                        .serverAccountID]),
                                        const Divider(
                                          thickness: 0.2,
                                          height: 1,
                                        ),
                                        const SizedBox(height: 10),
                                        Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: defaultPadding),
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                      S
                                                          .of(context)
                                                          .email_integration,
                                                      style: FontManager
                                                          .body2Regular(
                                                              ProtonColors
                                                                  .textNorm)),
                                                  CupertinoSwitch(
                                                    value: emailIntegrationEnables[
                                                            accountMenuModel
                                                                .accountModel
                                                                .serverAccountID] ??
                                                        false,
                                                    activeColor:
                                                        ProtonColors.protonBlue,
                                                    onChanged: (bool newValue) {
                                                      setState(() {
                                                        emailIntegrationEnables[
                                                                accountMenuModel
                                                                    .accountModel
                                                                    .serverAccountID] =
                                                            newValue;
                                                      });
                                                    },
                                                  )
                                                ])),
                                        const SizedBox(height: 10),
                                        for (String addressID
                                            in accountMenuModel.emailIds)
                                          Container(
                                              margin: const EdgeInsets.only(
                                                  bottom: 5),
                                              child: ListTile(
                                                title: Text(
                                                    viewModel
                                                        .getProtonAddressByID(
                                                            addressID)!
                                                        .email,
                                                    style: FontManager
                                                        .body2Regular(
                                                            ProtonColors
                                                                .textNorm)),
                                                trailing: IconButton(
                                                  onPressed: () async {
                                                    await viewModel
                                                        .removeEmailAddressFromWalletAccount(
                                                            userWallet,
                                                            accountMenuModel
                                                                .accountModel,
                                                            addressID);
                                                    setState(() {
                                                      emailIntegrationEnables[
                                                              accountMenuModel
                                                                  .accountModel
                                                                  .serverAccountID] =
                                                          false;
                                                      hasEmailIntegration =
                                                          false;
                                                      for (var accountMenuModel
                                                          in walletMenuModel
                                                              .accounts) {
                                                        if (emailIntegrationEnables[
                                                                accountMenuModel
                                                                    .accountModel
                                                                    .serverAccountID] ??
                                                            false) {
                                                          hasEmailIntegration =
                                                              true;
                                                          break;
                                                        }
                                                      }
                                                    });
                                                  },
                                                  icon: const Icon(Icons.close),
                                                ),
                                              )),
                                        if (emailIntegrationEnables[
                                            accountMenuModel
                                                .accountModel.serverAccountID]!)
                                          GestureDetector(
                                              onTap: () {
                                                EmailIntegrationDropdownSheet
                                                    .show(
                                                        context,
                                                        viewModel,
                                                        userWallet,
                                                        accountMenuModel,
                                                        callback: () {
                                                  setState(() {
                                                    emailIntegrationEnables[
                                                            accountMenuModel
                                                                .accountModel
                                                                .serverAccountID] =
                                                        true;
                                                    hasEmailIntegration = true;
                                                  });
                                                });
                                              },
                                              child: Row(children: [
                                                const SizedBox(
                                                    width: defaultPadding),
                                                const AddButtonV1(),
                                                const SizedBox(width: 5),
                                                Text(S.of(context).add,
                                                    style: FontManager
                                                        .body2Regular(
                                                            ProtonColors
                                                                .protonBlue)),
                                              ])),
                                        const SizedBox(height: 20),
                                      ]))
                          ]);
                        }),
                    const SizedBox(
                      height: defaultPadding,
                    ),
                    ListTile(
                      shape: const Border(),
                      leading: SvgPicture.asset(
                          "assets/images/icon/ic-cog-wheel.svg",
                          fit: BoxFit.fill,
                          width: 20,
                          height: 20),
                      title: Text(S.of(context).advanced_settings,
                          style:
                              FontManager.body2Median(ProtonColors.textNorm)),
                      onTap: () {
                        AdvanceWalletSettingSheet.show(
                            context, viewModel, walletMenuModel);
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
          });
    }));
  }
}
