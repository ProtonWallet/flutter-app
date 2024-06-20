// home.view.dart
import 'dart:math';
import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/components/custom.expansion.dart';
import 'package:wallet/components/custom.loading.with.icon.dart';
import 'package:wallet/components/custom.todo.dart';
import 'package:wallet/components/discover/discover.feeds.view.dart';
import 'package:wallet/components/home/btc.actions.view.dart';
import 'package:wallet/components/underline.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/exchange.caculator.dart';
import 'package:wallet/managers/features/models/wallet.list.dart';
import 'package:wallet/managers/features/wallet.list.bloc.dart';
import 'package:wallet/managers/features/wallet.transaction.bloc.dart';
import 'package:wallet/managers/services/exchange.rate.service.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/home.v3/bitcoin.address.list.dart';
import 'package:wallet/scenes/home.v3/bottom.sheet/add.wallet.account.dart';
import 'package:wallet/scenes/home.v3/bottom.sheet/delete.wallet.dart';
import 'package:wallet/scenes/home.v3/bottom.sheet/onboarding.guide.dart';
import 'package:wallet/scenes/home.v3/bottom.sheet/passphrase.dart';
import 'package:wallet/scenes/home.v3/bottom.sheet/secure.your.wallet.dart';
import 'package:wallet/scenes/home.v3/bottom.sheet/upgrade.intro.dart';
import 'package:wallet/scenes/home.v3/bottom.sheet/wallet.setting.dart';
import 'package:wallet/scenes/home.v3/home.viewmodel.dart';
import 'package:wallet/scenes/home.v3/sidebar.wallet.items.dart';
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

  Widget buildContent(BuildContext context) {
    bool walletView = true;

    /// TODO:: fix me
    bool hasTransaction = true;

    /// TODO:: fix me
    return BlocBuilder<WalletTransactionBloc, WalletTransactionState>(
        bloc: viewModel.walletTransactionBloc,
        builder: (context, state) {
          return Center(
            child: ListView(scrollDirection: Axis.vertical, children: [
              Container(
                  margin:
                  const EdgeInsets.symmetric(horizontal: defaultPadding),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (walletView)
                                    Text(S
                                        .of(context)
                                        .total_accounts,
                                        style: FontManager.captionSemiBold(
                                            ProtonColors.textNorm)),
                                  AnimatedFlipCounter(
                                      prefix: viewModel.dataProviderManager
                                          .userSettingsDataProvider
                                          .getFiatCurrencyName(
                                          fiatCurrency: viewModel
                                              .currentExchangeRate
                                              .fiatCurrency),
                                      value: ExchangeCalculator
                                          .getNotionalInFiatCurrency(
                                        viewModel.currentExchangeRate,
                                        state.balanceInSatoshi,
                                      ),

                                      /// TODO:: use actual balance
                                      fractionDigits: defaultDisplayDigits,
                                      textStyle:
                                      FontManager.balanceInFiatCurrency(
                                          ProtonColors.textNorm)),
                                  Text(
                                      ExchangeCalculator.getBitcoinUnitLabel(
                                        viewModel.bitcoinUnit,
                                        state.balanceInSatoshi,
                                      ),

                                      /// TODO:: use actual balance
                                      style: FontManager.balanceInBTC(
                                          ProtonColors.textWeak))
                                ],
                              ),
                              const SizedBox(width: 4),
                              state.isSyncing
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
                                    viewModel.walletTransactionBloc
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
                            exchangeRate: viewModel
                                .currentExchangeRate,
                            onSend: () {
                              viewModel.move(NavID.send);
                            },
                            onBuy: () {
                              viewModel.move(NavID.buy);
                            },
                            onReceive: () {
                              move(context, NavID.receive);
                            }),
                        const SizedBox(
                          height: 20,
                        ),
                        if (hasTransaction == false)
                          Center(
                              child: Underline(
                                  onTap: () {
                                    SecureYourWalletSheet.show(
                                        context, viewModel);
                                  },
                                  color: ProtonColors.brandLighten20,
                                  child: Text(S
                                      .of(context)
                                      .secure_your_wallet,
                                      style: FontManager.body2Median(
                                          ProtonColors.brandLighten20)))),
                        if (viewModel.currentTodoStep <
                            viewModel.totalTodoSteps &&
                            hasTransaction)
                          CustomExpansion(
                              totalSteps: viewModel.totalTodoSteps,
                              currentStep: viewModel.currentTodoStep,
                              children: [
                                const SizedBox(
                                  height: 5,
                                ),
                                CustomTodos(
                                    title: S
                                        .of(context)
                                        .todos_backup_proton_account,
                                    checked: viewModel.hadBackupProtonAccount,
                                    callback: () {}),
                                const SizedBox(
                                  height: 5,
                                ),
                                CustomTodos(
                                    title: S
                                        .of(context)
                                        .todos_backup_wallet_mnemonic,
                                    checked: viewModel.hadBackup,
                                    callback: () {
                                      move(context, NavID.setupBackup);
                                    }),
                                const SizedBox(
                                  height: 5,
                                ),
                                CustomTodos(
                                    title: S
                                        .of(context)
                                        .todos_setup_2fa,
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
                                      child: Text(S
                                          .of(context)
                                          .transactions,
                                          style: FontManager.body1Median(
                                              ProtonColors.protonBlue))),
                                  const SizedBox(width: 10),
                                  Text("|",
                                      style: FontManager.body1Median(
                                          ProtonColors.textNorm)),
                                  const SizedBox(width: 10),
                                  GestureDetector(
                                      onTap: () {
                                        viewModel.updateBodyListStatus(
                                            BodyListStatus.bitcoinAddressList);
                                      },
                                      child: Text(S
                                          .of(context)
                                          .bitcoin_address,
                                          style: FontManager.body1Median(
                                              ProtonColors.protonBlue))),
                                ],
                              ),
                              viewModel.bodyListStatus ==
                                  BodyListStatus.transactionList
                                  ? TransactionList(viewModel: viewModel)
                                  : BitcoinAddressList(viewModel: viewModel),
                            ])),
                        if (hasTransaction == false)
                          Column(children: [
                            const SizedBox(
                              height: 40,
                            ),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ButtonV5(
                                      onPressed: () {
                                        viewModel.move(NavID.receive);
                                      },
                                      backgroundColor: ProtonColors.white,
                                      text: S
                                          .of(context)
                                          .receive,
                                      width: MediaQuery
                                          .of(context)
                                          .size
                                          .width >
                                          424
                                          ? 180
                                          : MediaQuery
                                          .of(context)
                                          .size
                                          .width /
                                          2 -
                                          defaultPadding * 2,
                                      textStyle: FontManager.body1Median(
                                          ProtonColors.protonBlue),
                                      height: 48),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  ButtonV5(
                                      onPressed: () {},
                                      backgroundColor:
                                      ProtonColors.backgroundBlack,
                                      text: S
                                          .of(context)
                                          .buy,
                                      width: MediaQuery
                                          .of(context)
                                          .size
                                          .width >
                                          424
                                          ? 180
                                          : MediaQuery
                                          .of(context)
                                          .size
                                          .width /
                                          2 -
                                          defaultPadding * 2,
                                      textStyle: FontManager.body1Median(
                                          ProtonColors.backgroundSecondary),
                                      height: 48),
                                ]),
                          ]),
                        const SizedBox(height: 20),
                        if (viewModel.protonFeedItems.isNotEmpty &&
                            hasTransaction == false)
                          Text(S
                              .of(context)
                              .explore_wallet,
                              style: FontManager.body1Median(
                                  ProtonColors.textNorm)),
                        const SizedBox(height: 10),
                        if (hasTransaction == false)
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
        });
  }

  Drawer buildDrawer(BuildContext context) {
    return Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(0), bottomRight: Radius.circular(0)),
        ),
        backgroundColor: ProtonColors.drawerBackground,
        width: min(MediaQuery
            .of(context)
            .size
            .width - 70, drawerMaxWidth),
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
      title: BlocBuilder<WalletListBloc, WalletListState>(
          bloc: viewModel.walletBloc,
          builder: (context, state) {
            String walletName = "";
            if (state.initialized) {
              for (WalletMenuModel walletMenuModel in state.walletsModel) {
                if (walletMenuModel.isSelected) {
                  walletName = walletMenuModel.walletName;
                }
                for (AccountMenuModel accountMenuModel
                in walletMenuModel.accounts) {
                  if (accountMenuModel.isSelected) {
                    if (walletMenuModel.accounts.length > 1) {
                      walletName =
                      "${walletMenuModel.walletName} - ${accountMenuModel
                          .label}";
                    } else {
                      walletName = walletMenuModel.walletName;
                    }
                    break;
                  }
                }
              }
            }
            return Text(
              walletName.isNotEmpty ? walletName : S
                  .of(context)
                  .proton_wallet,
              style: FontManager.body2Median(ProtonColors.textNorm),
            );
          }),
      centerTitle: true,
      actions: [
        BlocBuilder<WalletListBloc, WalletListState>(
            bloc: viewModel.walletBloc,
            builder: (context, state) {
              return IconButton(
                icon: SvgPicture.asset("assets/images/icon/wallet_edit.svg",
                    fit: BoxFit.fill, width: 40, height: 40),
                onPressed: () {
                  // TODO:: wallet settings could be a new View/view model. move to wallet settings.
                  /// temperay
                  var context = Coordinator.rootNavigatorKey.currentContext;
                  if (context != null) {
                    for (WalletMenuModel walletMenuModel
                    in state.walletsModel) {
                      if (walletMenuModel.isSelected) {
                        WalletSettingSheet.show(
                            context, viewModel, walletMenuModel);
                        break;
                      }

                      /// check if it's wallet account view
                      bool inAccount = false;
                      for (AccountMenuModel accountMenuModel in walletMenuModel
                          .accounts) {
                        if (accountMenuModel.isSelected) {
                          WalletSettingSheet.show(
                              context, viewModel, walletMenuModel);
                          inAccount = true;
                          break;
                        }
                      }
                      if (inAccount) {
                        break;
                      }
                    }
                  }
                },
              );
            }),
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
      viewModel.move(identifier);
    }
  }
}

