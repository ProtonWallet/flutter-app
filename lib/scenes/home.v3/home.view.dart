import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/components/custom.expansion.dart';
import 'package:wallet/components/custom.loading.with.icon.dart';
import 'package:wallet/components/custom.newsbox.v2.dart';
import 'package:wallet/components/custom.homepage.box.dart';
import 'package:wallet/components/custom.todo.dart';
import 'package:wallet/components/dropdown.button.v1.dart';
import 'package:wallet/components/textfield.text.dart';
import 'package:wallet/components/textfield.text.v2.dart';
import 'package:wallet/components/transaction/transaction.listtitle.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/script_type.dart';
import 'package:wallet/helper/avatar.color.helper.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/fiat.currency.helper.dart';
import 'package:wallet/helper/local_toast.dart';
import 'package:wallet/helper/secure_storage_helper.dart';
import 'package:wallet/helper/user.settings.provider.dart';
import 'package:wallet/helper/wallet_manager.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/home.v3/home.viewmodel.dart';
import 'package:wallet/scenes/settings/settings.account.v2.view.dart';
import 'package:wallet/theme/theme.font.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/rust/api/proton_api.dart' as proton_api;

const double drawerMaxWidth = 400;

class HomeView extends ViewBase<HomeViewModel> {
  HomeView(HomeViewModel viewModel) : super(viewModel, const Key("HomeView"));

