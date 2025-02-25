// home.view.dart
import 'dart:math';

import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/common.helper.dart';
import 'package:wallet/helper/exceptions.dart';
import 'package:wallet/helper/exchange.caculator.dart';
import 'package:wallet/helper/extension/build.context.extension.dart';
import 'package:wallet/helper/extension/svg.gen.image.extension.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/managers/features/wallet.balance/wallet.balance.bloc.dart';
import 'package:wallet/managers/features/wallet.list/wallet.list.bloc.dart';
import 'package:wallet/managers/features/wallet.list/wallet.list.bloc.model.dart';
import 'package:wallet/managers/features/wallet.list/wallet.list.bloc.state.dart';
import 'package:wallet/managers/features/wallet.trans/wallet.transaction.bloc.dart';
import 'package:wallet/managers/services/exchange.rate.service.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/provider/theme.provider.dart';
import 'package:wallet/rust/api/errors.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/scenes/components/button.v5.dart';
import 'package:wallet/scenes/components/custom.card_loading.builder.dart';
import 'package:wallet/scenes/components/custom.expansion.dart';
import 'package:wallet/scenes/components/custom.todo.dart';
import 'package:wallet/scenes/components/discover/discover.feeds.view.dart';
import 'package:wallet/scenes/components/home/bitcoin.price.box.dart';
import 'package:wallet/scenes/components/home/btc.actions.view.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/home.v3/home.menu.list.dart';
import 'package:wallet/scenes/home.v3/home.viewmodel.dart';
import 'package:wallet/scenes/home.v3/sidebar.wallet.items.dart';
import 'package:wallet/scenes/home.v3/transaction.list.dart';
import 'package:wallet/scenes/settings/settings.account.v2.view.dart';

class HomeView extends ViewBase<HomeViewModel> {
  const HomeView(HomeViewModel viewModel, {super.locker})
      : super(viewModel, const Key("HomeView"));