Widget buildSidebar(BuildContext context, HomeViewModel viewModel) {
  /// TODO:: fixme
  return BlocBuilder<WalletListBloc, WalletListState>(
      bloc: viewModel.walletBloc,
      builder: (context, state) {
        return SafeArea(
            child: SingleChildScrollView(
                child: SizedBox(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
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
                                  SvgPicture.asset(
                                      "assets/images/icon/logo_text.svg",
                                      fit: BoxFit.fill,
                                      width: 146.41,
                                      height: 18),
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
                              child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      S
                                          .of(context)
                                          .wallets,
                                      style: FontManager.body2Regular(
                                          ProtonColors.textHint),
                                    ),
                                    GestureDetector(
                                        onTap: () {
                                          if (state.walletsModel.length <
                                              freeUserWalletLimit) {
                                            if (viewModel.currentSize ==
                                                ViewSize.mobile) {
                                              Navigator.of(context).pop();
                                            }
                                            viewModel.nameTextController.text =
                                            "";
                                            viewModel.passphraseTextController
                                                .text = "";
                                            viewModel
                                                .passphraseConfirmTextController
                                                .text = "";
                                            OnboardingGuideSheet.show(
                                                context, viewModel);
                                          } else {
                                            UpgradeIntroSheet.show(
                                                context, viewModel);
                                          }
                                        },
                                        child: SvgPicture.asset(
                                            "assets/images/icon/ic-plus-circle.svg",
                                            fit: BoxFit.fill,
                                            width: 20,
                                            height: 20)),
                                  ])),
                          const SizedBox(
                            height: 10,
                          ),
                          // wallet
                          SidebarWalletItems(
                            walletListBloc: viewModel.walletBloc,
                            // select wallet
                            selectAccount: (wallet, account) {
                              if (viewModel.currentSize == ViewSize.mobile) {
                                Navigator.of(context).pop();
                              }
                              viewModel.selectAccount(wallet, account);
                            },
                            selectWallet: (wallet) {
                              if (viewModel.currentSize == ViewSize.mobile) {
                                Navigator.of(context).pop();
                              }
                              viewModel.selectWallet(wallet);
                            },
                            // delete wallet when un valid
                            onDelete: (wallet, hasBalance, isInvalidWallet) {
                              DeleteWalletSheet.show(
                                  context, viewModel, wallet, false,
                                  isInvalidWallet: true);
                            },
                            // update passphrase
                            updatePassphrase: (wallet) {
                              PassphraseSheet.show(
                                  context, viewModel, wallet.walletModel);
                            },
                            // add new account into wallet
                            addAccount: (wallet) {
                              AddWalletAccountSheet.show(
                                  context, viewModel, wallet.walletModel);
                            },
                          ),
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
                                    Text(S
                                        .of(context)
                                        .more,
                                        style: FontManager.body2Regular(
                                            ProtonColors.textHint)),
                                  ])),
                          ListTile(
                              onTap: () async {
                                UpgradeIntroSheet.show(context, viewModel);
                              },
                              leading: SvgPicture.asset(
                                  "assets/images/icon/ic-diamondwallet_plus.svg",
                                  fit: BoxFit.fill,
                                  width: 20,
                                  height: 20),
                              title: Transform.translate(
                                  offset: const Offset(-8, 0),
                                  child: Text(S
                                      .of(context)
                                      .wallet_plus,
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
                                  child: Text(S
                                      .of(context)
                                      .discover,
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
                                  child: Text(S
                                      .of(context)
                                      .settings_title,
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
                                  child: Text(S
                                      .of(context)
                                      .security,
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
                                  child: Text(S
                                      .of(context)
                                      .recovery,
                                      style: FontManager.body2Median(
                                          ProtonColors.textHint)))),
                          ListTile(
                              onTap: () {
                                viewModel.move(NavID.natvieReportBugs);
                              },
                              leading: SvgPicture.asset(
                                  "assets/images/icon/ic-bugreport.svg",
                                  fit: BoxFit.fill,
                                  width: 20,
                                  height: 20),
                              title: Transform.translate(
                                  offset: const Offset(-8, 0),
                                  child: Text(S
                                      .of(context)
                                      .report_a_problem,
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
                                  child: Text(S
                                      .of(context)
                                      .logout,
                                      style: FontManager.body2Median(
                                          ProtonColors.textHint)))),
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
                                    "${S
                                        .of(context)
                                        .app_name} 1.0.0 (32)",
                                    style: FontManager.captionRegular(
                                        ProtonColors.textHint),
                                  ))),
                        ]))));
      });
}

