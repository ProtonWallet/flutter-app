import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/avatar.color.helper.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/fiat.currency.helper.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/managers/features/wallet.list/wallet.list.bloc.dart';
import 'package:wallet/managers/features/wallet.list/wallet.list.bloc.state.dart';
import 'package:wallet/scenes/components/button.v5.dart';
import 'package:wallet/scenes/components/custom.header.dart';
import 'package:wallet/scenes/components/custom.loading.dart';
import 'package:wallet/scenes/components/dropdown.button.v2.dart';
import 'package:wallet/scenes/components/dropdown.currency.v1.dart';
import 'package:wallet/scenes/components/page.layout.v1.dart';
import 'package:wallet/scenes/components/textfield.text.v2.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/home.v3/sub.views/wallet.setting/wallet.setting.viewmodel.dart';

class WalletSettingView extends ViewBase<WalletSettingViewModel> {
  const WalletSettingView(WalletSettingViewModel viewModel)
      : super(viewModel, const Key("WalletSettingView"));

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

  @override
  Widget build(BuildContext context) {
    return PageLayoutV1(
      headerWidget: CustomHeader(
        title: S.of(context).wallet_preference,
        buttonDirection: AxisDirection.left,
        padding: const EdgeInsets.only(bottom: 10),
      ),
      scrollController: viewModel.scrollController,
      initialized: viewModel.initialized,
      child: BlocBuilder<WalletListBloc, WalletListState>(
          bloc: viewModel.walletListBloc,
          builder: (context, wlState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFieldTextV2(
                      prefixIcon: Padding(
                          padding: const EdgeInsets.all(4),
                          child: CircleAvatar(
                            backgroundColor:
                                AvatarColorHelper.getBackgroundColor(
                                    viewModel.walletMenuModel.currentIndex % 4),
                            radius: 10,
                            child: getWalletLeadingIcon(
                                viewModel.walletMenuModel.currentIndex % 4),
                          )),
                      labelText: S.of(context).name,
                      hintText: S.of(context).wallet_name_hint,
                      alwaysShowHint: true,
                      textController: viewModel.walletNameController,
                      myFocusNode: viewModel.walletNameFocusNode,
                      maxLength: maxWalletNameSize,
                      onFinish: () async {
                        viewModel.updateWalletName(
                          viewModel.walletNameController.text,
                        );
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
                        style: ProtonStyles.body2Medium(
                            color: ProtonColors.textNorm)),
                    const SizedBox(
                      height: defaultPadding,
                    ),
                    BlocBuilder<WalletListBloc, WalletListState>(
                        bloc: viewModel.walletListBloc,
                        builder: (context, state) {
                          return Column(children: [
                            for (final accountMenuModel
                                in viewModel.walletMenuModel.accounts)
                              Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: const EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    color: ProtonColors.white,
                                    borderRadius: BorderRadius.circular(18.0),
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
                                            textController: viewModel
                                                .getAccountSettingInfoByAccountID(
                                                    accountMenuModel
                                                        .accountModel.accountID)
                                                .nameController,
                                            myFocusNode: viewModel
                                                .getAccountSettingInfoByAccountID(
                                                    accountMenuModel
                                                        .accountModel.accountID)
                                                .nameFocusNode,
                                            onFinish: () async {
                                              viewModel.updateAccountName(
                                                  accountMenuModel.accountModel,
                                                  viewModel
                                                      .getAccountSettingInfoByAccountID(
                                                          accountMenuModel
                                                              .accountModel
                                                              .accountID)
                                                      .nameController
                                                      .text);
                                            },
                                            scrollPadding: EdgeInsets.only(
                                                bottom: MediaQuery.of(context)
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
                                              padding: const EdgeInsets.only(
                                                  right: 10),
                                              child: CircleAvatar(
                                                  radius: 30,
                                                  backgroundColor: ProtonColors
                                                      .backgroundProton,
                                                  child: IconButton(
                                                    onPressed: () {
                                                      viewModel.coordinator
                                                          .showWalletAccountSetting(
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
                                      width: MediaQuery.of(context).size.width -
                                          defaultPadding * 2,
                                      items: fiatCurrencies,
                                      itemsText: fiatCurrencies
                                          .map(FiatCurrencyHelper.getFullName)
                                          .toList(),
                                      itemsLeadingIcons: fiatCurrencies
                                          .map(CommonHelper.getCountryIcon)
                                          .toList(),
                                      valueNotifier: viewModel
                                          .getAccountSettingInfoByAccountID(
                                              accountMenuModel
                                                  .accountModel.accountID)
                                          .fiatCurrencyNotifier,
                                    ),
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
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                  S
                                                      .of(context)
                                                      .receive_bitcoin_via_email,
                                                  style:
                                                      ProtonStyles.body2Regular(
                                                          color: ProtonColors
                                                              .textNorm)),
                                              CupertinoSwitch(
                                                value: viewModel
                                                    .getAccountSettingInfoByAccountID(
                                                        accountMenuModel
                                                            .accountModel
                                                            .accountID)
                                                    .bveEnabled,
                                                activeColor:
                                                    ProtonColors.protonBlue,
                                                onChanged:
                                                    (bool newValue) async {
                                                  if (newValue) {
                                                    viewModel.coordinator
                                                        .showEditBvE(
                                                      viewModel.walletListBloc,
                                                      accountMenuModel
                                                          .accountModel,
                                                      () {
                                                        final accountID =
                                                            accountMenuModel
                                                                .accountModel
                                                                .accountID;
                                                        viewModel
                                                            .updateBvEEnabledStatus(
                                                                accountID,
                                                                true);
                                                      },
                                                    );
                                                  } else if (!viewModel
                                                      .isRemovingBvE) {
                                                    viewModel.updateRemovingBvE(
                                                        true);
                                                    final accountID =
                                                        accountMenuModel
                                                            .accountModel
                                                            .accountID;
                                                    await viewModel
                                                        .removeEmailAddressFromWalletAccount(
                                                            accountMenuModel
                                                                .accountModel,
                                                            accountMenuModel
                                                                .emailIds
                                                                .first);
                                                    viewModel
                                                        .updateBvEEnabledStatus(
                                                            accountID, false);
                                                    viewModel.updateRemovingBvE(
                                                        false);
                                                  }
                                                },
                                              )
                                            ])),
                                    if (!(viewModel
                                            .getAccountSettingInfoByAccountID(
                                                accountMenuModel
                                                    .accountModel.accountID)
                                            .bveEnabled) &&
                                        (CommonHelper.isPrimaryAccount(
                                                accountMenuModel.accountModel
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
                                                      style: ProtonStyles
                                                          .body2Regular(
                                                        color: ProtonColors
                                                            .textNorm,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text: S
                                                          .of(context)
                                                          .bve_warning_create_new_account,
                                                      style: ProtonStyles
                                                          .captionMedium(
                                                        color: ProtonColors
                                                            .textNorm,
                                                      ).copyWith(
                                                        fontSize: 14,
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                        decorationColor:
                                                            ProtonColors
                                                                .textNorm,
                                                      ),
                                                      recognizer:
                                                          TapGestureRecognizer()
                                                            ..onTap = () {
                                                              viewModel.move(NavID
                                                                  .addWalletAccount);
                                                            },
                                                    ),
                                                    TextSpan(
                                                      text: S
                                                          .of(context)
                                                          .bve_warning_2,
                                                      style: ProtonStyles
                                                          .body2Regular(
                                                        color: ProtonColors
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
                                                        style: ProtonStyles
                                                            .captionMedium(
                                                          color: ProtonColors
                                                              .textNorm,
                                                        ).copyWith(
                                                          fontSize: 14,
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                          decorationColor:
                                                              ProtonColors
                                                                  .textNorm,
                                                        ))),
                                              ]),
                                        ),
                                      ),
                                    const SizedBox(height: 10),
                                    for (String addressID
                                        in accountMenuModel.emailIds)
                                      Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 5),
                                          child: ListTile(
                                            title: Text(
                                                viewModel
                                                    .getProtonAddressByID(
                                                        addressID)!
                                                    .email,
                                                style:
                                                    ProtonStyles.body2Regular(
                                                        color: ProtonColors
                                                            .textNorm)),
                                            trailing: viewModel.isRemovingBvE
                                                ? Transform.translate(
                                                    offset:
                                                        const Offset(-10, 0),
                                                    child: const CustomLoading(
                                                      size: 20,
                                                    ),
                                                  )
                                                : IconButton(
                                                    onPressed: () async {
                                                      viewModel
                                                          .updateRemovingBvE(
                                                              true);
                                                      await viewModel
                                                          .removeEmailAddressFromWalletAccount(
                                                              accountMenuModel
                                                                  .accountModel,
                                                              addressID);
                                                      final accountID =
                                                          accountMenuModel
                                                              .accountModel
                                                              .accountID;
                                                      viewModel
                                                          .updateBvEEnabledStatus(
                                                              accountID, false);
                                                      viewModel
                                                          .updateRemovingBvE(
                                                              false);
                                                    },
                                                    icon:
                                                        const Icon(Icons.close),
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
                                style: ProtonStyles.body2Medium(
                                    color: ProtonColors.textNorm))),
                        backgroundColor: Colors.transparent,
                        collapsedBackgroundColor: Colors.transparent,
                        onExpansionChanged: (isExpanded) {
                          if (isExpanded) {
                            Future.delayed(const Duration(milliseconds: 300),
                                () {
                              viewModel.scrollController.animateTo(
                                viewModel
                                    .scrollController.position.maxScrollExtent,
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
                              viewModel.move(NavID.setupBackup);
                            },
                            text: S.of(context).backup_wallet_view_seed_phrase,
                            width: MediaQuery.of(context).size.width,
                            backgroundColor: ProtonColors.protonBlue,
                            textStyle: ProtonStyles.body1Medium(
                                color: ProtonColors.white),
                            height: 48,
                          ),
                          const SizedBox(height: 8),
                          ButtonV5(
                              onPressed: () {
                                viewModel.coordinator.showDeleteWallet(
                                  triggerFromSidebar: false,
                                );
                              },
                              text: S.of(context).delete_wallet,
                              width: MediaQuery.of(context).size.width,
                              backgroundColor: ProtonColors.signalError,
                              textStyle: ProtonStyles.body1Medium(
                                  color: ProtonColors.white),
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
          }),
    );
  }
}
