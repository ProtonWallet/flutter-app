import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/avatar.color.helper.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/managers/wallet/proton.wallet.manager.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/home.v3/bottom.sheet/add.wallet.account.dart';
import 'package:wallet/scenes/home.v3/bottom.sheet/delete.wallet.dart';
import 'package:wallet/scenes/home.v3/bottom.sheet/passphrase.dart';
import 'package:wallet/scenes/home.v3/home.view.dart';
import 'package:wallet/scenes/home.v3/home.viewmodel.dart';
import 'package:wallet/theme/theme.font.dart';

Widget sidebarWalletItems(BuildContext context, HomeViewModel viewModel) {
  return Column(children: [
    if (viewModel.initialed)
      for (WalletModel walletModel
          in Provider.of<ProtonWalletProvider>(context).protonWallet.wallets)
        ListTileTheme(
            contentPadding:
                const EdgeInsets.only(left: defaultPadding, right: 10),
            child: ExpansionTile(
              shape: const Border(),
              collapsedBackgroundColor:
                  (Provider.of<ProtonWalletProvider>(context)
                                  .protonWallet
                                  .currentWallet !=
                              null &&
                          Provider.of<ProtonWalletProvider>(context)
                                  .protonWallet
                                  .currentAccount ==
                              null &&
                          Provider.of<ProtonWalletProvider>(context)
                                  .protonWallet
                                  .currentWallet!
                                  .serverWalletID ==
                              walletModel.serverWalletID)
                      ? ProtonColors.drawerBackgroundHighlight
                      : Colors.transparent,
              backgroundColor: (Provider.of<ProtonWalletProvider>(context)
                              .protonWallet
                              .currentWallet !=
                          null &&
                      Provider.of<ProtonWalletProvider>(context)
                              .protonWallet
                              .currentAccount ==
                          null &&
                      Provider.of<ProtonWalletProvider>(context)
                              .protonWallet
                              .currentWallet!
                              .serverWalletID ==
                          walletModel.serverWalletID)
                  ? ProtonColors.drawerBackgroundHighlight
                  : Colors.transparent,
              initiallyExpanded: Provider.of<ProtonWalletProvider>(context)
                  .protonWallet
                  .hasPassphrase(walletModel),
              leading: SvgPicture.asset(
                  "assets/images/icon/wallet-${Provider.of<ProtonWalletProvider>(context).protonWallet.wallets.indexOf(walletModel) % 4}.svg",
                  fit: BoxFit.fill,
                  width: 18,
                  height: 18),
              title: Transform.translate(
                  offset: const Offset(-8, 0),
                  child: Provider.of<ProtonWalletProvider>(context)
                          .protonWallet
                          .hasPassphrase(walletModel)
                      ? GestureDetector(
                          onTap: () {
                            viewModel.selectWallet(walletModel);
                            if (viewModel.currentSize == ViewSize.mobile) {
                              Navigator.of(context).pop();
                            }
                          },
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                        width: min(
                                            MediaQuery.of(context).size.width -
                                                180,
                                            drawerMaxWidth - 110),
                                        child: Text(
                                          walletModel.name,
                                          style: FontManager.captionSemiBold(
                                              AvatarColorHelper.getTextColor(
                                                  Provider.of<ProtonWalletProvider>(
                                                          context)
                                                      .protonWallet
                                                      .wallets
                                                      .indexOf(walletModel))),
                                          overflow: TextOverflow.ellipsis,
                                        )),
                                    Text(
                                        "${Provider.of<ProtonWalletProvider>(context).protonWallet.getAccountCounts(walletModel)} accounts",
                                        style: FontManager.captionRegular(
                                            ProtonColors.textHint))
                                  ],
                                )
                              ]))
                      : Row(children: [
                          GestureDetector(
                              onTap: () {
                                PassphraseSheet.show(
                                    context, viewModel, walletModel);
                              },
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                            width: min(
                                                MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    250,
                                                drawerMaxWidth - 180),
                                            child: Text(walletModel.name,
                                                style: FontManager.captionSemiBold(
                                                    AvatarColorHelper
                                                        .getTextColor(Provider
                                                                .of<ProtonWalletProvider>(
                                                                    context)
                                                            .protonWallet
                                                            .wallets
                                                            .indexOf(
                                                                walletModel))),
                                                overflow:
                                                    TextOverflow.ellipsis)),
                                        Text(
                                            "${Provider.of<ProtonWalletProvider>(context).protonWallet.getAccountCounts(walletModel)} accounts",
                                            style: FontManager.captionRegular(
                                                ProtonColors.textHint))
                                      ],
                                    ),
                                    Padding(
                                        padding: const EdgeInsets.only(left: 4),
                                        child: Icon(
                                          Icons.info_outline_rounded,
                                          color: ProtonColors.signalError,
                                          size: 24,
                                        )),
                                  ])),
                          GestureDetector(
                              onTap: () {
                                DeleteWalletSheet.show(
                                    context, viewModel, walletModel, false,
                                    isInvalidWallet: true);
                              },
                              child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Icon(
                                    Icons.delete_outline_rounded,
                                    color: ProtonColors.signalError,
                                    size: 24,
                                  ))),
                        ])),
              iconColor: ProtonColors.textHint,
              collapsedIconColor: ProtonColors.textHint,
              children: [
                if (Provider.of<ProtonWalletProvider>(context)
                    .protonWallet
                    .hasPassphrase(walletModel))
                  for (AccountModel accountModel
                      in Provider.of<ProtonWalletProvider>(context)
                          .protonWallet
                          .getAccounts(walletModel))
                    Material(
                        color: ProtonColors.drawerBackground,
                        child: ListTile(
                          tileColor: Provider.of<ProtonWalletProvider>(context)
                                      .protonWallet
                                      .currentAccount ==
                                  null
                              ? null
                              : accountModel.serverAccountID ==
                                      Provider.of<ProtonWalletProvider>(context)
                                          .protonWallet
                                          .currentAccount!
                                          .serverAccountID
                                  ? ProtonColors.drawerBackgroundHighlight
                                  : ProtonColors.drawerBackground,
                          onTap: () {
                            viewModel.selectAccount(walletModel, accountModel);
                            if (viewModel.currentSize == ViewSize.mobile) {
                              Navigator.of(context).pop();
                            }
                          },
                          leading: Container(
                            margin: const EdgeInsets.only(left: 10),
                            child: SvgPicture.asset(
                                "assets/images/icon/wallet-account-${Provider.of<ProtonWalletProvider>(context).protonWallet.wallets.indexOf(walletModel) % 4}.svg",
                                fit: BoxFit.fill,
                                width: 16,
                                height: 16),
                          ),
                          title: Transform.translate(
                              offset: const Offset(-4, 0),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            CommonHelper.getFirstNChar(
                                                accountModel.labelDecrypt, 20),
                                            style: FontManager.captionMedian(
                                                AvatarColorHelper.getTextColor(
                                                    Provider.of<ProtonWalletProvider>(
                                                            context)
                                                        .protonWallet
                                                        .wallets
                                                        .indexOf(
                                                            walletModel)))),
                                      ],
                                    ),
                                    getWalletAccountBalanceWidget(
                                        context,
                                        viewModel,
                                        accountModel,
                                        AvatarColorHelper.getTextColor(
                                            Provider.of<ProtonWalletProvider>(
                                                    context)
                                                .protonWallet
                                                .wallets
                                                .indexOf(walletModel))),
                                  ])),
                        )),
                if (Provider.of<ProtonWalletProvider>(context)
                    .protonWallet
                    .hasPassphrase(walletModel))
                  Material(
                      color: ProtonColors.drawerBackground,
                      child: ListTile(
                        onTap: () {
                          if (Provider.of<ProtonWalletProvider>(context,
                                      listen: false)
                                  .protonWallet
                                  .getAccounts(walletModel)
                                  .length <
                              freeUserWalletAccountLimit) {
                            AddWalletAccountSheet.show(
                                context, viewModel, walletModel);
                          } else {
                            CommonHelper.showSnackbar(
                                context,
                                S.of(context).freeuser_wallet_account_limit(
                                    freeUserWalletAccountLimit));
                          }
                        },
                        tileColor: ProtonColors.drawerBackground,
                        leading: Container(
                            margin: const EdgeInsets.only(left: 10),
                            child: Assets.images.icon.addAccount.svg(
                              fit: BoxFit.fill,
                              width: 16,
                              height: 16,
                            )),
                        title: Transform.translate(
                            offset: const Offset(-4, 0),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(S.of(context).add_account,
                                          style: FontManager.captionRegular(
                                              ProtonColors.textHint)),
                                    ],
                                  )
                                ])),
                      )),
              ],
            ))
  ]);
}