  @override
  Widget build(BuildContext context) {
    return buildDrawerNavigator(
      context,
      drawerMaxWidth: drawerMaxWidth,
      appBar: buildAppBar,
      drawer: buildDrawer,
      onDrawerChanged: (bool isOpen) {
        if (!isOpen) {
          viewModel.updateDrawerStatus(WalletDrawerStatus.close);
        } else {
          viewModel.updateDrawerStatus(WalletDrawerStatus.openSetting);
        }
      },
      content: buildContent,
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
                            child: ListView(children: [
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                              walletListState,
                                            ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                          ],
                                        )),
                                    BtcTitleActionsView(
                                        initialized:
                                            walletListState.initialized,
                                        disableBuy:
                                            viewModel.isBuyMobileDisabled,
                                        onSend: () {
                                          viewModel.move(NavID.send);
                                        },
                                        onBuy: () {
                                          viewModel.move(NavID.buy);
                                        },
                                        onDisabledBuy: () {
                                          viewModel.move(NavID.buyUnavailable);
                                        },
                                        onReceive: () {
                                          move(context, NavID.receive);
                                        }),
                                    const SizedBox(
                                      height: 16,
                                    ),
                                    if (viewModel.canInvite)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: defaultPadding),
                                        child: GestureDetector(
                                          onTap: () {
                                            viewModel.move(NavID.sendInvite);
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
                                                color: ProtonColors
                                                    .backgroundSecondary,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        24.0)),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    context.local
                                                        .invite_your_friends,
                                                    style: ProtonStyles
                                                        .body2Medium(
                                                            color: ProtonColors
                                                                .protonBlue),
                                                  ),
                                                ),
                                                Transform.translate(
                                                  offset: const Offset(6, 0),
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
                                    const SizedBox(
                                      height: 6,
                                    ),
                                    if (viewModel.currentTodoStep <
                                            viewModel.totalTodoSteps &&
                                        !walletTransactionState.isSyncing)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: defaultPadding),
                                        child: GestureDetector(
                                          onTap: () {
                                            viewModel
                                                .move(NavID.secureYourWallet);
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
                                                color: ProtonColors.protonBlue,
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
                                                  style:
                                                      ProtonStyles.body2Medium(
                                                          color: ProtonColors
                                                              .textInverted),
                                                ),
                                                Transform.translate(
                                                  offset: const Offset(6, 0),
                                                  child: Icon(
                                                      Icons
                                                          .arrow_forward_ios_rounded,
                                                      color: ProtonColors
                                                          .textInverted,
                                                      size: 14),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Container(
                                        decoration: BoxDecoration(
                                          color:
                                              getTransactionAndAddressesBackground(
                                                  walletTransactionState,
                                                  viewModel.bodyListStatus),
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(24.0),
                                            topRight: Radius.circular(24.0),
                                            bottomLeft: Radius.circular(24.0),
                                            bottomRight: Radius.circular(24.0),
                                          ),
                                        ),
                                        padding: const EdgeInsets.only(
                                            bottom: 20, top: 10),
                                        child: Column(children: [
                                          TransactionList(viewModel: viewModel),
                                        ])),
                                    if (walletTransactionState
                                            .historyTransaction.isEmpty &&
                                        !walletTransactionState.isSyncing)
                                      Column(children: [
                                        const SizedBox(
                                          height: defaultPadding,
                                        ),
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              ButtonV5(
                                                  enable: walletListState
                                                      .initialized,
                                                  onPressed: () {
                                                    viewModel
                                                        .move(NavID.receive);
                                                  },
                                                  backgroundColor: ProtonColors
                                                      .backgroundSecondary,
                                                  text: S.of(context).receive,
                                                  width: context.width > 424
                                                      ? 180
                                                      : context.width / 2 -
                                                          defaultPadding * 2,
                                                  textStyle:
                                                      ProtonStyles.body1Medium(
                                                    color:
                                                        ProtonColors.protonBlue,
                                                  ),
                                                  height: 55),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              if (!viewModel
                                                  .isBuyMobileDisabled)
                                                ButtonV5(
                                                    enable: walletListState
                                                        .initialized,
                                                    onPressed: () {
                                                      viewModel.move(NavID.buy);
                                                    },
                                                    onDisablePressed: () {
                                                      viewModel.move(
                                                          NavID.buyUnavailable);
                                                    },
                                                    textDisableStyle:
                                                        ProtonStyles
                                                            .body1Medium(
                                                      color: ProtonColors
                                                          .textDisable,
                                                    ),
                                                    disableWithAction: viewModel
                                                        .isBuyMobileDisabled,
                                                    backgroundColor: viewModel
                                                            .isBuyMobileDisabled
                                                        ? ProtonColors
                                                            .interActionWeak
                                                        : ProtonColors.black,
                                                    text: S.of(context).buy,
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
                                                            defaultPadding * 2,
                                                    textStyle: ProtonStyles
                                                        .body1Medium(
                                                            color: ProtonColors
                                                                .textInverted),
                                                    height: 55),
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
                                                    .isEmpty &&
                                                !walletTransactionState
                                                    .isSyncing)
                                              Text(
                                                  S.of(context).explore_wallet,
                                                  style:
                                                      ProtonStyles.body1Medium(
                                                          color: ProtonColors
                                                              .textNorm)),
                                            const SizedBox(height: 10),
                                            if (walletTransactionState
                                                    .historyTransaction
                                                    .isEmpty &&
                                                !walletTransactionState
                                                    .isSyncing)
                                              Column(children: [
                                                DiscoverFeedsView(
                                                  onTap: (String link) {
                                                    launchUrl(Uri.parse(link),
                                                        mode: LaunchMode
                                                            .externalApplication);
                                                  },
                                                  protonFeedItems:
                                                      viewModel.protonFeedItems,
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
                              priceGraphDataProvider:
                                  viewModel.priceGraphDataProvider,
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
    WalletListState walletListState,
  ) {
    if (accountName.isEmpty || walletTransactionState.syncedWithError) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          children: [
            accountName.isNotEmpty
                ? Text(accountName,
                    style:
                        ProtonStyles.body1Regular(color: ProtonColors.textHint))
                : const CustomCardLoadingBuilder(
                    width: 200,
                    height: 16,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    margin: EdgeInsets.only(top: 4),
                  ).build(context),
            const SizedBox(
              width: 30,
            ),
            if (walletTransactionState.syncedWithError &&
                walletTransactionState.errorMessage.isNotEmpty)
              GestureDetector(
                  onTap: () {
                    CommonHelper.showErrorDialog(
                      walletTransactionState.errorMessage,
                    );
                  },
                  child: Icon(
                    Icons.warning_amber_rounded,
                    size: 24,
                    color: ProtonColors.notificationWaning,
                  )),
          ],
        ),
        const SizedBox(
          height: 2,
        ),
        const CustomCardLoadingBuilder(
          width: 200,
          height: 36,
          borderRadius: BorderRadius.all(Radius.circular(4)),
          margin: EdgeInsets.only(top: 4),
        ).build(context),
        const SizedBox(
          height: 2,
        ),
        const CustomCardLoadingBuilder(
          width: 200,
          height: 16,
          borderRadius: BorderRadius.all(Radius.circular(4)),
          margin: EdgeInsets.only(top: 4),
        ).build(context),
      ]);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(children: [
          Text(accountName,
              style: ProtonStyles.body1Medium(color: ProtonColors.textHint)),
          const SizedBox(
            height: 4,
          ),
        ]),
        Row(children: [
          showBalanceLoading(
            viewModel,
            walletBalanceState,
            walletTransactionState,
            needExchangeRate: true,
          )
              ? const CustomCardLoadingBuilder(
                  width: 200,
                  height: 36,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  margin: EdgeInsets.only(top: 4),
                ).build(context)
              : viewModel.displayBalance
                  ? AnimatedFlipCounter(
                      prefix: viewModel.getFiatCurrencySign(
                          fiatCurrency:
                              viewModel.currentExchangeRate.fiatCurrency),
                      thousandSeparator: ",",
                      value: ExchangeCalculator.getNotionalInFiatCurrency(
                        viewModel.currentExchangeRate,
                        walletBalanceState.balanceInSatoshi,
                      ),
                      fractionDigits: defaultDisplayDigits,
                      textStyle: ProtonWalletStyles.textAmount(
                        color: ProtonColors.textNorm,
                        fontVariation: 600.0,
                        height: 1.0,
                      ))
                  : Text(
                      "${viewModel.getFiatCurrencySign(fiatCurrency: viewModel.currentExchangeRate.fiatCurrency)}$hidedBalanceString",
                      style: ProtonWalletStyles.textAmount(
                        color: ProtonColors.textNorm,
                        fontVariation: 600.0,
                        height: 1.0,
                      ),
                    ),
          const SizedBox(width: 10),
          viewModel.displayBalance
              ? GestureDetector(
                  onTap: () {
                    viewModel.setDisplayBalance(display: false);
                  },
                  child: Icon(
                    Icons.visibility_off_outlined,
                    size: 24,
                    color: ProtonColors.textWeak,
                  ))
              : GestureDetector(
                  onTap: () {
                    viewModel.setDisplayBalance(display: true);
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
        showBalanceLoading(
          viewModel,
          walletBalanceState,
          walletTransactionState,
          needExchangeRate: false,
        )
            ? const CustomCardLoadingBuilder(
                width: 200,
                height: 16,
                borderRadius: BorderRadius.all(Radius.circular(4)),
                margin: EdgeInsets.only(top: 4),
              ).build(context)
            : viewModel.displayBalance
                ? Text(
                    ExchangeCalculator.getBitcoinUnitLabel(
                      viewModel.bitcoinUnit,
                      walletBalanceState.balanceInSatoshi,
                    ),
                    style:
                        ProtonStyles.body1Medium(color: ProtonColors.textHint)
                            .copyWith(height: 1))
                : Text(
                    "$hidedBalanceString ${viewModel.bitcoinUnit.name.toUpperCase() != "MBTC" ? viewModel.bitcoinUnit.name.toUpperCase() : "mBTC"}",
                    style:
                        ProtonStyles.body1Medium(color: ProtonColors.textHint)
                            .copyWith(height: 1),
                  ),
      ],
    );
  }

  bool showBalanceLoading(
    HomeViewModel viewModel,
    WalletBalanceState walletBalanceState,
    WalletTransactionState walletTransactionState, {
    required bool needExchangeRate,
  }) {
    if (needExchangeRate) {
      /// we will need to show card loading when exchange rate is not initialized
      /// if user has 0 balance, and the wallet is still syncing, we
      /// will need to show card loading to let user know the wallet is still syncing
      /// so we didn't display actual balance to user; otherwise we can display cached balance first.
      return viewModel.currentExchangeRate.id == defaultExchangeRate.id ||
          (walletTransactionState.isSyncing &&
              walletBalanceState.balanceInSatoshi == 0);
    }
    return (walletTransactionState.isSyncing &&
        walletBalanceState.balanceInSatoshi == 0);
  }

  Color getTransactionAndAddressesBackground(
      WalletTransactionState walletTransactionState,
      BodyListStatus listStatus) {
    if (listStatus == BodyListStatus.transactionList) {
      return walletTransactionState.historyTransaction.isEmpty
          ? ProtonColors.backgroundNorm
          : ProtonColors.backgroundSecondary;
    } else {
      return walletTransactionState.bitcoinAddresses.isEmpty
          ? ProtonColors.backgroundNorm
          : ProtonColors.backgroundSecondary;
    }
  }

  Drawer buildDrawer(BuildContext context) {
    return Drawer(
        shape: const RoundedRectangleBorder(),
        backgroundColor: ProtonColors.drawerBackground,
        width: min(MediaQuery.of(context).size.width - 70, drawerMaxWidth),
        child: buildSidebar(context, viewModel));
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: viewModel.walletDrawerStatus ==
                WalletDrawerStatus.close
            ? Provider.of<ThemeProvider>(context, listen: false).isDarkMode()
                ? Brightness.light
                : Brightness.dark
            : Brightness.light,
        // For Android (dark icons)
        statusBarBrightness: viewModel.walletDrawerStatus ==
                WalletDrawerStatus.close
            ? Provider.of<ThemeProvider>(context, listen: false).isDarkMode()
                ? Brightness.dark
                : Brightness.light
            : Brightness.dark,
      ),
      backgroundColor: ProtonColors.backgroundNorm,
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
              style: ProtonStyles.body2Medium(color: ProtonColors.textNorm),
            );
          }),
      centerTitle: true,
      actions: [
        BlocBuilder<WalletListBloc, WalletListState>(
            bloc: viewModel.walletListBloc,
            builder: (context, state) {
              return IconButton(
                icon: Assets.images.icon.walletEdit
                    .applyThemeIfNeeded(context)
                    .svg(
                      fit: BoxFit.fill,
                      width: 40,
                      height: 40,
                    ),
                onPressed: () {
                  /// temperay
                  final context = Coordinator.rootNavigatorKey.currentContext;
                  if (context != null) {
                    if (state.initialized && state.walletsModel.isEmpty) {
                      viewModel.setOnBoard();
                      return;
                    }
                    for (final walletMenuModel in state.walletsModel) {
                      if (walletMenuModel.isSelected) {
                        viewModel.showWalletSettings(
                          walletMenuModel,
                        );
                        break;
                      }

                      /// check if it's wallet account view
                      bool inAccount = false;
                      for (final accountMenuModel in walletMenuModel.accounts) {
                        if (accountMenuModel.isSelected) {
                          viewModel.showWalletSettings(
                            walletMenuModel,
                          );
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
              icon: Assets.images.icon.drawerMenu
                  .applyThemeIfNeeded(context)
                  .svg(fit: BoxFit.fill, width: 40, height: 40),
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
  return BlocBuilder<WalletListBloc, WalletListState>(
      bloc: viewModel.walletListBloc,
      builder: (context, state) {
        return SafeArea(
            child: SingleChildScrollView(
                child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height,
                        ),
                        child: IntrinsicHeight(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                              const SizedBox(height: 30),
                              // logo section
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: defaultPadding),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Assets.images.icon.logoText.svg(
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
                                  displayName: viewModel.getDisplayName(),
                                  userEmail: viewModel.getUserEmail()),
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
                                          style: ProtonStyles.body2Regular(
                                              color: ProtonColors.textHint),
                                        ),
                                        GestureDetector(
                                            onTap: () {
                                              viewModel.setOnBoard();
                                            },
                                            child: Assets
                                                .images.icon.icPlusCircle
                                                .svg(
                                                    fit: BoxFit.fill,
                                                    width: 20,
                                                    height: 20)),
                                      ])),
                              const SizedBox(
                                height: 10,
                              ),

                              /// wallet list
                              SidebarWalletItems(
                                walletListBloc: viewModel.walletListBloc,
                                // select wallet
                                selectAccount: (wallet, account) {
                                  if (viewModel.isMobileSize) {
                                    Navigator.of(context).pop();
                                  }
                                  viewModel.selectAccount(wallet, account);
                                },
                                selectWallet: (wallet) {
                                  if (viewModel.isMobileSize) {
                                    Navigator.of(context).pop();
                                  }
                                  viewModel.selectWallet(wallet);
                                },

                                /// delete wallet when un valid
                                onDelete: (
                                  wallet, {
                                  required hasBalance,
                                  required isInvalidWallet,
                                }) {
                                  viewModel.showDeleteWallet(
                                    wallet,
                                    triggerFromSidebar: true,
                                  );
                                },

                                /// update passphrase
                                updatePassphrase: (wallet) {
                                  viewModel.showImportWalletPassphrase(
                                    wallet,
                                  );
                                },

                                /// add new account into wallet
                                addAccount: (wallet) {
                                  viewModel.walletIDtoAddAccount =
                                      wallet.walletModel.walletID;
                                  viewModel.move(NavID.addWalletAccount);
                                },
                                viewModel: viewModel,
                              ),

                              /// home more settings
                              HomeMoreSettings(
                                onUpgrade: () {},
                                onDiscover: () {
                                  viewModel.move(NavID.discover);
                                },
                                onSettings: () {
                                  viewModel.move(NavID.settings);
                                },
                                onSecurity: () {
                                  viewModel.move(NavID.securitySetting);
                                },
                                onRecovery: () {
                                  viewModel.move(NavID.recovery);
                                },
                                onReportBug: () {
                                  viewModel.move(NavID.natvieReportBugs);
                                },
                                onLogout: () async {
                                  await viewModel.logout();
                                },
                              ),

                              const SizedBox(height: 10),
                              const Expanded(
                                child: SizedBox(height: 20),
                              ),

                              /// app version fixed at bottom
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    viewModel.appVersion,
                                    style: ProtonStyles.captionRegular(
                                      color: ProtonColors.textHint,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                            ]))))));
      });
}