  @override
  Widget buildWithViewModel(
      BuildContext context, HomeViewModel viewModel, ViewSize viewSize) {
    if (viewModel.hasWallet == false && viewModel.initialed) {
      viewModel.setOnBoard(context);
    }
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
          viewModel.currentWallet != null
              ? (viewModel.walletID2Accounts.isNotEmpty &&
                      viewModel.walletID2Accounts[viewModel.currentWallet!.id]!
                              .length >
                          1)
                  ? "${viewModel.currentWallet!.name} - ${viewModel.currentAccount!.labelDecrypt}"
                  : viewModel.currentWallet!.name
              : S.of(context).proton_wallet,
          style: FontManager.titleHeadline(ProtonColors.textNorm),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: SvgPicture.asset("assets/images/icon/wallet_edit.svg",
                fit: BoxFit.fill, width: 40, height: 40),
            onPressed: () {
              showWalletSetting(context, viewModel);
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
          width: min(MediaQuery.of(context).size.width, drawerMaxWidth),
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
                                  viewModel.customFiatCurrency
                                      ? "${Provider.of<UserSettingProvider>(context).getFiatCurrencySign()}${(Provider.of<UserSettingProvider>(context).walletUserSetting.exchangeRate.exchangeRate * viewModel.balance / 100 / 100000000).toStringAsFixed(defaultDisplayDigits)}"
                                      : Provider.of<UserSettingProvider>(
                                              context)
                                          .getBitcoinUnitLabel(
                                              viewModel.balance.toInt()),
                                  style: FontManager.balanceInFiatCurrency(
                                      ProtonColors.textNorm)),
                              Text(
                                  viewModel.customFiatCurrency
                                      ? Provider.of<UserSettingProvider>(
                                              context)
                                          .getBitcoinUnitLabel(
                                              viewModel.balance.toInt())
                                      : "${Provider.of<UserSettingProvider>(context).getFiatCurrencySign()}${(Provider.of<UserSettingProvider>(context).walletUserSetting.exchangeRate.exchangeRate * viewModel.balance / 100 / 100000000).toStringAsFixed(defaultDisplayDigits)}",
                                  style: FontManager.balanceInBTC(
                                      ProtonColors.textWeak))
                            ],
                          ),
                          const SizedBox(width: 4),
                          viewModel.currentAccount != null
                              ? viewModel.isSyncingMap[viewModel
                                          .currentAccount!.serverAccountID] ??
                                      false
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
                                        viewModel.syncWallet();
                                      },
                                      child: Icon(
                                        Icons.refresh_rounded,
                                        size: 22,
                                        color: ProtonColors.textWeak,
                                      ))
                              : const Icon(null),
                        ]),
                    const SizedBox(
                      height: 20,
                    ),
                    CustomHomePageBox(
                        title: "Current BTC price",
                        iconPath: "assets/images/icon/bitcoin.svg",
                        width: MediaQuery.of(context).size.width -
                            defaultPadding * 2,
                        price: viewModel.btcPriceInfo.price,
                        priceChange: viewModel.btcPriceInfo.priceChange24h,
                        children: [
                          SizedBox(
                              width: 80,
                              child: GestureDetector(
                                onTap: () {
                                  if (viewModel.currentWallet == null) {
                                    LocalToast.showToast(context,
                                        "Please select your wallet first",
                                        icon: null);
                                  } else {
                                    viewModel.move(ViewIdentifiers.send);
                                  }
                                },
                                child: Text(
                                  S.of(context).send_button,
                                  textAlign: TextAlign.center,
                                  style: FontManager.body1Regular(
                                      ProtonColors.textWeak),
                                ),
                              )),
                          SizedBox(
                              width: 80,
                              child: GestureDetector(
                                onTap: () {
                                  if (viewModel.currentWallet == null) {
                                    LocalToast.showToast(context,
                                        "Please select your wallet first",
                                        icon: null);
                                  } else {
                                    viewModel.move(ViewIdentifiers.receive);
                                  }
                                },
                                child: Text(
                                  S.of(context).receive,
                                  textAlign: TextAlign.center,
                                  style: FontManager.body1Regular(
                                      ProtonColors.textWeak),
                                ),
                              )),
                          SizedBox(
                              width: 80,
                              child: GestureDetector(
                                onTap: () {},
                                child: Text(
                                  S.of(context).buy,
                                  textAlign: TextAlign.center,
                                  style: FontManager.body1Regular(
                                      ProtonColors.textWeak),
                                ),
                              )),
                        ]),
                    const SizedBox(
                      height: 10,
                    ),
                    if (viewModel.currentTodoStep < viewModel.totalTodoSteps)
                      CustomExpansion(
                          totalSteps: viewModel.totalTodoSteps,
                          currentStep: viewModel.currentTodoStep,
                          children: [
                            const SizedBox(
                              height: 5,
                            ),
                            CustomTodos(
                                title: "Backup your Recovery Phrase",
                                content: "Keep your account safe!",
                                checked: viewModel.hadBackup,
                                callback: () {
                                  if (viewModel.currentWallet == null) {
                                    LocalToast.showToast(context,
                                        "Please select your wallet first",
                                        icon: null);
                                  } else {
                                    viewModel.move(ViewIdentifiers.setupBackup);
                                  }
                                }),
                            const SizedBox(
                              height: 5,
                            ),
                            CustomTodos(
                              title: "Setup Email Integration",
                              content: "Send Bitcoin via email address",
                              checked: viewModel.hadSetupEmailIntegration,
                              callback: () {
                                viewModel.updateEmailIntegration();
                                showEmailIntegrationSettingGuide(
                                    context, viewModel);
                              },
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            CustomTodos(
                              title: "Set your preferred Fiat currency",
                              content: "Customize your experience",
                              checked: viewModel.hadSetFiatCurrency,
                              callback: () {
                                showFiatCurrencySettingGuide(
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
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Transactions",
                                      style: FontManager.body1Median(
                                          ProtonColors.textNorm),
                                      textAlign: TextAlign.left,
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          showTransactionFilter(
                                              context, viewModel);
                                        },
                                        icon: SvgPicture.asset(
                                            "assets/images/icon/setup-preference.svg",
                                            fit: BoxFit.fill,
                                            width: 16,
                                            height: 16)),
                                  ])),
                          for (int index = 0;
                              index <
                                  min(
                                      viewModel.history.length,
                                      defaultTransactionPerPage *
                                              viewModel.currentHistoryPage +
                                          defaultTransactionPerPage);
                              index++)
                            if (viewModel.checkTransactionFilter(index))
                              TransactionListTitle(
                                width: MediaQuery.of(context).size.width,
                                address: viewModel.fromEmails[index].isNotEmpty
                                    ? CommonHelper.getFirstNChar(
                                        WalletManager
                                            .getEmailFromWalletTransaction(
                                                viewModel.fromEmails[index]),
                                        24)
                                    : "${viewModel.history[index].txid.substring(0, 10)}***${viewModel.history[index].txid.substring(64 - 6)}",
                                amount: (viewModel.getAmount(index)).toDouble(),
                                isSend: viewModel.history[index].sent >
                                    viewModel.history[index].received,
                                note: viewModel.userLabels[index],
                                timestamp: viewModel
                                    .history[index].confirmationTime?.timestamp,
                                onTap: () {
                                  viewModel.selectedTXID =
                                      viewModel.history[index].txid;
                                  viewModel
                                      .move(ViewIdentifiers.historyDetails);
                                },
                              ),
                          if (viewModel.history.length >
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
                          if (viewModel.history.isEmpty)
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
                    const SizedBox(
                      height: 40,
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      ButtonV5(
                          onPressed: () {
                            viewModel.move(ViewIdentifiers.receive);
                          },
                          backgroundColor: ProtonColors.white,
                          text: S.of(context).receive,
                          width: 180,
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
                          width: 180,
                          textStyle: FontManager.body1Median(
                              ProtonColors.backgroundSecondary),
                          height: 48),
                    ]),
                    const SizedBox(height: 20),
                    Text(S.of(context).explore_wallet,
                        style: FontManager.body1Median(ProtonColors.textNorm)),
                    const SizedBox(height: 10),
                    SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 200,
                        child: ListView(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            physics: const ClampingScrollPhysics(),
                            children: [
                              CustomNewsBoxV2(
                                  title: S.of(context).security_n_proton_wallet,
                                  content: S
                                      .of(context)
                                      .how_to_stay_safe_and_protect_your_assets,
                                  iconPath: "assets/images/icon/protect.svg",
                                  headerBackground: const Color(0x668B93FF),
                                  width: 160),
                              const SizedBox(width: 10),
                              CustomNewsBoxV2(
                                  title: S.of(context).wallets_n_accounts,
                                  content: S
                                      .of(context)
                                      .whats_the_different_and_how_to_use_them,
                                  iconPath: "assets/images/icon/wallet.svg",
                                  headerBackground: const Color(0x66FE7A36),
                                  width: 160),
                              const SizedBox(width: 10),
                              CustomNewsBoxV2(
                                  title: S.of(context).transfer_bitcoin,
                                  content: S
                                      .of(context)
                                      .how_to_send_and_receive_bitcoin_with_proton,
                                  iconPath: "assets/images/icon/transfer.svg",
                                  headerBackground: const Color(0x660D9276),
                                  width: 160),
                              const SizedBox(width: 10),
                              CustomNewsBoxV2(
                                  title: S.of(context).mobile_apps,
                                  content: S
                                      .of(context)
                                      .start_using_proton_wallet_on_your_phone,
                                  iconPath: "assets/images/icon/mobile.svg",
                                  headerBackground: const Color(0x66FF6868),
                                  width: 160),
                              const SizedBox(width: 10),
                            ])),
                    const SizedBox(height: 20),
                    // Text("Transaction Fees",
                    //     style: FontManager.body1Median(ProtonColors.textNorm)),
                    // const SizedBox(height: 10),
                    // Container(
                    //     width: MediaQuery.of(context).size.width,
                    //     height: 110,
                    //     child: ListView(
                    //         scrollDirection: Axis.horizontal,
                    //         shrinkWrap: true,
                    //         physics: const ClampingScrollPhysics(),
                    //         children: [
                    //           TransactionFeeBox(
                    //             priorityText: "High Priority",
                    //             timeEstimate: "In ~10 minutes",
                    //             fee: viewModel.bitcoinTransactionFee.block1Fee,
                    //           ),
                    //           const SizedBox(width: 10),
                    //           TransactionFeeBox(
                    //             priorityText: "Median Priority",
                    //             timeEstimate: "In ~30 minutes",
                    //             fee: viewModel.bitcoinTransactionFee.block3Fee,
                    //           ),
                    //           const SizedBox(width: 10),
                    //           TransactionFeeBox(
                    //             priorityText: "Low Priority",
                    //             timeEstimate: "In ~50 minutes",
                    //             fee: viewModel.bitcoinTransactionFee.block5Fee,
                    //           ),
                    //           const SizedBox(width: 10),
                    //           TransactionFeeBox(
                    //             priorityText: "No Priority",
                    //             timeEstimate: "In ~3.5 hours",
                    //             fee: viewModel.bitcoinTransactionFee.block20Fee,
                    //           ),
                    //         ])),
                    const SizedBox(height: 40),
                  ])),
        ]),
      ),
    );
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

