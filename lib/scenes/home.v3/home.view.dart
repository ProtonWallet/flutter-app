import 'dart:math';
import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/components/custom.expansion.dart';
import 'package:wallet/components/custom.loading.with.icon.dart';
import 'package:wallet/components/custom.todo.dart';
import 'package:wallet/components/discover/discover.feeds.view.dart';
import 'package:wallet/components/home/btc.actions.view.dart';
import 'package:wallet/components/textfield.text.dart';
import 'package:wallet/components/transaction/transaction.listtitle.dart';
import 'package:wallet/components/underline.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/local_toast.dart';
import 'package:wallet/helper/user.settings.provider.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/bitcoin.address.model.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/managers/wallet/proton.wallet.manager.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/home.v3/bitcoin.address.list.dart';
import 'package:wallet/scenes/home.v3/bottom.sheet/onboarding.guide.dart';
import 'package:wallet/scenes/home.v3/bottom.sheet/secure.your.wallet.dart';
import 'package:wallet/scenes/home.v3/bottom.sheet/transaction.filter.dart';
import 'package:wallet/scenes/home.v3/bottom.sheet/wallet.setting.dart';
import 'package:wallet/scenes/home.v3/home.viewmodel.dart';
import 'package:wallet/scenes/home.v3/sidebar.wallet.items.old.dart';
import 'package:wallet/scenes/home.v3/transaction.list.dart';
import 'package:wallet/scenes/settings/settings.account.v2.view.dart';
import 'package:wallet/theme/theme.font.dart';
import 'package:wallet/l10n/generated/locale.dart';

const double drawerMaxWidth = 400;

class HomeView extends ViewBase<HomeViewModel> {
  const HomeView(HomeViewModel viewModel)
      : super(viewModel, const Key("HomeView"));

  @override
  Widget build(BuildContext context) {
    return buildDrawerNavigator(
      context,
      drawerMaxWidth: drawerMaxWidth,
      appBar: (BuildContext context) {
        return buildAppBar(context);
      },
      drawer: (BuildContext context) {
        return buildDrawer(context);
      },
      onDrawerChanged: (bool isOpen) {
        if (isOpen == false) {
          viewModel.saveUserSettings();
          viewModel.updateDrawerStatus(WalletDrawerStatus.close);
        } else {
          viewModel.updateDrawerStatus(WalletDrawerStatus.openSetting);
        }
      },
      content: (BuildContext context) {
        return buildContent(context);
      },
    );
  }

