import 'dart:math';
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
import 'package:wallet/helper/avatar.color.helper.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/local_toast.dart';
import 'package:wallet/helper/secure_storage_helper.dart';
import 'package:wallet/helper/user.settings.provider.dart';
import 'package:wallet/helper/wallet_manager.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/provider/proton.wallet.provider.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/home.v3/bottom.sheet/add.wallet.account.dart';
import 'package:wallet/scenes/home.v3/bottom.sheet/email.integration.setting.dart';
import 'package:wallet/scenes/home.v3/bottom.sheet/fiat.currency.setting.dart';
import 'package:wallet/scenes/home.v3/bottom.sheet/passphrase.dart';
import 'package:wallet/scenes/home.v3/bottom.sheet/secure.your.wallet.dart';
import 'package:wallet/scenes/home.v3/bottom.sheet/transaction.filter.dart';
import 'package:wallet/scenes/home.v3/bottom.sheet/wallet.setting.dart';
import 'package:wallet/scenes/home.v3/home.viewmodel.dart';
import 'package:wallet/scenes/settings/settings.account.v2.view.dart';
import 'package:wallet/theme/theme.font.dart';
import 'package:wallet/l10n/generated/locale.dart';

const double drawerMaxWidth = 400;

class HomeView extends ViewBase<HomeViewModel> {
  const HomeView(HomeViewModel viewModel)
      : super(viewModel, const Key("HomeView"));