void showAddWalletAccountGuide(
    BuildContext context, HomeViewModel viewModel, WalletModel walletModel) {
  showModalBottomSheet(
      context: context,
      backgroundColor: ProtonColors.backgroundProton,
      constraints: BoxConstraints(
        minWidth: MediaQuery.of(context).size.width,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
      ),
      builder: (BuildContext context) {
        ValueNotifier scriptTypeValueNotifier =
            ValueNotifier(ScriptType.nativeSegWit);
        TextEditingController labelController = TextEditingController(text: "");
        return Container(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  DropdownButtonV1(
                      labelText: S.of(context).script_type,
                      width: MediaQuery.of(context).size.width -
                          defaultPadding * 2,
                      items: ScriptType.scripts,
                      itemsText: ScriptType.scripts.map((v) => v.name).toList(),
                      valueNotifier: scriptTypeValueNotifier),
                  const SizedBox(height: 12),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: defaultPadding),
                    child: TextFieldTextV2(
                      labelText: S.of(context).account_label,
                      textController: labelController,
                      myFocusNode: FocusNode(),
                      validation: (String value) {
                        if (value.isEmpty) {
                          return "Required";
                        }
                        return "";
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                      padding: const EdgeInsets.only(top: 20),
                      margin: const EdgeInsets.symmetric(
                          horizontal: defaultButtonPadding),
                      child: ButtonV5(
                          onPressed: () async {
                            EasyLoading.show(
                                status: "Adding account..",
                                maskType: EasyLoadingMaskType.black);
                            await viewModel.addWalletAccount(
                                walletModel.id!,
                                scriptTypeValueNotifier.value,
                                labelController.text);
                            EasyLoading.dismiss();
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                          backgroundColor: ProtonColors.protonBlue,
                          text: S.of(context).add_account,
                          width: MediaQuery.of(context).size.width,
                          textStyle: FontManager.body1Median(
                              ProtonColors.backgroundSecondary),
                          height: 48)),
                ]));
      });
}