Widget showUpdateWalletPassphraseDialog(
    BuildContext context, HomeViewModel viewModel, WalletModel walletModel) {
  final TextEditingController textEditingController = TextEditingController();
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
          EasyLoading.show(maskType: EasyLoadingMaskType.black);
          try {
            await viewModel.updatePassphrase(
                walletModel.walletID, textEditingController.text);
            await Future.delayed(const Duration(seconds: 1));
          } on BridgeError catch (e, stacktrace) {
            viewModel.errorMessage = e.localizedString;
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
  FiatCurrency? fiatCurrency = accountModel.getFiatCurrency();
  final ProtonExchangeRate? exchangeRate =
      ExchangeRateService.getExchangeRateOrNull(fiatCurrency);
  final double estimateValue = ExchangeCalculator.getNotionalInFiatCurrency(
      exchangeRate ?? viewModel.currentExchangeRate,
      accountModel.balance.toInt());
  if (exchangeRate == null) {
    fiatCurrency = null;
  }
  return Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
    Text(
        "${viewModel.getFiatCurrencyName(fiatCurrency: fiatCurrency)}${estimateValue.toStringAsFixed(defaultDisplayDigits)}",
        style: ProtonStyles.captionSemibold(color: textColor)),
    Text(
        ExchangeCalculator.getBitcoinUnitLabel(
            viewModel.bitcoinUnit, accountModel.balance.toInt()),
        style: ProtonStyles.overlineRegular(color: ProtonColors.textHint))
  ]);
}