  @override
  Widget buildWithViewModel(
      BuildContext context, HomeViewModel viewModel, ViewSize viewSize) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: ProtonColors.backgroundProton,
      appBar: AppBar(
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
              WalletSettingSheet.show(context, viewModel);
            },
          )
        ],
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: SvgPicture.asset("assets/images/icon/drawer_menu.svg",
                  fit: BoxFit.fill, width: 40, height: 40),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        scrolledUnderElevation:
            0.0, // don't change background color when scroll down
      ),
      drawer: Drawer(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(0), bottomRight: Radius.circular(0)),
          ),
          backgroundColor: ProtonColors.drawerBackground,
          width: min(MediaQuery.of(context).size.width - 70, drawerMaxWidth),
          child: buildSidebar(context, viewModel)),
      onDrawerChanged: (isOpen) {
        if (isOpen == false) {
          viewModel.saveUserSettings();
          viewModel.updateDrawerStatus(WalletDrawerStatus.close);
        } else {
          viewModel.updateDrawerStatus(WalletDrawerStatus.openSetting);
        }
      },
      body: Center(
        child: ListView(scrollDirection: Axis.vertical, children: [
          Container(
              margin: const EdgeInsets.symmetric(horizontal: defaultPadding),
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
                              Text(
                                  "${Provider.of<UserSettingProvider>(context).getFiatCurrencySign()}${Provider.of<UserSettingProvider>(context).getNotionalInFiatCurrency(Provider.of<ProtonWalletProvider>(context).protonWallet.currentBalance).toStringAsFixed(defaultDisplayDigits)}",
                                  style: FontManager.balanceInFiatCurrency(
                                      ProtonColors.textNorm)),
                              Text(
                                  Provider.of<UserSettingProvider>(context)
                                      .getBitcoinUnitLabel(
                                          Provider.of<ProtonWalletProvider>(
                                                  context)
                                              .protonWallet
                                              .currentBalance
                                              .toInt()),
                                  style: FontManager.balanceInBTC(
                                      ProtonColors.textWeak))
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
                          viewModel.move(NavID.send);
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
                          move(context, viewModel, NavID.receive);
                        }),
                    const SizedBox(
                      height: 10,
                    ),
                    if (Provider.of<ProtonWalletProvider>(context,
                            listen: false)
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
                                  SecureYourWalletSheet.show(
                                      context, viewModel);
                                }
                              },
                              color: ProtonColors.brandLighten20,
                              child: Text(S.of(context).secure_your_wallet,
                                  style: FontManager.body2Median(
                                      ProtonColors.brandLighten20)))),
                    if (viewModel.currentTodoStep < viewModel.totalTodoSteps &&
                        Provider.of<ProtonWalletProvider>(context,
                                listen: false)
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
                                title:
                                    S.of(context).todos_backup_proton_account,
                                checked: viewModel.hadBackup,
                                callback: () {}),
                            const SizedBox(
                              height: 5,
                            ),
                            CustomTodos(
                                title:
                                    S.of(context).todos_backup_wallet_mnemonic,
                                checked: viewModel.hadBackup,
                                callback: () {
                                  move(context, viewModel, NavID.setupBackup);
                                }),
                            const SizedBox(
                              height: 5,
                            ),
                            CustomTodos(
                                title: S.of(context).todos_setup_2fa,
                                checked: viewModel.hadBackup,
                                callback: () {}),
                            const SizedBox(
                              height: 5,
                            ),
                            CustomTodos(
                              title:
                                  S.of(context).todos_setup_email_integration,
                              checked: viewModel.hadSetupEmailIntegration,
                              callback: () {
                                WalletModel? walletModel =
                                    Provider.of<ProtonWalletProvider>(context)
                                        .protonWallet
                                        .currentWallet;
                                AccountModel? accountModel =
                                    Provider.of<ProtonWalletProvider>(context)
                                        .protonWallet
                                        .currentAccount;
                                if (walletModel != null &&
                                    accountModel != null) {
                                  viewModel.updateEmailIntegration(
                                      walletModel, accountModel);
                                }
                                EmailIntegrationSheet.show(context, viewModel);
                              },
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            CustomTodos(
                              title: S.of(context).todos_setup_fiat,
                              checked: viewModel.hadSetFiatCurrency,
                              callback: () {
                                FiatCurrencySettingSheet.show(
                                    context, viewModel);
                              },
                            ),
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
                          Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: defaultPadding),
                              child: viewModel.showSearchHistoryTextField
                                  ? TextFieldText(
                                      borderRadius: 20,
                                      width: MediaQuery.of(context).size.width,
                                      height: 50,
                                      color: ProtonColors.backgroundSecondary,
                                      suffixIcon:
                                          const Icon(Icons.close, size: 16),
                                      prefixIcon:
                                          const Icon(Icons.search, size: 16),
                                      showSuffixIcon: true,
                                      suffixIconOnPressed: () {
                                        viewModel
                                            .setSearchHistoryTextField(false);
                                      },
                                      controller:
                                          viewModel.transactionSearchController,
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(children: [
                                              Text(
                                                S.of(context).transactions,
                                                style: FontManager.body1Median(
                                                    ProtonColors.textNorm),
                                                textAlign: TextAlign.left,
                                              ),
                                            ]),
                                            Row(children: [
                                              IconButton(
                                                  onPressed: () {
                                                    TransactionFilterSheet.show(
                                                        context, viewModel);
                                                  },
                                                  icon: SvgPicture.asset(
                                                      "assets/images/icon/setup-preference.svg",
                                                      fit: BoxFit.fill,
                                                      width: 16,
                                                      height: 16)),
                                              IconButton(
                                                  onPressed: () {
                                                    viewModel
                                                        .setSearchHistoryTextField(
                                                            true);
                                                  },
                                                  icon: Icon(
                                                      Icons.search_rounded,
                                                      color:
                                                          ProtonColors.textNorm,
                                                      size: 16))
                                            ]),
                                          ]))),
                          for (int index = 0;
                              index <
                                  min(
                                      Provider.of<ProtonWalletProvider>(context)
                                          .protonWallet
                                          .historyTransactionsAfterFilter
                                          .length,
                                      defaultTransactionPerPage *
                                              viewModel.currentHistoryPage +
                                          defaultTransactionPerPage);
                              index++)
                            TransactionListTitle(
                              width: MediaQuery.of(context).size.width,
                              address: CommonHelper.getFirstNChar(
                                  WalletManager.getEmailFromWalletTransaction(
                                      Provider.of<ProtonWalletProvider>(context)
                                                  .protonWallet
                                                  .historyTransactionsAfterFilter[
                                                      index]
                                                  .amountInSATS >
                                              0
                                          ? Provider.of<ProtonWalletProvider>(
                                                  context)
                                              .protonWallet
                                              .historyTransactionsAfterFilter[
                                                  index]
                                              .sender
                                          : Provider.of<ProtonWalletProvider>(
                                                  context)
                                              .protonWallet
                                              .historyTransactionsAfterFilter[
                                                  index]
                                              .toList),
                                  24),
                              amount: Provider.of<ProtonWalletProvider>(context)
                                  .protonWallet
                                  .historyTransactionsAfterFilter[index]
                                  .amountInSATS
                                  .toDouble(),
                              note: Provider.of<ProtonWalletProvider>(context)
                                      .protonWallet
                                      .historyTransactionsAfterFilter[index]
                                      .label ??
                                  "",
                              body: Provider.of<ProtonWalletProvider>(context)
                                      .protonWallet
                                      .historyTransactionsAfterFilter[index]
                                      .body ??
                                  "",
                              onTap: () {
                                viewModel.selectedTXID =
                                    Provider.of<ProtonWalletProvider>(context,
                                            listen: false)
                                        .protonWallet
                                        .historyTransactionsAfterFilter[index]
                                        .txID;
                                viewModel.historyAccountModel =
                                    Provider.of<ProtonWalletProvider>(context,
                                            listen: false)
                                        .protonWallet
                                        .historyTransactionsAfterFilter[index]
                                        .accountModel;
                                viewModel.move(NavID.historyDetails);
                              },
                              timestamp:
                                  Provider.of<ProtonWalletProvider>(context)
                                      .protonWallet
                                      .historyTransactionsAfterFilter[index]
                                      .createTimestamp,
                              isSend: Provider.of<ProtonWalletProvider>(context)
                                      .protonWallet
                                      .historyTransactionsAfterFilter[index]
                                      .amountInSATS <
                                  0,
                            ),
                          if (Provider.of<ProtonWalletProvider>(context)
                                  .protonWallet
                                  .historyTransactionsAfterFilter
                                  .length >
                              defaultTransactionPerPage *
                                      viewModel.currentHistoryPage +
                                  defaultTransactionPerPage)
                            GestureDetector(
                                onTap: () {
                                  viewModel.showMoreTransactionHistory();
                                },
                                child: Container(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Text("Show more",
                                        style: FontManager.body1Regular(
                                            ProtonColors.protonBlue)))),
                          if (Provider.of<ProtonWalletProvider>(context)
                              .protonWallet
                              .historyTransactionsAfterFilter
                              .isEmpty)
                            Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Center(
                                      child: SvgPicture.asset(
                                          "assets/images/icon/do_transactions.svg",
                                          fit: BoxFit.fill,
                                          width: 26,
                                          height: 26)),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  SizedBox(
                                      width: 280,
                                      child: Text(
                                        "Send and receive Bitcoin with your email.",
                                        style: FontManager.titleHeadline(
                                            ProtonColors.textNorm),
                                        textAlign: TextAlign.center,
                                      )),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ]),
                        ])),
                    if (Provider.of<ProtonWalletProvider>(context)
                        .protonWallet
                        .historyTransactionsAfterFilter
                        .isEmpty)
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
                                  text: S.of(context).receive,
                                  width: 180,
                                  textStyle: FontManager.body1Median(
                                      ProtonColors.protonBlue),
                                  height: 48),
                              const SizedBox(
                                width: 10,
                              ),
                              ButtonV5(
                                  onPressed: () {},
                                  backgroundColor: ProtonColors.backgroundBlack,
                                  text: S.of(context).buy,
                                  width: 180,
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
                          style:
                              FontManager.body1Median(ProtonColors.textNorm)),
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
      ),
    );
  }

  void move(BuildContext context, HomeViewModel viewModel, NavID identifier) {
    if (context.mounted) {
      if (CommonHelper.checkSelectWallet(context)) {
        viewModel.move(identifier);
      }
    }
  }
}