void showFiatCurrencySettingGuide(
    BuildContext context, HomeViewModel viewModel) {
  showModalBottomSheet(
      context: context,
      backgroundColor: ProtonColors.backgroundProton,
      constraints: BoxConstraints(
        minWidth: MediaQuery.of(context).size.width,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
      ),
      builder: (BuildContext context) {
        return Container(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),
                  DropdownButtonV1(
                      labelText: S.of(context).setting_fiat_currency_label,
                      width: MediaQuery.of(context).size.width -
                          defaultPadding * 2,
                      items: fiatCurrencies,
                      itemsText: fiatCurrencies
                          .map((v) => FiatCurrencyHelper.getText(v))
                          .toList(),
                      valueNotifier: viewModel.fiatCurrencyNotifier),
                  Container(
                      padding: const EdgeInsets.only(top: 20),
                      margin: const EdgeInsets.symmetric(
                          horizontal: defaultButtonPadding),
                      child: ButtonV5(
                          onPressed: () {
                            viewModel.updateFiatCurrency(
                                viewModel.fiatCurrencyNotifier.value);
                            viewModel.saveUserSettings();
                            Navigator.pop(context);
                          },
                          backgroundColor: ProtonColors.protonBlue,
                          text: S.of(context).save,
                          width: MediaQuery.of(context).size.width,
                          textStyle: FontManager.body1Median(
                              ProtonColors.backgroundSecondary),
                          height: 48)),
                ]));
      });
}

void showEmailIntegrationSettingGuide(
    BuildContext context, HomeViewModel viewModel) {
  AccountModel userAccount = viewModel.currentAccount!;
  bool emailIntegrationEnable =
      viewModel.accountID2IntegratedEmailIDs[userAccount.id]!.isNotEmpty;
  ValueNotifier emailIntegrationNotifier =
      ValueNotifier(viewModel.protonAddresses.firstOrNull);
  showModalBottomSheet(
      context: context,
      backgroundColor: ProtonColors.backgroundProton,
      constraints: BoxConstraints(
        minWidth: MediaQuery.of(context).size.width,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return SingleChildScrollView(
              child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16, horizontal: defaultPadding),
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(children: [
                          const SizedBox(height: 10),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Email Integration",
                                    style: FontManager.body2Regular(
                                        ProtonColors.textNorm)),
                                CupertinoSwitch(
                                  value: emailIntegrationEnable,
                                  activeColor: ProtonColors.protonBlue,
                                  onChanged: (bool newValue) {
                                    setState(() {
                                      emailIntegrationEnable = newValue;
                                    });
                                  },
                                )
                              ]),
                          const SizedBox(height: 10),
                          if (emailIntegrationEnable)
                            for (String addressID
                                in viewModel.accountID2IntegratedEmailIDs[
                                        userAccount.id] ??
                                    [])
                              Container(
                                  margin: const EdgeInsets.only(bottom: 5),
                                  child: TextFieldText(
                                    width:
                                        MediaQuery.of(context).size.width - 60,
                                    height: 50,
                                    color: ProtonColors.backgroundSecondary,
                                    suffixIcon: const Icon(Icons.close),
                                    showSuffixIcon: true,
                                    showEnabledBorder: false,
                                    suffixIconOnPressed: () async {
                                      EasyLoading.show(
                                          status: "removing email..",
                                          maskType: EasyLoadingMaskType.black);
                                      await viewModel.removeEmailAddress(
                                          viewModel
                                              .currentWallet!.serverWalletID,
                                          userAccount.serverAccountID,
                                          addressID);
                                      EasyLoading.dismiss();
                                      setState(() {
                                        viewModel.reloadPage();
                                      });
                                    },
                                    controller: TextEditingController(
                                        text: viewModel
                                            .getProtonAddressByID(addressID)!
                                            .email),
                                  )),
                          const SizedBox(height: 10),
                          if (emailIntegrationEnable)
                            Column(children: [
                              const SizedBox(height: 10),
                              DropdownButtonV1(
                                labelText: S.of(context).add_email_to_account,
                                items: viewModel.protonAddresses,
                                itemsText: viewModel.protonAddresses
                                    .map((e) => e.email)
                                    .toList(),
                                valueNotifier: emailIntegrationNotifier,
                                width: MediaQuery.of(context).size.width,
                              ),
                              const SizedBox(height: 10),
                              ButtonV5(
                                  onPressed: () async {
                                    EasyLoading.show(
                                        status: "adding email..",
                                        maskType: EasyLoadingMaskType.black);
                                    await viewModel
                                        .addEmailAddressToWalletAccount(
                                            viewModel
                                                .currentWallet!.serverWalletID,
                                            userAccount.serverAccountID,
                                            emailIntegrationNotifier.value.id);
                                    EasyLoading.dismiss();
                                    setState(() {
                                      viewModel.reloadPage();
                                    });
                                  },
                                  backgroundColor: ProtonColors.protonBlue,
                                  text: S.of(context).add,
                                  width: MediaQuery.of(context).size.width,
                                  textStyle: FontManager.body1Median(
                                      ProtonColors.white),
                                  radius: 40,
                                  height: 52),
                              const SizedBox(height: 10),
                            ]),
                        ])
                      ])));
        });
      });
}