  Center buildContent(BuildContext context) {
    return Center(
      child: ListView(scrollDirection: Axis.vertical, children: [
        Container(
            margin: const EdgeInsets.symmetric(horizontal: defaultPadding),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(
                height: 20,
              ),
              Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (Provider.of<ProtonWalletProvider>(context)
                            .protonWallet
                            .currentAccount ==
                        null)
                      Text(S.of(context).total_accounts,
                          style: FontManager.captionSemiBold(
                              ProtonColors.textNorm)),
                    AnimatedFlipCounter(
                        prefix: Provider.of<UserSettingProvider>(context)
                            .getFiatCurrencyName(),
                        value: Provider.of<UserSettingProvider>(context)
                            .getNotionalInFiatCurrency(
                                Provider.of<ProtonWalletProvider>(context)
                                    .protonWallet
                                    .currentBalance),
                        fractionDigits: defaultDisplayDigits,
                        textStyle: FontManager.balanceInFiatCurrency(
                            ProtonColors.textNorm)),
                    Text(
                        Provider.of<UserSettingProvider>(context)
                            .getBitcoinUnitLabel(
                                Provider.of<ProtonWalletProvider>(context)
                                    .protonWallet
                                    .currentBalance
                                    .toInt()),
                        style: FontManager.balanceInBTC(ProtonColors.textWeak))
                  ],
                ),
                const SizedBox(width: 4),
                Provider.of<ProtonWalletProvider>(context)
                        .protonWallet
                        .isSyncing()
                    ? CustomLoadingWithIcon(
                        icon: Icon(
                          Icons.refresh_rounded,
                          size: 22,
                          color: ProtonColors.textWeak,
                        ),
                        durationInMilliSeconds: 800,
                      )
                    : GestureDetector(
                        onTap: () {
                          Provider.of<ProtonWalletProvider>(context,
                                  listen: false)
                              .syncWallet();
                        },
                        child: Icon(
                          Icons.refresh_rounded,
                          size: 22,
                          color: ProtonColors.textWeak,
                        ))
              ]),
              const SizedBox(
                height: 20,
              ),
              BtcTitleActionsView(
                  price: viewModel.btcPriceInfo.price,
                  priceChange: viewModel.btcPriceInfo.priceChange24h,
                  onSend: () {
                    if (Provider.of<ProtonWalletProvider>(context,
                                listen: false)
                            .protonWallet
                            .currentWallet !=
                        null) {
                      viewModel.move(NavID.send);
                    } else {
                      CommonHelper.showSnackbar(
                          context, S.of(context).please_select_wallet_first);
                    }
                  },
                  onBuy: () {
                    if (Provider.of<ProtonWalletProvider>(context,
                                listen: false)
                            .protonWallet
                            .currentAccount !=
                        null) {
                      viewModel.move(NavID.buy);
                    } else {
                      LocalToast.showErrorToast(context,
                          "Will add it after add wallet account switch");
                    }
                  },
                  onReceive: () {
                    if (Provider.of<ProtonWalletProvider>(context,
                                listen: false)
                            .protonWallet
                            .currentWallet !=
                        null) {
                      move(context, NavID.receive);
                    } else {
                      CommonHelper.showSnackbar(
                          context, S.of(context).please_select_wallet_first);
                    }
                  }),
              const SizedBox(
                height: 10,
              ),
              if (Provider.of<ProtonWalletProvider>(context, listen: false)
                  .protonWallet
                  .historyTransactions
                  .isEmpty)
                Center(
                    child: Underline(
                        onTap: () {
                          if (Provider.of<ProtonWalletProvider>(context,
                                      listen: false)
                                  .protonWallet
                                  .currentWallet !=
                              null) {
                            SecureYourWalletSheet.show(context, viewModel);
                          }
                        },
                        color: ProtonColors.brandLighten20,
                        child: Text(S.of(context).secure_your_wallet,
                            style: FontManager.body2Median(
                                ProtonColors.brandLighten20)))),
              if (viewModel.currentTodoStep < viewModel.totalTodoSteps &&
                  Provider.of<ProtonWalletProvider>(context, listen: false)
                      .protonWallet
                      .historyTransactions
                      .isNotEmpty)
                CustomExpansion(
                    totalSteps: viewModel.totalTodoSteps,
                    currentStep: viewModel.currentTodoStep,
                    children: [
                      const SizedBox(
                        height: 5,
                      ),
                      CustomTodos(
                          title: S.of(context).todos_backup_proton_account,
                          checked: viewModel.hadBackupProtonAccount,
                          callback: () {}),
                      const SizedBox(
                        height: 5,
                      ),
                      CustomTodos(
                          title: S.of(context).todos_backup_wallet_mnemonic,
                          checked: viewModel.hadBackup,
                          callback: () {
                            move(context, NavID.setupBackup);
                          }),
                      const SizedBox(
                        height: 5,
                      ),
                      CustomTodos(
                          title: S.of(context).todos_setup_2fa,
                          checked: viewModel.hadSetup2FA,
                          callback: () {}),
                      const SizedBox(
                        height: 5,
                      ),
                    ]),
              const SizedBox(
                height: 20,
              ),
              Container(
                  decoration: BoxDecoration(
                    color: ProtonColors.white,
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  padding: const EdgeInsets.only(bottom: 20, top: 10),
                  child: Column(children: [
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                            onTap: () {
                              viewModel.updateBodyListStatus(
                                  BodyListStatus.transactionList);
                            },
                            child: Text(S.of(context).transactions,
                                style: FontManager.body1Median(
                                    ProtonColors.protonBlue))),
                        const SizedBox(width: 10),
                        Text("|",
                            style:
                                FontManager.body1Median(ProtonColors.textNorm)),
                        const SizedBox(width: 10),
                        GestureDetector(
                            onTap: () {
                              viewModel.updateBodyListStatus(
                                  BodyListStatus.bitcoinAddressList);
                            },
                            child: Text(S.of(context).bitcoin_address,
                                style: FontManager.body1Median(
                                    ProtonColors.protonBlue))),
                      ],
                    ),
                    viewModel.bodyListStatus == BodyListStatus.transactionList
                        ? TransactionList(viewModel: viewModel)
                        : BitcoinAddressList(viewModel: viewModel),
                  ])),
              if (Provider.of<ProtonWalletProvider>(context)
                  .protonWallet
                  .historyTransactionsAfterFilter
                  .isEmpty)
                Column(children: [
                  const SizedBox(
                    height: 40,
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    ButtonV5(
                        onPressed: () {
                          viewModel.move(NavID.receive);
                        },
                        backgroundColor: ProtonColors.white,
                        text: S.of(context).receive,
                        width: MediaQuery.of(context).size.width > 424
                            ? 180
                            : MediaQuery.of(context).size.width / 2 -
                                defaultPadding * 2,
                        textStyle:
                            FontManager.body1Median(ProtonColors.protonBlue),
                        height: 48),
                    const SizedBox(
                      width: 10,
                    ),
                    ButtonV5(
                        onPressed: () {},
                        backgroundColor: ProtonColors.backgroundBlack,
                        text: S.of(context).buy,
                        width: MediaQuery.of(context).size.width > 424
                            ? 180
                            : MediaQuery.of(context).size.width / 2 -
                                defaultPadding * 2,
                        textStyle: FontManager.body1Median(
                            ProtonColors.backgroundSecondary),
                        height: 48),
                  ]),
                ]),
              const SizedBox(height: 20),
              if (viewModel.protonFeedItems.isNotEmpty &&
                  Provider.of<ProtonWalletProvider>(context)
                      .protonWallet
                      .historyTransactionsAfterFilter
                      .isEmpty)
                Text(S.of(context).explore_wallet,
                    style: FontManager.body1Median(ProtonColors.textNorm)),
              const SizedBox(height: 10),
              if (Provider.of<ProtonWalletProvider>(context)
                  .protonWallet
                  .historyTransactionsAfterFilter
                  .isEmpty)
                //Discover feeds
                DiscoverFeedsView(
                  onTap: (String link) {
                    launchUrl(Uri.parse(link));
                  },
                  protonFeedItems: viewModel.protonFeedItems,
                ),
              const SizedBox(height: 40),
            ])),
      ]),
    );
  }

  Drawer buildDrawer(BuildContext context) {
    return Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(0), bottomRight: Radius.circular(0)),
        ),
        backgroundColor: ProtonColors.drawerBackground,
        width: min(MediaQuery.of(context).size.width - 70, drawerMaxWidth),
        child: buildSidebar(context, viewModel));
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            viewModel.walletDrawerStatus == WalletDrawerStatus.close
                ? Brightness.dark
                : Brightness.light,
        // For Android (dark icons)
        statusBarBrightness:
            viewModel.walletDrawerStatus == WalletDrawerStatus.close
                ? Brightness.light
                : Brightness.dark,
      ),
      backgroundColor: ProtonColors.backgroundProton,
      title: Text(
        Provider.of<ProtonWalletProvider>(context).getDisplayName() ??
            S.of(context).proton_wallet,
        style: FontManager.body2Median(ProtonColors.textNorm),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: SvgPicture.asset("assets/images/icon/wallet_edit.svg",
              fit: BoxFit.fill, width: 40, height: 40),
          onPressed: () {
            // TODO:: wallet settings could be a new View/view model. move to wallet settings.
            /// temperay
            var context = Coordinator.rootNavigatorKey.currentContext;
            if (context != null) {
              WalletSettingSheet.show(context, viewModel);
            }
          },
        )
      ],
      leading: Builder(
        builder: (BuildContext context) {
          if (viewModel.currentSize == ViewSize.mobile) {
            return IconButton(
              icon: SvgPicture.asset("assets/images/icon/drawer_menu.svg",
                  fit: BoxFit.fill, width: 40, height: 40),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          } else {
            return const SizedBox();
          }
        },
      ),
      scrolledUnderElevation:
          0.0, // don't change background color when scroll down
    );
  }

  void move(BuildContext context, NavID identifier) {
    if (context.mounted) {
      if (CommonHelper.checkSelectWallet(context)) {
        viewModel.move(identifier);
      }
    }
  }
}