void showMyAlertDialog(BuildContext context, String content) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Secure Storage Info"),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: content)).then(
                  (v) => {LocalToast.showToast(context, S.of(context).copied)});
            },
            child: Text(S.of(context).copy_button),
          )
        ],
      );
    },
  );
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
                    const AccountInfoV2(),
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
                    sidebarWalletItems(context, viewModel),
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
                        onTap: () {
                          Navigator.of(context).pop();
                          viewModel.move(NavID.nativeUpgrade);
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
                          Navigator.of(context).pop();
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
                                  viewModel.move(NavID.setupOnboard);
                                },
                              )
                            ])),
                    const SizedBox(
                      height: 30,
                    ),
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
          Navigator.of(context).pop();
        },
        child: Text(S.of(context).cancel),
      ),
      TextButton(
        onPressed: () async {
          EasyLoading.show(
              status: "saving passphrase..",
              maskType: EasyLoadingMaskType.black);
          try {
            await SecureStorageHelper.instance
                .set(walletModel.serverWalletID, textEditingController.text);
            await Future.delayed(const Duration(seconds: 1));
          } catch (e) {
            viewModel.errorMessage = e.toString();
          }
          EasyLoading.dismiss();
          if (context.mounted) {
            Navigator.of(context).pop(); // pop current dialog
          }
        },
        child: Text(S.of(context).submit),
      ),
    ],
  );
}

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
              onExpansionChanged: (expanded) {
                viewModel.selectWallet(walletModel);
                Navigator.of(context).pop();
              },
              title: Transform.translate(
                  offset: const Offset(-8, 0),
                  child: Provider.of<ProtonWalletProvider>(context)
                          .protonWallet
                          .hasPassphrase(walletModel)
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      CommonHelper.getFirstNChar(
                                          walletModel.name, 12),
                                      style: FontManager.captionSemiBold(
                                          AvatarColorHelper.getTextColor(
                                              Provider.of<ProtonWalletProvider>(
                                                      context)
                                                  .protonWallet
                                                  .wallets
                                                  .indexOf(walletModel)))),
                                  Text(
                                      "${Provider.of<ProtonWalletProvider>(context).protonWallet.getAccountCounts(walletModel)} accounts",
                                      style: FontManager.captionRegular(
                                          ProtonColors.textHint))
                                ],
                              )
                            ])
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
                                        Text(
                                            CommonHelper.getFirstNChar(
                                                walletModel.name, 12),
                                            style: FontManager.captionSemiBold(
                                                AvatarColorHelper.getTextColor(
                                                    Provider.of<ProtonWalletProvider>(
                                                            context)
                                                        .protonWallet
                                                        .wallets
                                                        .indexOf(
                                                            walletModel)))),
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
                                viewModel.coordinator
                                    .showWalletDeletion(walletModel.id ?? 0);
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
                            Navigator.of(context).pop();
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
                          AddWalletAccountSheet.show(
                              context, viewModel, walletModel);
                        },
                        tileColor: ProtonColors.drawerBackground,
                        leading: Container(
                            margin: const EdgeInsets.only(left: 10),
                            child: SvgPicture.asset(
                                "assets/images/icon/add-account.svg",
                                fit: BoxFit.fill,
                                width: 16,
                                height: 16)),
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

Widget getWalletAccountBalanceWidget(BuildContext context,
    HomeViewModel viewModel, AccountModel accountModel, Color textColor) {
  double esitmateValue = Provider.of<UserSettingProvider>(context)
      .getNotionalInFiatCurrency(accountModel.balance.toInt());
  return Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
    Text(
        "${Provider.of<UserSettingProvider>(context).getFiatCurrencySign()}${esitmateValue.toStringAsFixed(defaultDisplayDigits)}",
        style: FontManager.captionSemiBold(textColor)),
    Text(
        Provider.of<UserSettingProvider>(context)
            .getBitcoinUnitLabel(accountModel.balance.toInt()),
        style: FontManager.overlineRegular(ProtonColors.textHint))
  ]);
}