void showTransactionFilter(BuildContext context, HomeViewModel viewModel) {
  if (viewModel.currentWallet == null) {
    LocalToast.showToast(context, "Please select your wallet first",
        icon: null);
    return;
  }
  showModalBottomSheet(
    context: context,
    backgroundColor: ProtonColors.backgroundProton,
    constraints: BoxConstraints(
      minWidth: MediaQuery.of(context).size.width,
    ),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
    ),
    builder: (BuildContext context) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 5,
                ),
                ListTile(
                  leading: Icon(
                      viewModel.transactionFilter == ""
                          ? Icons.check_rounded
                          : null,
                      size: 18),
                  title: Text("All transactions (default)",
                      style: FontManager.body2Regular(ProtonColors.textNorm)),
                  onTap: () {
                    viewModel.updateTransactionFilter("");
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: Icon(
                      viewModel.transactionFilter.contains("send")
                          ? Icons.check_rounded
                          : null,
                      size: 18),
                  title: Text("Send only",
                      style: FontManager.body2Regular(ProtonColors.textNorm)),
                  onTap: () {
                    viewModel.updateTransactionFilter("send");
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: Icon(
                      viewModel.transactionFilter.contains("receive")
                          ? Icons.check_rounded
                          : null,
                      size: 18),
                  title: Text("Receive only",
                      style: FontManager.body2Regular(ProtonColors.textNorm)),
                  onTap: () {
                    viewModel.updateTransactionFilter("receive");
                    Navigator.of(context).pop();
                  },
                ),
              ],
            )
          ],
        ),
      );
    },
  );
}