Widget buildSidebar(BuildContext context, HomeViewModel viewModel) {
  return SafeArea(
      child: SingleChildScrollView(
          child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 30),
                    // logo section
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: defaultPadding),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SvgPicture.asset("assets/images/icon/logo_text.svg",
                                fit: BoxFit.fill, width: 146.41, height: 18),
                            const SizedBox(
                              height: 20,
                            ),
                          ]),
                    ),
                    //account info section
                    AccountInfoV2(
                        displayName: viewModel.displayName,
                        userEmail: viewModel.userEmail),
                    const SizedBox(
                      height: 10,
                    ),
                    const Divider(thickness: 0.2),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: defaultPadding),
                        child: Text(
                          S.of(context).wallets,
                          style:
                              FontManager.body2Regular(ProtonColors.textHint),
                        )),
                    const SizedBox(
                      height: 10,
                    ),
                    // wallet
                    sidebarWalletItems(context, viewModel),
                    // TODO:: enable this later wallet side bar.
                    // SidebarWalletItems(
                    //   walletListBloc: viewModel.walletBloc,
                    //   // select wallet
                    //   selectAccount: (wallet, account) {
                    //     if (viewModel.currentSize == ViewSize.mobile) {
                    //       Navigator.of(context).pop();
                    //     }
                    //     viewModel.selectAccount(wallet, account);
                    //   },
                    //   // delete wallet when un valid
                    //   onDelete: (wallet, hasBalance, isInvalidWallet) {
                    //     DeleteWalletSheet.show(
                    //         context, viewModel, wallet, false,
                    //         isInvalidWallet: true);
                    //   },
                    //   // update passphrase
                    //   updatePassphrase: (wallet) {
                    //     PassphraseSheet.show(context, viewModel, wallet);
                    //   },
                    //   // add new account into wallet
                    //   addAccount: (wallet) {
                    //     AddWalletAccountSheet.show(context, viewModel, wallet);
                    //   },
                    // ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Divider(thickness: 0.2),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: defaultPadding),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(S.of(context).more,
                                  style: FontManager.body2Regular(
                                      ProtonColors.textHint)),
                            ])),
                    ListTile(
                        onTap: () async {
                          if (viewModel.currentSize == ViewSize.mobile) {
                            Navigator.of(context).pop();
                          }
                          EasyLoading.show(
                              status: "child session..",
                              maskType: EasyLoadingMaskType.black);
                          await viewModel.move(NavID.nativeUpgrade);
                          EasyLoading.dismiss();
                        },
                        leading: SvgPicture.asset(
                            "assets/images/icon/ic-diamondwallet_plus.svg",
                            fit: BoxFit.fill,
                            width: 20,
                            height: 20),
                        title: Transform.translate(
                            offset: const Offset(-8, 0),
                            child: Text(S.of(context).wallet_plus,
                                style: FontManager.body2Median(
                                    ProtonColors.drawerWalletPlus)))),
                    ListTile(
                        onTap: () {
                          if (viewModel.currentSize == ViewSize.mobile) {
                            Navigator.of(context).pop();
                          }
                          viewModel.move(NavID.discover);
                        },
                        leading: SvgPicture.asset(
                            "assets/images/icon/ic-squares-in-squarediscover.svg",
                            fit: BoxFit.fill,
                            width: 20,
                            height: 20),
                        title: Transform.translate(
                            offset: const Offset(-8, 0),
                            child: Text(S.of(context).discover,
                                style: FontManager.body2Median(
                                    ProtonColors.textHint)))),
                    ListTile(
                        onTap: () {},
                        leading: SvgPicture.asset(
                            "assets/images/icon/ic-cog-wheel.svg",
                            fit: BoxFit.fill,
                            width: 20,
                            height: 20),
                        title: Transform.translate(
                            offset: const Offset(-8, 0),
                            child: Text(S.of(context).settings_title,
                                style: FontManager.body2Median(
                                    ProtonColors.textHint)))),
                    ListTile(
                        onTap: () {
                          if (viewModel.currentSize == ViewSize.mobile) {
                            Navigator.of(context).pop();
                          }
                          viewModel.move(NavID.securitySetting);
                        },
                        leading: SvgPicture.asset(
                            "assets/images/icon/ic-shield.svg",
                            fit: BoxFit.fill,
                            width: 20,
                            height: 20),
                        title: Transform.translate(
                            offset: const Offset(-8, 0),
                            child: Text(S.of(context).security,
                                style: FontManager.body2Median(
                                    ProtonColors.textHint)))),
                    ListTile(
                        onTap: () {},
                        leading: SvgPicture.asset(
                            "assets/images/icon/ic-arrow-rotate-right.svg",
                            fit: BoxFit.fill,
                            width: 20,
                            height: 20),
                        title: Transform.translate(
                            offset: const Offset(-8, 0),
                            child: Text(S.of(context).recovery,
                                style: FontManager.body2Median(
                                    ProtonColors.textHint)))),
                    ListTile(
                        onTap: () {},
                        leading: SvgPicture.asset(
                            "assets/images/icon/ic-bugreport.svg",
                            fit: BoxFit.fill,
                            width: 20,
                            height: 20),
                        title: Transform.translate(
                            offset: const Offset(-8, 0),
                            child: Text(S.of(context).report_a_problem,
                                style: FontManager.body2Median(
                                    ProtonColors.textHint)))),
                    ListTile(
                        onTap: () async {
                          await viewModel.logout();
                        },
                        leading: SvgPicture.asset(
                            "assets/images/icon/ic-arrow-out-from-rectanglesignout.svg",
                            fit: BoxFit.fill,
                            width: 20,
                            height: 20),
                        title: Transform.translate(
                            offset: const Offset(-8, 0),
                            child: Text(S.of(context).logout,
                                style: FontManager.body2Median(
                                    ProtonColors.textHint)))),
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: defaultPadding),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              ButtonV5(
                                text: S.of(context).add_wallet,
                                width: MediaQuery.of(context).size.width,
                                backgroundColor:
                                    ProtonColors.drawerButtonBackground,
                                textStyle: FontManager.body1Median(
                                    ProtonColors.protonBlue),
                                height: 48,
                                onPressed: () {
                                  if (Provider.of<ProtonWalletProvider>(context,
                                              listen: false)
                                          .protonWallet
                                          .wallets
                                          .length <
                                      freeUserWalletLimit) {
                                    if (viewModel.currentSize ==
                                        ViewSize.mobile) {
                                      Navigator.of(context).pop();
                                    }
                                    viewModel.nameTextController.text = "";
                                    viewModel.passphraseTextController.text =
                                        "";
                                    viewModel.passphraseConfirmTextController
                                        .text = "";
                                    OnboardingGuideSheet.show(
                                        context, viewModel);
                                  } else {
                                    CommonHelper.showSnackbar(
                                        context,
                                        S.of(context).freeuser_wallet_limit(
                                            freeUserWalletLimit));
                                  }
                                },
                              )
                            ])),
                    const SizedBox(
                      height: 20,
                    ),
                    // TODO:: use packageinfo but need fix dependency issue
                    //   Center(
                    //       child: Container(
                    //           padding: const EdgeInsets.only(bottom: 10),
                    //           child: Text(
                    //             "${S.of(context).app_name} ${viewModel.packageInfo!.version} (${viewModel.packageInfo!.buildNumber})",
                    //             style: FontManager.captionRegular(
                    //                 ProtonColors.textHint),
                    //           ))),
                    Center(
                        child: Container(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              "${S.of(context).app_name} 1.0.0 (27)",
                              style: FontManager.captionRegular(
                                  ProtonColors.textHint),
                            ))),
                  ]))));
}

