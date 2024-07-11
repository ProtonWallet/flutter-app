// home.view.dart
import 'dart:math';
import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:card_loading/card_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wallet/helper/exceptions.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/rust/common/errors.dart';
import 'package:wallet/scenes/components/button.v5.dart';
import 'package:wallet/scenes/components/custom.expansion.dart';
import 'package:wallet/scenes/components/custom.todo.dart';
import 'package:wallet/scenes/components/discover/discover.feeds.view.dart';
import 'package:wallet/scenes/components/home/bitcoin.price.box.dart';
import 'package:wallet/scenes/components/home/btc.actions.view.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/exchange.caculator.dart';
import 'package:wallet/managers/features/models/wallet.list.dart';
import 'package:wallet/managers/features/wallet.balance.bloc.dart';
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
    return BlocBuilder<WalletListBloc, WalletListState>(
        bloc: viewModel.walletListBloc,
        builder: (context, walletListState) {
          String accountName = "";
          if (walletListState.initialized) {
            for (WalletMenuModel walletMenuModel
                in walletListState.walletsModel) {
              if (walletMenuModel.isSelected) {
                accountName = S.of(context).total_accounts;
              }
              for (AccountMenuModel accountMenuModel
                  in walletMenuModel.accounts) {
                if (accountMenuModel.isSelected) {
                  accountName = accountMenuModel.label;
                  break;
                }
              }
            }
          }
          return BlocBuilder<WalletTransactionBloc, WalletTransactionState>(
              bloc: viewModel.walletTransactionBloc,
              builder: (context, walletTransactionState) {
                return BlocBuilder<WalletBalanceBloc, WalletBalanceState>(
                    bloc: viewModel.walletBalanceBloc,
                    builder: (context, walletBalanceState) {
                      return Stack(children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 70),
                            child: ListView(
                                scrollDirection: Axis.vertical,
                                children: [
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: defaultPadding,
                                            ),
                                            child: Column(
                                              children: [
                                                getMainBalanceWidget(
                                                  context,
                                                  viewModel,
                                                  accountName,
                                                  walletBalanceState,
                                                  walletTransactionState,
                                                ),
                                                const SizedBox(
                                                  height: 20,
                                                ),
                                              ],
                                            )),
                                        BtcTitleActionsView(onSend: () {
                                          viewModel.move(NavID.send);
                                        }, onBuy: () {
                                          viewModel.move(NavID.buy);
                                        }, onReceive: () {
                                          move(context, NavID.receive);
                                        }),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        if (walletTransactionState
                                            .historyTransaction.isEmpty)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: defaultPadding),
                                            child: GestureDetector(
                                              onTap: () {
                                                SecureYourWalletSheet.show(
                                                    context, viewModel);
                                              },
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                padding: const EdgeInsets.only(
                                                    left: 20,
                                                    right: 20,
                                                    top: defaultPadding,
                                                    bottom: defaultPadding),
                                                decoration: BoxDecoration(
                                                    color: ProtonColors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            24.0)),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      S
                                                          .of(context)
                                                          .secure_your_wallet,
                                                      style: FontManager
                                                          .body2Median(
                                                              ProtonColors
                                                                  .protonBlue),
                                                    ),
                                                    Transform.translate(
                                                      offset:
                                                          const Offset(6, 0),
                                                      child: Icon(
                                                          Icons
                                                              .arrow_forward_ios_rounded,
                                                          color: ProtonColors
                                                              .protonBlue,
                                                          size: 14),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        if (viewModel.currentTodoStep <
                                                viewModel.totalTodoSteps &&
                                            walletTransactionState
                                                .historyTransaction.isNotEmpty)
                                          CustomExpansion(
                                              totalSteps:
                                                  viewModel.totalTodoSteps,
                                              currentStep:
                                                  viewModel.currentTodoStep,
                                              children: [
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                CustomTodos(
                                                    title: S
                                                        .of(context)
                                                        .todos_backup_proton_account,
                                                    checked: viewModel
                                                        .hadBackupProtonAccount,
                                                    callback: () {}),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                CustomTodos(
                                                    title: S
                                                        .of(context)
                                                        .todos_backup_wallet_mnemonic,
                                                    checked: viewModel
                                                            .showWalletRecovery ==
                                                        false,
                                                    callback: () {
                                                      move(context,
                                                          NavID.setupBackup);
                                                    }),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                CustomTodos(
                                                    title: S
                                                        .of(context)
                                                        .todos_setup_2fa,
                                                    checked:
                                                        viewModel.hadSetup2FA,
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
                                              color:
                                                  getTransactionAndAddressesBackground(
                                                      walletTransactionState,
                                                      viewModel.bodyListStatus),
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(24.0),
                                                topRight: Radius.circular(24.0),
                                                bottomLeft:
                                                    Radius.circular(24.0),
                                                bottomRight:
                                                    Radius.circular(24.0),
                                              ),
                                            ),
                                            padding: const EdgeInsets.only(
                                                bottom: 20, top: 10),
                                            child: Column(children: [
                                              viewModel.bodyListStatus ==
                                                      BodyListStatus
                                                          .transactionList
                                                  ? TransactionList(
                                                      viewModel: viewModel)
                                                  : BitcoinAddressList(
                                                      viewModel: viewModel),
                                            ])),
                                        if (walletTransactionState
                                            .historyTransaction.isEmpty)
                                          Column(children: [
                                            const SizedBox(
                                              height: defaultPadding,
                                            ),
                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  ButtonV5(
                                                      onPressed: () {
                                                        viewModel.move(
                                                            NavID.receive);
                                                      },
                                                      backgroundColor:
                                                          ProtonColors.white,
                                                      text:
                                                          S.of(context).receive,
                                                      width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width >
                                                              424
                                                          ? 180
                                                          : MediaQuery.of(context)
                                                                      .size
                                                                      .width /
                                                                  2 -
                                                              defaultPadding *
                                                                  2,
                                                      textStyle: FontManager
                                                          .body1Median(
                                                              ProtonColors
                                                                  .protonBlue),
                                                      height: 48),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  ButtonV5(
                                                      onPressed: () {},
                                                      backgroundColor:
                                                          ProtonColors
                                                              .backgroundBlack,
                                                      text: S.of(context).buy,
                                                      width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width >
                                                              424
                                                          ? 180
                                                          : MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  2 -
                                                              defaultPadding *
                                                                  2,
                                                      textStyle: FontManager
                                                          .body1Median(ProtonColors
                                                              .backgroundSecondary),
                                                      height: 48),
                                                ]),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                          ]),
                                        const SizedBox(height: 20),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: defaultPadding,
                                          ),
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                if (viewModel.protonFeedItems
                                                        .isNotEmpty &&
                                                    walletTransactionState
                                                        .historyTransaction
                                                        .isEmpty)
                                                  Text(
                                                      S
                                                          .of(context)
                                                          .explore_wallet,
                                                      style: FontManager
                                                          .body1Median(
                                                              ProtonColors
                                                                  .textNorm)),
                                                const SizedBox(height: 10),
                                                if (walletTransactionState
                                                    .historyTransaction.isEmpty)
                                                  Column(children: [
                                                    DiscoverFeedsView(
                                                      onTap: (String link) {
                                                        launchUrl(
                                                            Uri.parse(link));
                                                      },
                                                      protonFeedItems: viewModel
                                                          .protonFeedItems,
                                                    ),
                                                    const SizedBox(
                                                      height: 40,
                                                    ),
                                                  ]),
                                              ]),
                                        ),
                                      ]),
                                ]),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          bottom: 0,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: BitcoinPriceBox(
                              title: S.of(context).btc_price,
                              price: viewModel.btcPriceInfo.price,
                              priceChange:
                                  viewModel.btcPriceInfo.priceChange24h,
                              exchangeRate: viewModel.currentExchangeRate,
                            ),
                          ),
                        )
                      ]);
                    });
              });
        });
  }

  Widget getMainBalanceWidget(
    BuildContext context,
    HomeViewModel viewModel,
    String accountName,
    WalletBalanceState walletBalanceState,
    WalletTransactionState walletTransactionState,
  ) {
    if (walletTransactionState.isSyncing || accountName.isEmpty) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        accountName.isNotEmpty
            ? Text(accountName,
                style: FontManager.body1Regular(ProtonColors.textHint))
            : const CardLoading(
                width: 200,
                height: 16,
                borderRadius: BorderRadius.all(Radius.circular(4)),
                margin: EdgeInsets.only(top: 4),
              ),
        const SizedBox(
          height: 2,
        ),
        const CardLoading(
          width: 200,
          height: 36,
          borderRadius: BorderRadius.all(Radius.circular(4)),
          margin: EdgeInsets.only(top: 4),
        ),
        const SizedBox(
          height: 2,
        ),
        const CardLoading(
          width: 200,
          height: 16,
          borderRadius: BorderRadius.all(Radius.circular(4)),
          margin: EdgeInsets.only(top: 4),
        ),
      ]);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(children: [
          Text(accountName,
              style: FontManager.body1Regular(ProtonColors.textHint)),
          const SizedBox(
            height: 4,
          ),
        ]),
        Row(children: [
          viewModel.displayBalance
              ? AnimatedFlipCounter(
                  prefix: viewModel.dataProviderManager.userSettingsDataProvider
                      .getFiatCurrencySign(
                          fiatCurrency:
                              viewModel.currentExchangeRate.fiatCurrency),
                  thousandSeparator: ",",
                  value: ExchangeCalculator.getNotionalInFiatCurrency(
                    viewModel.currentExchangeRate,
                    walletBalanceState.balanceInSatoshi,
                  ),

                  /// TODO:: use actual balance
                  fractionDigits: defaultDisplayDigits,
                  textStyle:
                      FontManager.balanceInFiatCurrency(ProtonColors.textNorm))
              : Text(
                  "${viewModel.dataProviderManager.userSettingsDataProvider.getFiatCurrencyName(fiatCurrency: viewModel.currentExchangeRate.fiatCurrency)}--.--",
                  style:
                      FontManager.balanceInFiatCurrency(ProtonColors.textNorm)),
          const SizedBox(width: 10),
          viewModel.displayBalance
              ? GestureDetector(
                  onTap: () {
                    viewModel.setDisplayBalance(false);
                  },
                  child: Icon(
                    Icons.visibility_off_outlined,
                    size: 24,
                    color: ProtonColors.textWeak,
                  ))
              : GestureDetector(
                  onTap: () {
                    viewModel.setDisplayBalance(true);
                  },
                  child: Icon(
                    Icons.visibility_outlined,
                    size: 24,
                    color: ProtonColors.textWeak,
                  )),
        ]),
        const SizedBox(
          height: 8,
        ),
        viewModel.displayBalance
            ? Text(
                ExchangeCalculator.getBitcoinUnitLabel(
                  viewModel.bitcoinUnit,
                  walletBalanceState.balanceInSatoshi,
                ),
                style: FontManager.balanceInBTC(ProtonColors.textHint))
            : Text(
                "---- ${viewModel.bitcoinUnit.name.toUpperCase() != "MBTC" ? viewModel.bitcoinUnit.name.toUpperCase() : "mBTC"}",
                style: FontManager.balanceInBTC(ProtonColors.textHint),
              ),
      ],
    );
  }

  Color getTransactionAndAddressesBackground(
      WalletTransactionState walletTransactionState,
      BodyListStatus listStatus) {
    if (listStatus == BodyListStatus.transactionList) {
      return walletTransactionState.historyTransaction.isEmpty
          ? ProtonColors.backgroundProton
          : ProtonColors.white;
    } else {
      return walletTransactionState.bitcoinAddresses.isEmpty
          ? ProtonColors.backgroundProton
          : ProtonColors.white;
    }
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
      title: BlocBuilder<WalletListBloc, WalletListState>(
          bloc: viewModel.walletListBloc,
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
                    walletName = walletMenuModel.walletName;
                    break;
                  }
                }
              }
            }
            return Text(
              walletName.isNotEmpty ? walletName : S.of(context).proton_wallet,
              style: FontManager.body2Median(ProtonColors.textNorm),
            );
          }),
      centerTitle: true,
      actions: [
        BlocBuilder<WalletListBloc, WalletListState>(
            bloc: viewModel.walletListBloc,
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
                      for (AccountMenuModel accountMenuModel
                          in walletMenuModel.accounts) {
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
      bloc: viewModel.walletListBloc,
      builder: (context, state) {
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
                                      S.of(context).wallets,
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
                            walletListBloc: viewModel.walletListBloc,
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
                                context,
                                viewModel,
                                wallet,
                              );
                            },
                            // add new account into wallet
                            addAccount: (wallet) {
                              AddWalletAccountSheet.show(
                                  context, viewModel, wallet);
                            },
                            viewModel: viewModel,
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
                                    Text(S.of(context).more,
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
                              onTap: () {
                                if (viewModel.currentSize == ViewSize.mobile) {
                                  Navigator.of(context).pop();
                                }
                                viewModel.move(NavID.settings);
                              },
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
                              onTap: () {
                                if (viewModel.currentSize == ViewSize.mobile) {
                                  Navigator.of(context).pop();
                                }
                                viewModel.move(NavID.recovery);
                              },
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
                          // ListTile(
                          //     onTap: () {
                          //       viewModel.move(NavID.natvieReportBugs);
                          //     },
                          //     leading: SvgPicture.asset(
                          //         "assets/images/icon/ic-bugreport.svg",
                          //         fit: BoxFit.fill,
                          //         width: 20,
                          //         height: 20),
                          //     title: Transform.translate(
                          //         offset: const Offset(-8, 0),
                          //         child: Text(S.of(context).report_a_problem,
                          //             style: FontManager.body2Median(
                          //                 ProtonColors.textHint)))),
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
                          const SizedBox(height: 20),

                          Center(
                            child: Container(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                viewModel.appVersion,
                                style: FontManager.captionRegular(
                                  ProtonColors.textHint,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ]))));
      });
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
                walletModel.walletID, textEditingController.text);
            await Future.delayed(const Duration(seconds: 1));
          } on BridgeError catch (e, stacktrace) {
            // TODO:: fix me
            viewModel.errorMessage = parseSampleDisplayError(e);
            logger.e("importWallet error: $e, stacktrace: $stacktrace");
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
        "${viewModel.dataProviderManager.userSettingsDataProvider.getFiatCurrencyName(fiatCurrency: fiatCurrency)}${estimateValue.toStringAsFixed(defaultDisplayDigits)}",
        style: FontManager.captionSemiBold(textColor)),
    Text(
        ExchangeCalculator.getBitcoinUnitLabel(
            viewModel.bitcoinUnit, accountModel.balance.toInt()),
        style: FontManager.overlineRegular(ProtonColors.textHint))
  ]);
}