void showWalletSetting(BuildContext context, HomeViewModel viewModel) {
  if (viewModel.currentWallet == null) {
    LocalToast.showToast(context, "Please select your wallet first",
        icon: null);
    return;
  }
  showModalBottomSheet(
      context: context,
      backgroundColor: ProtonColors.backgroundProton,
      isScrollControlled: true,
      constraints: BoxConstraints(
        minWidth: MediaQuery.of(context).size.width,
        maxHeight: MediaQuery.of(context).size.height - 60,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
      ),
      builder: (BuildContext context) {
        TextEditingController walletNameController =
            TextEditingController(text: viewModel.currentWallet!.name);
        List<AccountModel> userAccounts =
            viewModel.walletID2Accounts[viewModel.currentWallet!.id] ?? [];

        Map<int, TextEditingController> accountNameControllers = {
          for (var item in userAccounts)
            item.id!: TextEditingController(text: item.labelDecrypt)
        };
        Map<int, bool> emailIntegrationEnables = {
          for (var item in userAccounts)
            item.id!:
                viewModel.accountID2IntegratedEmailIDs[item.id]!.isNotEmpty
        };
        Map<int, ValueNotifier> emailIntegrationNotifiers = {
          for (var item in userAccounts)
            item.id!: ValueNotifier(viewModel.protonAddresses.firstOrNull)
        };

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
                child: Container(
              padding: const EdgeInsets.symmetric(
                  vertical: defaultPadding, horizontal: defaultPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                      radius: 18,
                      backgroundColor: ProtonColors.white,
                      child: IconButton(
                        icon: Icon(Icons.close_rounded,
                            color: ProtonColors.textNorm, size: 16),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      TextFieldTextV2(
                        labelText: S.of(context).wallet_name,
                        textController: walletNameController,
                        myFocusNode: FocusNode(),
                        onFinish: () async {
                          await proton_api.updateWalletName(
                              walletId: viewModel.currentWallet!.serverWalletID,
                              newName: walletNameController.text);
                          viewModel.currentWallet!.name =
                              walletNameController.text;
                          await DBHelper.walletDao!
                              .update(viewModel.currentWallet!);
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
                            // border: Border.all(color: Colors.black, width: 1.0),
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                          child: Column(children: [
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
                                      Text(S.of(context).custom_bitcoin_unit,
                                          style: FontManager.body2Regular(
                                              ProtonColors.textNorm)),
                                      CupertinoSwitch(
                                        value: viewModel.customBitcoinUnit,
                                        activeColor: ProtonColors.protonBlue,
                                        onChanged: (bool newValue) {
                                          setState(() {
                                            viewModel.customBitcoinUnit =
                                                newValue;
                                            if (newValue == false) {
                                              viewModel.bitcoinUnitNotifier
                                                  .value = BitcoinUnit.btc;
                                            }
                                          });
                                        },
                                      ),
                                    ])),
                            if (viewModel.customBitcoinUnit)
                              DropdownButtonV1(
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
                      Container(
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: ProtonColors.white,
                            // border: Border.all(color: Colors.black, width: 1.0),
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                          child: Column(children: [
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
                                      Text(S.of(context).custom_fiat_currency,
                                          style: FontManager.body2Regular(
                                              ProtonColors.textNorm)),
                                      CupertinoSwitch(
                                        value: viewModel.customFiatCurrency,
                                        activeColor: ProtonColors.protonBlue,
                                        onChanged: (bool newValue) {
                                          setState(() {
                                            viewModel.customFiatCurrency =
                                                newValue;
                                            if (newValue == false) {
                                              viewModel.fiatCurrencyNotifier
                                                  .value = FiatCurrency.usd;
                                            }
                                          });
                                        },
                                      ),
                                    ])),
                            if (viewModel.customFiatCurrency)
                              DropdownButtonV1(
                                  labelText:
                                      S.of(context).setting_fiat_currency_label,
                                  width: MediaQuery.of(context).size.width -
                                      defaultPadding * 2,
                                  items: fiatCurrencies,
                                  itemsText: fiatCurrencies
                                      .map((v) => FiatCurrencyHelper.getText(v))
                                      .toList(),
                                  valueNotifier:
                                      viewModel.fiatCurrencyNotifier),
                            const SizedBox(
                              height: 10,
                            ),
                          ])),
                      const SizedBox(
                        height: defaultPadding,
                      ),
                      Text(S.of(context).accounts,
                          style:
                              FontManager.body2Median(ProtonColors.textNorm)),
                      const SizedBox(
                        height: defaultPadding,
                      ),
                      for (AccountModel userAccount in viewModel
                              .walletID2Accounts[viewModel.currentWallet!.id] ??
                          [])
                        Container(
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: ProtonColors.white,
                              // border: Border.all(color: Colors.black, width: 1.0),
                              borderRadius: BorderRadius.circular(18.0),
                            ),
                            child: Column(children: [
                              TextFieldTextV2(
                                labelText: S.of(context).account_label,
                                textController:
                                    accountNameControllers[userAccount.id!]!,
                                myFocusNode: FocusNode(),
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
                                              emailIntegrationEnables[
                                                  userAccount.id!] = newValue;
                                            });
                                          },
                                        )
                                      ])),
                              const SizedBox(height: 10),
                              if (emailIntegrationEnables[userAccount.id!]!)
                                for (String addressID
                                    in viewModel.accountID2IntegratedEmailIDs[
                                            userAccount.id] ??
                                        [])
                                  Container(
                                      margin: const EdgeInsets.only(bottom: 5),
                                      child: TextFieldText(
                                        width:
                                            MediaQuery.of(context).size.width -
                                                60,
                                        height: 50,
                                        color: ProtonColors.backgroundSecondary,
                                        suffixIcon: const Icon(Icons.close),
                                        showSuffixIcon: true,
                                        showEnabledBorder: false,
                                        suffixIconOnPressed: () async {
                                          EasyLoading.show(
                                              status: "removing email..",
                                              maskType:
                                                  EasyLoadingMaskType.black);
                                          await viewModel.removeEmailAddress(
                                              viewModel.currentWallet!
                                                  .serverWalletID,
                                              userAccount.serverAccountID,
                                              addressID);
                                          EasyLoading.dismiss();
                                          setState(() {
                                            viewModel.reloadPage();
                                          });
                                        },
                                        controller: TextEditingController(
                                            text: viewModel
                                                .getProtonAddressByID(
                                                    addressID)!
                                                .email),
                                      )),
                              if (emailIntegrationEnables[userAccount.id!]!)
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      DropdownButtonV1(
                                        labelText:
                                            S.of(context).add_email_to_account,
                                        items: viewModel.protonAddresses,
                                        itemsText: viewModel.protonAddresses
                                            .map((e) => e.email)
                                            .toList(),
                                        valueNotifier:
                                            emailIntegrationNotifiers[
                                                userAccount.id!],
                                        width:
                                            MediaQuery.of(context).size.width -
                                                120,
                                      ),
                                      GestureDetector(
                                          onTap: () async {
                                            EasyLoading.show(
                                                status: "adding email..",
                                                maskType:
                                                    EasyLoadingMaskType.black);
                                            await viewModel
                                                .addEmailAddressToWalletAccount(
                                                    viewModel.currentWallet!
                                                        .serverWalletID,
                                                    userAccount.serverAccountID,
                                                    emailIntegrationNotifiers[
                                                            userAccount.id!]!
                                                        .value
                                                        .id);
                                            EasyLoading.dismiss();
                                            setState(() {
                                              viewModel.reloadPage();
                                            });
                                          },
                                          child: Padding(
                                              padding: const EdgeInsets.only(
                                                  right: defaultPadding),
                                              child: Container(
                                                width: 60,
                                                height: 40,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color:
                                                      ProtonColors.protonBlue,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0),
                                                ),
                                                child: Text(S.of(context).add,
                                                    style: FontManager
                                                        .body2Regular(
                                                            ProtonColors
                                                                .white)),
                                              ))),
                                    ]),
                              const Divider(
                                thickness: 0.2,
                                height: 1,
                              ),
                              Container(
                                  margin: const EdgeInsets.all(defaultPadding),
                                  padding: const EdgeInsets.all(10),
                                  child: GestureDetector(
                                    onTap: () async {
                                      if (userAccounts.length > 1) {
                                        EasyLoading.show(
                                            status: "deleting account..",
                                            maskType:
                                                EasyLoadingMaskType.black);
                                        await viewModel.deleteAccount(
                                            viewModel
                                                .currentWallet!.serverWalletID,
                                            userAccount.serverAccountID);
                                        EasyLoading.dismiss();
                                        setState(() {
                                          viewModel.reloadPage();
                                        });
                                      } else {
                                        LocalToast.showErrorToast(context,
                                            "Can not delete last account in wallet!");
                                      }
                                    },
                                    child: Text(S.of(context).delete_account,
                                        style: FontManager.body1Median(
                                            ProtonColors.signalError)),
                                  )),
                            ])),
                      const SizedBox(
                        height: defaultPadding,
                      ),
                      ExpansionTile(
                          shape: const Border(),
                          initiallyExpanded: false,
                          tilePadding: const EdgeInsets.all(0),
                          leading: SvgPicture.asset(
                              "assets/images/icon/ic-cog-wheel.svg",
                              fit: BoxFit.fill,
                              width: 20,
                              height: 20),
                          title: Text(S.of(context).advanced_options,
                              style: FontManager.body2Median(
                                  ProtonColors.textNorm)),
                          iconColor: ProtonColors.textHint,
                          collapsedIconColor: ProtonColors.textHint,
                          children: [
                            ButtonV5(
                              text: S.of(context).backup_wallet,
                              width: MediaQuery.of(context).size.width,
                              backgroundColor: ProtonColors.protonBlue,
                              textStyle:
                                  FontManager.body1Median(ProtonColors.white),
                              height: 48,
                              onPressed: () async {
                                Navigator.of(context).pop();
                                viewModel.move(ViewIdentifiers.setupBackup);
                              },
                            ),
                            const SizedBox(height: 10),
                            ButtonV5(
                              text: S.of(context).delete_wallet,
                              width: MediaQuery.of(context).size.width,
                              backgroundColor: ProtonColors.signalError,
                              textStyle:
                                  FontManager.body1Median(ProtonColors.white),
                              height: 48,
                              onPressed: () async {
                                Navigator.of(context).pop();
                                viewModel.move(ViewIdentifiers.walletDeletion);
                              },
                            )
                          ]),
                      const SizedBox(
                        height: defaultPadding,
                      ),
                    ],
                  )
                ],
              ),
            ));
          },
        );
      });
}

