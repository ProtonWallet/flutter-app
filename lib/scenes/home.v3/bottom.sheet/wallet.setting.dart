import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/avatar.color.helper.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/fiat.currency.helper.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/managers/features/wallet.list/wallet.list.bloc.dart';
import 'package:wallet/managers/features/wallet.list/wallet.list.bloc.model.dart';
import 'package:wallet/managers/features/wallet.list/wallet.list.bloc.state.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/scenes/components/bottom.sheets/base.dart';
import 'package:wallet/scenes/components/button.v5.dart';
import 'package:wallet/scenes/components/custom.header.dart';
import 'package:wallet/scenes/components/custom.loading.dart';
import 'package:wallet/scenes/components/dropdown.button.v2.dart';
import 'package:wallet/scenes/components/dropdown.currency.v1.dart';
import 'package:wallet/scenes/components/textfield.text.v2.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/home.v3/bottom.sheet/advance.wallet.account.setting.dart';
import 'package:wallet/scenes/home.v3/bottom.sheet/delete.wallet.dart';
import 'package:wallet/scenes/home.v3/bottom.sheet/email.integration.dropdown.v2.dart';
import 'package:wallet/scenes/home.v3/home.viewmodel.dart';
import 'package:wallet/theme/theme.font.dart';

class WalletSettingSheet {
  static void show(
    BuildContext context,
    HomeViewModel viewModel,
    WalletMenuModel walletMenuModel,
  ) {
    final ScrollController scrollController = ScrollController();

    /// Create a map to check if each account has email integration enabled
    final Map<String, bool> emailIntegrationEnables = {
      for (final accountMenuModel in walletMenuModel.accounts)
        accountMenuModel.accountModel.accountID:
            accountMenuModel.emailIds.isNotEmpty,
    };

    final TextEditingController walletNameController =
        TextEditingController(text: walletMenuModel.walletName);
    final FocusNode walletNameFocusNode = FocusNode();

    final List<AccountModel> userAccounts =
        walletMenuModel.accounts.map((e) => e.accountModel).toList();
    final Map<String, ValueNotifier> accountFiatCurrencyNotifier =
        viewModel.getAccountFiatCurrencyNotifiers(userAccounts);
    final Map<String, ValueNotifier> _ = {
      for (var item in userAccounts)
        item.accountID: ValueNotifier(viewModel.protonAddresses.firstOrNull)
    };
    final Map<String, TextEditingController> accountNameControllers = {
      for (var accountMenuModel in walletMenuModel.accounts)
        accountMenuModel.accountModel.accountID:
            TextEditingController(text: accountMenuModel.label)
    };
    final Map<String, FocusNode> accountNameFocusNodes = {
      for (var item in userAccounts) item.accountID: FocusNode()
    };
    for (AccountModel item in userAccounts) {
      accountNameFocusNodes[item.accountID]!.addListener(() {
        if (accountNameFocusNodes[item.accountID]!.hasFocus) {
          scrollController.jumpTo(scrollController.offset +
              MediaQuery.of(context).viewInsets.bottom);
        }
      });
    }

    Widget getWalletLeadingIcon(int index) {
      switch (index) {
        case 1:
          return Assets.images.icon.wallet1.svg(
            fit: BoxFit.fill,
            width: 16,
            height: 16,
          );
        case 2:
          return Assets.images.icon.wallet2.svg(
            fit: BoxFit.fill,
            width: 16,
            height: 16,
          );
        case 3:
          return Assets.images.icon.wallet3.svg(
            fit: BoxFit.fill,
            width: 16,
            height: 16,
          );
        default:
          return Assets.images.icon.wallet0.svg(
            fit: BoxFit.fill,
            width: 16,
            height: 16,
          );
      }
    }

    HomeModalBottomSheet.show(context,
        scrollController: scrollController,
        header: CustomHeader(
          title: S.of(context).wallet_preference,
          buttonDirection: AxisDirection.left,
        ), child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
      return BlocBuilder<WalletListBloc, WalletListState>(
          bloc: viewModel.walletListBloc,
          builder: (context, wlState) {
            // TODO(fix): change to walletMenuModel
            var foundWalletMenuModel = walletMenuModel;
            for (final item in wlState.walletsModel) {
              if (walletMenuModel.walletModel.walletID ==
                  item.walletModel.walletID) {
                foundWalletMenuModel = item;
                break;
              }
            }
            final WalletModel userWallet = foundWalletMenuModel.walletModel;

            final int indexOfWallet = foundWalletMenuModel.currentIndex;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                            child: getWalletLeadingIcon(indexOfWallet % 4),
                          )),
                      labelText: S.of(context).name,
                      hintText: S.of(context).wallet_name_hint,
                      alwaysShowHint: true,
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
                      height: defaultPadding,
                    ),
                    Text(S.of(context).accounts,
                        style: FontManager.body2Median(ProtonColors.textNorm)),
                    const SizedBox(
                      height: defaultPadding,
                    ),
                    BlocBuilder<WalletListBloc, WalletListState>(
                        bloc: viewModel.walletListBloc,
                        builder: (context, state) {
                          List<String> usedEmailIDs = [];
                          for (WalletMenuModel walletMenuModel
                              in state.walletsModel) {
                            for (AccountMenuModel accountMenuModel
                                in walletMenuModel.accounts) {
                              usedEmailIDs += accountMenuModel.emailIds;
                            }
                          }
                          return Column(children: [
                            for (final walletMenuModel2 in state.walletsModel)
                              if (walletMenuModel2.walletModel.walletID ==
                                  foundWalletMenuModel.walletModel.walletID)
                                for (final accountMenuModel
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
                                                            .accountID]!,
                                                myFocusNode:
                                                    accountNameFocusNodes[
                                                        accountMenuModel
                                                            .accountModel
                                                            .accountID]!,
                                                onFinish: () async {
                                                  viewModel.renameAccount(
                                                      userWallet,
                                                      accountMenuModel
                                                          .accountModel,
                                                      accountNameControllers[
                                                              accountMenuModel
                                                                  .accountModel
                                                                  .accountID]!
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
                                        DropdownCurrencyV1(
                                            labelText: S
                                                .of(context)
                                                .setting_fiat_currency_label,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                defaultPadding * 2,
                                            items: fiatCurrencies,
                                            itemsText: fiatCurrencies
                                                .map(FiatCurrencyHelper
                                                    .getFullName)
                                                .toList(),
                                            itemsLeadingIcons: fiatCurrencies
                                                .map(
                                                    CommonHelper.getCountryIcon)
                                                .toList(),
                                            valueNotifier:
                                                accountFiatCurrencyNotifier[
                                                    accountMenuModel
                                                        .accountModel
                                                        .accountID]),
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
                                                          .receive_bitcoin_via_email,
                                                      style: FontManager
                                                          .body2Regular(
                                                              ProtonColors
                                                                  .textNorm)),
                                                  CupertinoSwitch(
                                                    value: emailIntegrationEnables[
                                                            accountMenuModel
                                                                .accountModel
                                                                .accountID] ??
                                                        false,
                                                    activeColor:
                                                        ProtonColors.protonBlue,
                                                    onChanged:
                                                        (bool newValue) async {
                                                      if (newValue) {
                                                        EmailIntegrationDropdownV2Sheet
                                                            .show(
                                                                context,
                                                                viewModel,
                                                                userWallet,
                                                                accountMenuModel,
                                                                usedEmailIDs,
                                                                callback: () {
                                                          setState(() {
                                                            emailIntegrationEnables[
                                                                accountMenuModel
                                                                    .accountModel
                                                                    .accountID] = true;
                                                          });
                                                        });
                                                      } else if (!viewModel
                                                          .isRemovingBvE) {
                                                        setState(() {
                                                          viewModel
                                                                  .isRemovingBvE =
                                                              true;
                                                        });
                                                        await viewModel
                                                            .removeEmailAddressFromWalletAccount(
                                                                userWallet,
                                                                accountMenuModel
                                                                    .accountModel,
                                                                accountMenuModel
                                                                    .emailIds
                                                                    .first);
                                                        setState(() {
                                                          emailIntegrationEnables[
                                                              accountMenuModel
                                                                  .accountModel
                                                                  .accountID] = false;
                                                          viewModel
                                                                  .isRemovingBvE =
                                                              false;
                                                        });
                                                      }
                                                    },
                                                  )
                                                ])),
                                        if (!(emailIntegrationEnables[
                                                    accountMenuModel
                                                        .accountModel
                                                        .accountID] ??
                                                false) &&
                                            (CommonHelper.isPrimaryAccount(
                                                    accountMenuModel
                                                        .accountModel
                                                        .derivationPath) ||
                                                accountMenuModel.balance > 0))
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                top: 6,
                                                left: defaultPadding,
                                                right: defaultPadding,
                                              ),
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text.rich(
                                                      textAlign: TextAlign.left,
                                                      TextSpan(children: [
                                                        TextSpan(
                                                          text: S
                                                              .of(context)
                                                              .bve_warning_1,
                                                          style: FontManager
                                                              .body2Regular(
                                                            ProtonColors
                                                                .textNorm,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text: S
                                                              .of(context)
                                                              .bve_warning_create_new_account,
                                                          style: FontManager
                                                              .linkUnderline(
                                                            ProtonColors
                                                                .textNorm,
                                                          ).copyWith(
                                                              fontSize: 14),
                                                          recognizer:
                                                              TapGestureRecognizer()
                                                                ..onTap = () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                  viewModel
                                                                          .walletIDtoAddAccount =
                                                                      walletMenuModel
                                                                          .walletModel
                                                                          .walletID;
                                                                  viewModel.move(
                                                                      NavID
                                                                          .addWalletAccount);
                                                                },
                                                        ),
                                                        TextSpan(
                                                          text: S
                                                              .of(context)
                                                              .bve_warning_2,
                                                          style: FontManager
                                                              .body2Regular(
                                                            ProtonColors
                                                                .textNorm,
                                                          ),
                                                        ),
                                                      ]),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    GestureDetector(
                                                        onTap: () {
                                                          viewModel.coordinator
                                                              .showBvEPrivacy(
                                                            isPrimaryAccount: CommonHelper
                                                                .isPrimaryAccount(
                                                                    accountMenuModel
                                                                        .accountModel
                                                                        .derivationPath),
                                                          );
                                                        },
                                                        child: Text(
                                                            S
                                                                .of(context)
                                                                .learn_more,
                                                            style: FontManager
                                                                .linkUnderline(
                                                              ProtonColors
                                                                  .textNorm,
                                                            ).copyWith(
                                                                fontSize: 14))),
                                                  ]),
                                            ),
                                          ),
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
                                                trailing: viewModel
                                                        .isRemovingBvE
                                                    ? Transform.translate(
                                                        offset: const Offset(
                                                            -10, 0),
                                                        child:
                                                            const CustomLoading(
                                                          size: 20,
                                                        ),
                                                      )
                                                    : IconButton(
                                                        onPressed: () async {
                                                          setState(() {
                                                            viewModel
                                                                    .isRemovingBvE =
                                                                true;
                                                          });
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
                                                                    .accountID] = false;
                                                            viewModel
                                                                    .isRemovingBvE =
                                                                false;
                                                          });
                                                        },
                                                        icon: const Icon(
                                                            Icons.close),
                                                      ),
                                              )),
                                        const SizedBox(height: 20),
                                      ]))
                          ]);
                        }),
                    Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        title: Transform.translate(
                            offset: const Offset(-8, 0),
                            child: Text(S.of(context).view_more,
                                style: FontManager.body2Median(
                                    ProtonColors.textNorm))),
                        backgroundColor: Colors.transparent,
                        collapsedBackgroundColor: Colors.transparent,
                        onExpansionChanged: (isExpanded) {
                          if (isExpanded) {
                            Future.delayed(const Duration(milliseconds: 300),
                                () {
                              scrollController.animateTo(
                                scrollController.position.maxScrollExtent,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                              );
                            });
                          }
                        },
                        children: [
                          const SizedBox(height: 4),
                          ButtonV5(
                            onPressed: () {
                              Navigator.of(context).pop();

                              /// pop wallet setting sheet or it will hide setupBackup view
                              viewModel.move(NavID.setupBackup);
                            },
                            text: S.of(context).backup_wallet_view_seed_phrase,
                            width: MediaQuery.of(context).size.width,
                            backgroundColor: ProtonColors.protonBlue,
                            textStyle:
                                FontManager.body1Median(ProtonColors.white),
                            height: 48,
                          ),
                          const SizedBox(height: 8),
                          ButtonV5(
                              onPressed: () {
                                DeleteWalletSheet.show(
                                  context,
                                  viewModel,
                                  foundWalletMenuModel,
                                  hasBalance: foundWalletMenuModel.accounts
                                          .map((v) => v.balance)
                                          .sum >
                                      0,
                                  onBackup: () {
                                    Navigator.of(context).pop();
                                    viewModel.move(NavID.setupBackup);
                                  },
                                );
                              },
                              text: S.of(context).delete_wallet,
                              width: MediaQuery.of(context).size.width,
                              backgroundColor: ProtonColors.signalError,
                              textStyle:
                                  FontManager.body1Median(ProtonColors.white),
                              height: 48),
                        ],
                      ),
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