Widget showUpdateWalletPassphraseDialog(
    BuildContext context, HomeViewModel viewModel, WalletModel walletModel) {
  TextEditingController textEditingController = TextEditingController();
  textEditingController.text = "";
  return AlertDialog(
    title: Text(S.of(context).set_passphrase),
    content: TextField(
      controller: textEditingController,
    ),
    actions: <Widget>[
      TextButton(
        onPressed: () {
          if (viewModel.currentSize == ViewSize.mobile) {
            Navigator.of(context).pop();
          }
        },
        child: Text(S.of(context).cancel),
      ),
      TextButton(
        onPressed: () async {
          EasyLoading.show(
              status: "saving passphrase..",
              maskType: EasyLoadingMaskType.black);
          try {
            await viewModel.updatePassphrase(
                walletModel.serverWalletID, textEditingController.text);
            await Future.delayed(const Duration(seconds: 1));
          } catch (e) {
            viewModel.errorMessage = e.toString();
          }
          EasyLoading.dismiss();
          if (context.mounted) {
            if (viewModel.currentSize == ViewSize.mobile) {
              Navigator.of(context).pop();
            } // pop current dialog
          }
        },
        child: Text(S.of(context).submit),
      ),
    ],
  );
}

Widget getWalletAccountBalanceWidget(
  BuildContext context,
  HomeViewModel viewModel,
  AccountModel accountModel,
  Color textColor,
) {
  double esitmateValue = Provider.of<UserSettingProvider>(context)
      .getNotionalInFiatCurrency(accountModel.balance.toInt());
  return Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
    Text(
        "${Provider.of<UserSettingProvider>(context).getFiatCurrencyName()}${esitmateValue.toStringAsFixed(defaultDisplayDigits)}",
        style: FontManager.captionSemiBold(textColor)),
    Text(
        Provider.of<UserSettingProvider>(context)
            .getBitcoinUnitLabel(accountModel.balance.toInt()),
        style: FontManager.overlineRegular(ProtonColors.textHint))
  ]);
}