Widget buildSidebar(BuildContext context, HomeViewModel viewModel) {
  return SafeArea(
      child: SingleChildScrollView(
          child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        size: 22,
                        color: ProtonColors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
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
                            const AccountInfoV2(),
                            const SizedBox(
                              height: 10,
                            ),
                          ]),
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
                        onTap: () {},
                        leading: SvgPicture.asset(
                            "assets/images/icon/ic-diamondwallet_plus.svg",
                            fit: BoxFit.fill,
                            width: 20,
                            height: 20),
                        title: Text(S.of(context).wallet_plus,
                            style: FontManager.body2Median(
                                ProtonColors.drawerWalletPlus))),
                    ListTile(
                        onTap: () {
                          viewModel.move(ViewIdentifiers.discover);
                        },
                        leading: SvgPicture.asset(
                            "assets/images/icon/ic-squares-in-squarediscover.svg",
                            fit: BoxFit.fill,
                            width: 20,
                            height: 20),
                        title: Text(S.of(context).discover,
                            style: FontManager.body2Median(
                                ProtonColors.textHint))),
                    ListTile(
                        onTap: () {},
                        leading: SvgPicture.asset(
                            "assets/images/icon/ic-cog-wheel.svg",
                            fit: BoxFit.fill,
                            width: 20,
                            height: 20),
                        title: Text(S.of(context).settings_title,
                            style: FontManager.body2Median(
                                ProtonColors.textHint))),
                    ListTile(
                        onTap: () {},
                        leading: SvgPicture.asset(
                            "assets/images/icon/ic-lock2fa.svg",
                            fit: BoxFit.fill,
                            width: 20,
                            height: 20),
                        title: Text(S.of(context).two_factor_title,
                            style: FontManager.body2Median(
                                ProtonColors.textHint))),
                    ListTile(
                        onTap: () {},
                        leading: SvgPicture.asset(
                            "assets/images/icon/ic-bugreport.svg",
                            fit: BoxFit.fill,
                            width: 20,
                            height: 20),
                        title: Text(S.of(context).report_a_problem,
                            style: FontManager.body2Median(
                                ProtonColors.textHint))),
                    ListTile(
                        onTap: () async {
                          EasyLoading.show(
                              status: "log out..",
                              maskType: EasyLoadingMaskType.black);
                          await viewModel.logout();
                          EasyLoading.dismiss();
                        },
                        leading: SvgPicture.asset(
                            "assets/images/icon/ic-arrow-out-from-rectanglesignout.svg",
                            fit: BoxFit.fill,
                            width: 20,
                            height: 20),
                        title: Text(S.of(context).logout,
                            style: FontManager.body2Median(
                                ProtonColors.textHint))),
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
                                  viewModel.move(ViewIdentifiers.setupOnboard);
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
          await SecureStorageHelper.set(
              walletModel.serverWalletID, textEditingController.text);
          await Future.delayed(const Duration(seconds: 1));
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
      for (WalletModel walletModel in viewModel.userWallets)
        ExpansionTile(
          onExpansionChanged: (bool isExpanded) {
            List<AccountModel>? accounts =
                viewModel.walletID2Accounts[walletModel.id];
            if (accounts != null && accounts.isNotEmpty) {
              viewModel.selectAccount(accounts.first);
            }
          },
          shape: const Border(),
          initiallyExpanded: false,
          leading: CircleAvatar(
            backgroundColor: AvatarColorHelper.getBackgroundColor(
                viewModel.userWallets.indexOf(walletModel)),
            radius: 20,
            child: Text(
              CommonHelper.getFirstNChar(walletModel.name, 1),
              style: FontManager.body2Median(AvatarColorHelper.getTextColor(
                  viewModel.userWallets.indexOf(walletModel))),
            ),
          ),
          title:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(CommonHelper.getFirstNChar(walletModel.name, 12),
                    style: FontManager.body2Median(
                        AvatarColorHelper.getTextColor(
                            viewModel.userWallets.indexOf(walletModel)))),
                Text("${walletModel.accountCount} accounts",
                    style: FontManager.captionRegular(ProtonColors.textHint))
              ],
            ),
            getWalletBalanceWidget(context, viewModel, walletModel)
          ]),
          iconColor: ProtonColors.textHint,
          collapsedIconColor: ProtonColors.textHint,
          children: [
            for (AccountModel accountModel
                in viewModel.walletID2Accounts[walletModel.id] ?? [])
              ListTile(
                onTap: () {
                  viewModel.selectAccount(accountModel);
                },
                leading: Container(
                    margin: const EdgeInsets.only(left: 20),
                    child: CircleAvatar(
                      backgroundColor: AvatarColorHelper.getBackgroundColor(
                          viewModel.userWallets.indexOf(walletModel)),
                      radius: 16,
                      child: Text(
                        CommonHelper.getFirstNChar(accountModel.labelDecrypt, 1)
                            .toUpperCase(),
                        style: FontManager.captionSemiBold(ProtonColors.white),
                      ),
                    )),
                title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              CommonHelper.getFirstNChar(
                                  accountModel.labelDecrypt, 12),
                              style: FontManager.captionSemiBold(
                                  ProtonColors.white)),
                        ],
                      ),
                      getWalletAccountBalanceWidget(
                          context,
                          viewModel,
                          accountModel,
                          AvatarColorHelper.getTextColor(
                              viewModel.userWallets.indexOf(walletModel))),
                    ]),
              ),
            ListTile(
              onTap: () {
                showAddWalletAccountGuide(context, viewModel, walletModel);
              },
              leading: Container(
                  margin: const EdgeInsets.only(left: 20),
                  child: CircleAvatar(
                    backgroundColor: ProtonColors.drawerWalletBackground1,
                    radius: 16,
                    child: Icon(
                      Icons.add,
                      color: ProtonColors.textHint,
                      size: 16,
                    ),
                  )),
              title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(S.of(context).add_account,
                            style: FontManager.captionRegular(
                                ProtonColors.textHint)),
                      ],
                    )
                  ]),
            ),
          ],
        )
  ]);
}