Widget showUpdateWalletPassphraseDialog(BuildContext context,
    HomeViewModel viewModel, WalletModel walletModel) {
  TextEditingController textEditingController = TextEditingController();
  textEditingController.text = "";
  return AlertDialog(
    title: Text(S
        .of(context)
        .set_passphrase),
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
        child: Text(S
            .of(context)
            .cancel),
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
        child: Text(S
            .of(context)
            .submit),
      ),
    ],
  );
}

Widget getWalletAccountBalanceWidget(BuildContext context,
    HomeViewModel viewModel,
    AccountModel accountModel,
    Color textColor,) {
  FiatCurrency? fiatCurrency =
  WalletManager.getAccountFiatCurrency(accountModel);
  ProtonExchangeRate? exchangeRate =
  ExchangeRateService.getExchangeRateOrNull(fiatCurrency);
  double estimateValue = ExchangeCalculator.getNotionalInFiatCurrency(
      exchangeRate ?? viewModel.currentExchangeRate,
      accountModel.balance.toInt());
  if (exchangeRate == null) {
    fiatCurrency = null;
  }
  return Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
    Text(
        "${viewModel.dataProviderManager.userSettingsDataProvider
            .getFiatCurrencyName(fiatCurrency: fiatCurrency)}${estimateValue
            .toStringAsFixed(defaultDisplayDigits)}",
        style: FontManager.captionSemiBold(textColor)),
    Text(
        ExchangeCalculator.getBitcoinUnitLabel(
            viewModel.bitcoinUnit, accountModel.balance.toInt()),
        style: FontManager.overlineRegular(ProtonColors.textHint))
  ]);
}