Widget getWalletBalanceWidget(
    BuildContext context, HomeViewModel viewModel, WalletModel walletModel) {
  double esitmateValue = CommonHelper.getEstimateValue(
      amount: walletModel.balance / 100000000,
      isBitcoinBase: true,
      currencyExchangeRate: Provider.of<UserSettingProvider>(context)
          .walletUserSetting
          .exchangeRate
          .exchangeRate);
  return Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
    Text(
        viewModel.customFiatCurrency
            ? "${Provider.of<UserSettingProvider>(context).getFiatCurrencySign()}${esitmateValue.toStringAsFixed(defaultDisplayDigits)}"
            : Provider.of<UserSettingProvider>(context)
                .getBitcoinUnitLabel(walletModel.balance.toInt()),
        style: FontManager.captionSemiBold(AvatarColorHelper.getTextColor(
            viewModel.userWallets.indexOf(walletModel)))),
    Text(
        viewModel.customFiatCurrency
            ? Provider.of<UserSettingProvider>(context)
                .getBitcoinUnitLabel(walletModel.balance.toInt())
            : "${Provider.of<UserSettingProvider>(context).getFiatCurrencySign()}${esitmateValue.toStringAsFixed(defaultDisplayDigits)}",
        style: FontManager.overlineRegular(ProtonColors.textHint))
  ]);
}

Widget getWalletAccountBalanceWidget(BuildContext context,
    HomeViewModel viewModel, AccountModel accountModel, Color textColor) {
  double esitmateValue = CommonHelper.getEstimateValue(
      amount: accountModel.balance / 100000000,
      isBitcoinBase: true,
      currencyExchangeRate: Provider.of<UserSettingProvider>(context)
          .walletUserSetting
          .exchangeRate
          .exchangeRate);
  return Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
    Text(
        viewModel.customFiatCurrency
            ? "${Provider.of<UserSettingProvider>(context).getFiatCurrencySign()}${esitmateValue.toStringAsFixed(defaultDisplayDigits)}"
            : Provider.of<UserSettingProvider>(context)
                .getBitcoinUnitLabel(accountModel.balance.toInt()),
        style: FontManager.captionSemiBold(textColor)),
    Text(
        viewModel.customFiatCurrency
            ? Provider.of<UserSettingProvider>(context)
                .getBitcoinUnitLabel(accountModel.balance.toInt())
            : "${Provider.of<UserSettingProvider>(context).getFiatCurrencySign()}${esitmateValue.toStringAsFixed(defaultDisplayDigits)}",
        style: FontManager.overlineRegular(ProtonColors.textHint))
  ]);
}
