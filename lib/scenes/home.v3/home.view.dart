import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wallet/components/add_account_dialog.dart';
import 'package:wallet/components/button.icon.with.text.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/components/custom.newsbox.dart';
import 'package:wallet/components/custom.symbol.box.dart';
import 'package:wallet/components/custom.todo.dart';
import 'package:wallet/components/dropdown.button.v1.dart';
import 'package:wallet/components/tag.text.dart';
import 'package:wallet/components/text.choices.dart';
import 'package:wallet/components/textfield.text.dart';
import 'package:wallet/components/transaction.fee.box.dart';
import 'package:wallet/components/transaction/transaction.listtitle.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/currency_helper.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/fiat.currency.helper.dart';
import 'package:wallet/helper/local_toast.dart';
import 'package:wallet/helper/secure_storage_helper.dart';
import 'package:wallet/helper/user.session.dart';
import 'package:wallet/helper/wallet_manager.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/home.v3/home.viewmodel.dart';
import 'package:wallet/scenes/settings/settings.account.view.dart';
import 'package:wallet/scenes/settings/settings.common.view.dart';
import 'package:wallet/theme/theme.font.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/rust/api/proton_api.dart' as proton_api;

class HomeView extends ViewBase<HomeViewModel> {
  HomeView(HomeViewModel viewModel) : super(viewModel, const Key("HomeView"));

  @override
  Widget buildWithViewModel(
      BuildContext context, HomeViewModel viewModel, ViewSize viewSize) {
    if (viewModel.hasWallet == false && viewModel.initialed) {
      viewModel.setOnBoard(context);
    }
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
          statusBarBrightness: Brightness.light, // For iOS (dark icons)
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text(
          viewModel.currentWallet != null
              ? viewModel.currentWallet!.name
                  .substring(0, min(viewModel.currentWallet!.name.length, 10))
              : S.of(context).proton_wallet,
          style:
              FontManager.titleHeadline(Theme.of(context).colorScheme.primary),
        ),
        actions: [
          Container(
              margin: const EdgeInsets.only(right: defaultPadding),
              child: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                radius: 14,
                child: Text(
                  Provider.of<UserSessionProvider>(context)
                      .userSession
                      .userDisplayName
                      .split(' ')
                      .map((str) => str.isEmpty ? '' : str.substring(0, 1))
                      .join(''),
                  style:
                      const TextStyle(fontSize: 12, color: ProtonColors.white),
                ),
              ))
        ],
        centerTitle: true,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(
                Icons.account_balance_wallet_outlined,
                size: 26,
              ), // 自定义的打开Drawer图标
              onPressed: () {
                Scaffold.of(context).openDrawer(); // 打开Drawer
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
        backgroundColor: ProtonColors.white,
        child: buildSidebar(context, viewModel),
      ),
      onDrawerChanged: (isOpen) {
        if (isOpen == false) {
          viewModel.saveUserSettings();
        }
      },
      body: Center(
        child: ListView(scrollDirection: Axis.vertical, children: [
          Center(
            child: Text(S.of(context).welcome_to,
                style: FontManager.body1Bold(ProtonColors.textNorm)),
          ),
          Center(
            child: Text(S.of(context).welcome_hint,
                style: FontManager.body1Regular(ProtonColors.textWeak)),
          ),
          const SizedBox(
            height: 4,
          ),
          CustomTodos(
              title: "Backup your Recovery Phrase",
              content: "Keep your account safe!",
              checked: viewModel.hadBackup,
              callback: () {
                if (viewModel.currentWallet == null) {
                  LocalToast.showToast(
                      context, "Please select your wallet first",
                      icon: null);
                } else {
                  viewModel.coordinator
                      .move(ViewIdentifiers.setupBackup, context);
                }
              }),
          CustomTodos(
            title: "Setup Email Integration",
            content: "Send Bitcoin via email address",
            checked: viewModel.hadSetupEmailIntegration,
            callback: () {
              LocalToast.showToast(context, "TODO", icon: null);
            },
          ),
          CustomTodos(
            title: "Set your preferred Fiat currency",
            content: "Customize your experience",
            checked: viewModel.hadSetFiatCurrency,
            callback: () {
              showFiatCurrencySettingGuide(context, viewModel);
            },
          ),
          Container(
            padding: const EdgeInsets.all(defaultPadding),
            margin: const EdgeInsets.all(defaultPadding),
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                  color: const Color.fromARGB(255, 226, 226, 226),
                  width: 1.0,
                )),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      DropdownButtonV1(
                          width: 160,
                          items: viewModel.userAccounts,
                          itemsText: viewModel.userAccounts
                              .map((v) => "${v.labelDecrypt}")
                              .toList(),
                          textStyle: FontManager.captionSemiBold(
                              Theme.of(context).colorScheme.primary),
                          valueNotifier: viewModel.accountNotifier),
                      if (viewModel.currentWallet != null)
                        if (viewModel.isSyncingMap.containsKey(
                            viewModel.currentWallet!.serverWalletID))
                          viewModel.isSyncingMap[
                                  viewModel.currentWallet!.serverWalletID]!
                              ? Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  width: 26,
                                  height: 26,
                                  child: const CircularProgressIndicator())
                              : GestureDetector(
                                  onTap: () {
                                    viewModel.syncWallet();
                                  },
                                  child: Container(
                                      margin: const EdgeInsets.only(left: 8),
                                      width: 26,
                                      height: 26,
                                      child: const CircularProgressIndicator(
                                        value: 1,
                                      )))
                    ]),
                    GestureDetector(
                      onTap: () {
                        showAccountMoreDialog(context, viewModel);
                      },
                      child: const Icon(
                        Icons.more_horiz,
                        size: 20,
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 4,
                ),
                Text("${viewModel.balance / 100000000} BTC",
                    style: FontManager.titleSubHeadline(
                        Theme.of(context).colorScheme.primary)),
                const SizedBox(
                  height: 4,
                ),
                Text(
                    "\$ ${viewModel.exchangeRate * viewModel.balance / 100 / 100000000}",
                    style: FontManager.captionRegular(
                        Theme.of(context).colorScheme.secondary)),
                const SizedBox(
                  height: 24,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ButtonIconWithText(
                      text: S.of(context).send_button,
                      icon: const Icon(
                        Icons.arrow_upward,
                        color: Colors.white,
                        size: 24,
                      ),
                      callback: () {
                        if (viewModel.currentWallet == null) {
                          LocalToast.showToast(
                              context, "Please select your wallet first",
                              icon: null);
                        } else {
                          viewModel.coordinator
                              .move(ViewIdentifiers.send, context);
                        }
                      },
                    ),
                    ButtonIconWithText(
                      text: S.of(context).receive_button,
                      icon: const Icon(
                        Icons.arrow_downward,
                        color: Colors.white,
                        size: 24,
                      ),
                      callback: () {
                        if (viewModel.currentWallet == null) {
                          LocalToast.showToast(
                              context, "Please select your wallet first",
                              icon: null);
                        } else {
                          viewModel.coordinator
                              .move(ViewIdentifiers.receive, context);
                        }
                      },
                    ),
                    ButtonIconWithText(
                      text: "Buy",
                      icon: const Icon(
                        Icons.monetization_on,
                        color: Colors.white,
                        size: 24,
                      ),
                      callback: () {
                        LocalToast.showToast(context, "TODO", icon: null);
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
          CustomSymbolBox(
            title: "Bitcoin",
            content: "\$${viewModel.btcPriceInfo.price * viewModel.balance}",
            iconPath: "assets/images/icon/wallet.svg",
            width: MediaQuery.of(context).size.width - defaultPadding * 2,
            price: viewModel.btcPriceInfo.price,
            priceChange: viewModel.btcPriceInfo.priceChange24h,
            callback: () {
              LocalToast.showToast(context, "TODO", icon: null);
            },
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Text("History Transactions",
                  style: FontManager.body1Median(
                      Theme.of(context).colorScheme.primary))),
          Column(children: [
            for (int index = 0; index < viewModel.history.length; index++)
              TransactionListTitle(
                width: MediaQuery.of(context).size.width - defaultPadding * 2,
                address:
                    "${viewModel.history[index].txid.substring(0, 10)}***${viewModel.history[index].txid.substring(64 - 6)}",
                coin: "Sat",
                amount: (viewModel.getAmount(index)).toDouble(),
                notional: CurrencyHelper.sat2usdt(
                    (viewModel.getAmount(index)).abs().toDouble()),
                isSend: viewModel.history[index].sent >
                    viewModel.history[index].received,
                note: viewModel.userLabels[index],
                timestamp: viewModel.history[index].confirmationTime!.timestamp,
                onTap: () {
                  viewModel.selectedTXID = viewModel.history[index].txid;
                  viewModel.coordinator
                      .move(ViewIdentifiers.historyDetails, context);
                },
              )
          ]),
          const SizedBox(
            height: 20,
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Text("Transaction Fees",
                  style: FontManager.body1Median(
                      Theme.of(context).colorScheme.primary))),
          const SizedBox(height: 10),
          Container(
              width: MediaQuery.of(context).size.width,
              height: 110,
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: ListView(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  children: [
                    TransactionFeeBox(
                      priorityText: "High Priority",
                      timeEstimate: "In ~10 minutes",
                      fee: viewModel.bitcoinTransactionFee.block1Fee,
                    ),
                    const SizedBox(width: 10),
                    TransactionFeeBox(
                      priorityText: "Median Priority",
                      timeEstimate: "In ~30 minutes",
                      fee: viewModel.bitcoinTransactionFee.block3Fee,
                    ),
                    const SizedBox(width: 10),
                    TransactionFeeBox(
                      priorityText: "Low Priority",
                      timeEstimate: "In ~50 minutes",
                      fee: viewModel.bitcoinTransactionFee.block5Fee,
                    ),
                    const SizedBox(width: 10),
                    TransactionFeeBox(
                      priorityText: "No Priority",
                      timeEstimate: "In ~3.5 hours",
                      fee: viewModel.bitcoinTransactionFee.block20Fee,
                    ),
                  ])),
          const SizedBox(
            height: 20,
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Text(S.of(context).explore_wallet,
                  style: FontManager.body1Median(
                      Theme.of(context).colorScheme.primary))),
          const SizedBox(height: 10),
          CustomNewsBox(
              title: S.of(context).security_n_proton_wallet,
              content: S.of(context).how_to_stay_safe_and_protect_your_assets,
              iconPath: "assets/images/icon/protect.svg",
              width: MediaQuery.of(context).size.width - defaultPadding * 2),
          const SizedBox(height: 10),
          CustomNewsBox(
              title: S.of(context).wallets_n_accounts,
              content: S.of(context).whats_the_different_and_how_to_use_them,
              iconPath: "assets/images/icon/wallet.svg",
              width: MediaQuery.of(context).size.width - defaultPadding * 2),
          const SizedBox(height: 10),
          CustomNewsBox(
              title: S.of(context).transfer_bitcoin,
              content:
                  S.of(context).how_to_send_and_receive_bitcoin_with_proton,
              iconPath: "assets/images/icon/transfer.svg",
              width: MediaQuery.of(context).size.width - defaultPadding * 2),
          const SizedBox(height: 10),
          CustomNewsBox(
              title: S.of(context).mobile_apps,
              content: S.of(context).start_using_proton_wallet_on_your_phone,
              iconPath: "assets/images/icon/mobile.svg",
              width: MediaQuery.of(context).size.width - defaultPadding * 2),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }
}

void showFiatCurrencySettingGuide(
    BuildContext context, HomeViewModel viewModel) {
  showModalBottomSheet(
      context: context,
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset("assets/images/icon/wallet.svg",
                      fit: BoxFit.fill, width: 32, height: 32),
                  const SizedBox(height: 6),
                  Text(S.of(context).setting_fiat_currency_label,
                      style: FontManager.body1Bold(ProtonColors.textNorm)),
                  const SizedBox(height: 12),
                  DropdownButtonV1(
                      width: 200,
                      items: viewModel.fiatCurrencies,
                      itemsText: viewModel.fiatCurrencies
                          .map((v) => FiatCurrencyHelper.getText(v))
                          .toList(),
                      textStyle: FontManager.captionSemiBold(
                          Theme.of(context).colorScheme.primary),
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
                          backgroundColor: ProtonColors.backgroundBlack,
                          text: S.of(context).save,
                          width: MediaQuery.of(context).size.width,
                          textStyle:
                              FontManager.body1Median(ProtonColors.white),
                          height: 48)),
                ]));
      });
}

void showAccountMoreDialog(BuildContext context, HomeViewModel viewModel) {
  if (viewModel.currentWallet == null) {
    LocalToast.showToast(context, "Please select your wallet first",
        icon: null);
    return;
  }
  showModalBottomSheet(
    context: context,
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
                  leading: const Icon(Icons.key, size: 18),
                  title: Text(S.of(context).set_passphrase,
                      style: FontManager.body2Regular(
                          Theme.of(context).colorScheme.primary)),
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return showUpdateWalletPassphraseDialog(
                              context, viewModel, viewModel.currentWallet!);
                        });
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.edit, size: 18),
                  title: Text(S.of(context).rename_wallet,
                      style: FontManager.body2Regular(
                          Theme.of(context).colorScheme.primary)),
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return showUpdateWalletNameDialog(
                              context, viewModel, viewModel.currentWallet!);
                        });
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.download_for_offline, size: 18),
                  title: Text(S.of(context).backup_wallet,
                      style: FontManager.body2Regular(
                          Theme.of(context).colorScheme.primary)),
                  onTap: () {
                    viewModel.coordinator
                        .move(ViewIdentifiers.setupBackup, context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, size: 18),
                  title: Text(S.of(context).delete_wallet,
                      style: FontManager.body2Regular(
                          Theme.of(context).colorScheme.primary)),
                  onTap: () async {
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                    viewModel.coordinator
                        .move(ViewIdentifiers.walletDeletion, context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.add, size: 18),
                  title: Text(S.of(context).create_account,
                      style: FontManager.body2Regular(
                          Theme.of(context).colorScheme.primary)),
                  onTap: () {
                    AddAccountAlertDialog.show(
                        context,
                        viewModel.currentWallet!.id!,
                        viewModel.currentWallet!.serverWalletID, callback: () {
                      viewModel.loadData();
                    });
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.edit, size: 18),
                  title: Text(S.of(context).rename_account,
                      style: FontManager.body2Regular(
                          Theme.of(context).colorScheme.primary)),
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return showRenameAccountDialog(context, viewModel);
                        });
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, size: 18),
                  title: Text(S.of(context).delete_account,
                      style: FontManager.body2Regular(
                          Theme.of(context).colorScheme.primary)),
                  onTap: () async {
                    if (viewModel.userAccounts.length > 1) {
                      EasyLoading.show(
                          status: "loading..",
                          maskType: EasyLoadingMaskType.black);
                      await viewModel.deleteAccount();
                      EasyLoading.dismiss();
                      if (context.mounted) {
                        Navigator.of(context).pop(); // pop current dialog
                      }
                    } else {
                      LocalToast.showErrorToast(
                          context, "Can not delete last account in wallet!");
                    }
                  },
                )
              ],
            )
          ],
        ),
      );
    },
  );
}

Widget showRenameAccountDialog(BuildContext context, HomeViewModel viewModel) {
  TextEditingController textEditingController = TextEditingController();
  textEditingController.text = viewModel.currentAccount!.labelDecrypt;
  return AlertDialog(
    content: TextField(
      decoration: InputDecoration(
        hintText: S.of(context).your_new_label_here,
      ),
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
          Navigator.of(context).pop();
          await viewModel.renameAccount(textEditingController.text);
        },
        child: Text(S.of(context).submit),
      ),
    ],
  );
}

Widget buildSidebar(BuildContext context, HomeViewModel viewModel) {
  return SingleChildScrollView(
    child: SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const AccountInfo(),
            sidebarWalletItems(context, viewModel),
            const CommonSettings(),
            Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                margin: const EdgeInsets.only(top: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(S.of(context).setting_bitcoin_unit_label,
                        style: FontManager.body1Regular(ProtonColors.textNorm)),
                    TextChoices(
                        choices: [
                          CommonBitcoinUnit.sats.name.toUpperCase(),
                          CommonBitcoinUnit.mbtc.name.toUpperCase(),
                          CommonBitcoinUnit.btc.name.toUpperCase(),
                        ],
                        selectedValue: viewModel.bitcoinUnitController.text,
                        controller: viewModel.bitcoinUnitController),
                  ],
                )),
            Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                margin: const EdgeInsets.only(top: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(S.of(context).setting_fiat_currency_label,
                        style: FontManager.body1Regular(ProtonColors.textNorm)),
                    DropdownButtonV1(
                        width: 200,
                        items: viewModel.fiatCurrencies,
                        itemsText: viewModel.fiatCurrencies
                            .map((v) => FiatCurrencyHelper.getText(v))
                            .toList(),
                        textStyle: FontManager.captionSemiBold(
                            Theme.of(context).colorScheme.primary),
                        valueNotifier: viewModel.fiatCurrencyNotifier),
                  ],
                )),
            Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                margin: const EdgeInsets.only(top: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(S.of(context).setting_hide_empty_used_address_label,
                        style: FontManager.body1Regular(ProtonColors.textNorm)),
                    TextChoices(
                        choices: [
                          S.of(context).setting_option_off,
                          S.of(context).setting_option_on
                        ],
                        selectedValue: viewModel.hideEmptyUsedAddresses
                            ? S.of(context).setting_option_on
                            : S.of(context).setting_option_off,
                        controller: viewModel.hideEmptyUsedAddressesController),
                  ],
                )),
            Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                margin: const EdgeInsets.only(top: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(S.of(context).setting_2fa_amount_threshold_label,
                        style: FontManager.body1Regular(ProtonColors.textNorm)),
                    TextFieldText(
                      width: 200,
                      height: 50,
                      color: ProtonColors.backgroundSecondary,
                      showSuffixIcon: false,
                      showEnabledBorder: false,
                      controller: viewModel.twoFactorAmountThresholdController,
                      digitOnly: true,
                    ),
                  ],
                )),
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 26.0),
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: ButtonV5(
                    onPressed: () {
                      launchUrl(Uri.parse(
                          "https://proton.me/support/two-factor-authentication-2fa"));
                    },
                    text: S.of(context).setting_2fa_setup,
                    width: MediaQuery.of(context).size.width,
                    backgroundColor: ProtonColors.surfaceLight,
                    borderColor: ProtonColors.wMajor1,
                    textStyle: FontManager.body1Median(ProtonColors.textNorm),
                    height: 48)),
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 26.0),
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: ButtonV5(
                    onPressed: () async {
                      EasyLoading.show(
                          status: "reloading..",
                          maskType: EasyLoadingMaskType.black);
                      await DBHelper.reset();
                      await WalletManager.fetchWalletsFromServer();
                      EasyLoading.dismiss();
                    },
                    text: "Reset Local Data and Reload",
                    width: MediaQuery.of(context).size.width,
                    backgroundColor: ProtonColors.surfaceLight,
                    borderColor: ProtonColors.wMajor1,
                    textStyle: FontManager.body1Median(ProtonColors.textNorm),
                    height: 48)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 26.0),
              margin: const EdgeInsets.symmetric(vertical: 30),
              child: ButtonV5(
                  onPressed: () {
                    viewModel.coordinator
                        .move(ViewIdentifiers.welcome, context);
                  },
                  text: S.of(context).logout.toUpperCase(),
                  width: MediaQuery.of(context).size.width,
                  textStyle: FontManager.body1Median(ProtonColors.white),
                  height: 48),
            ),
          ]),
    ),
  );
}

Widget showUpdateWalletNameDialog(
    BuildContext context, HomeViewModel viewModel, WalletModel walletModel) {
  TextEditingController textEditingController = TextEditingController();
  textEditingController.text = walletModel.name;
  return AlertDialog(
    title: Text(S.of(context).update_wallet_name),
    content: TextField(
      decoration: InputDecoration(
        hintText: S.of(context).your_new_wallet_name_here,
      ),
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
              status: "loading..", maskType: EasyLoadingMaskType.black);
          await proton_api.updateWalletName(
              walletId: walletModel.serverWalletID,
              newName: textEditingController.text);
          walletModel.name = textEditingController.text;
          await DBHelper.walletDao!.update(walletModel);
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
  return ExpansionTile(
    initiallyExpanded: true,
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(S.of(context).your_wallets),
        Text(viewModel.currentWallet != null
            ? viewModel.currentWallet!.name
                .substring(0, min(viewModel.currentWallet!.name.length, 10))
            : ""),
      ],
    ),
    children: [
      if (viewModel.initialed)
        for (WalletModel walletModel in viewModel.userWallets)
          ListTile(
              onTap: () {
                if (walletModel.status == WalletModel.statusActive) {
                  viewModel.selectWallet(walletModel.id!);
                } else {
                  LocalToast.showErrorToast(
                      context, S.of(context).wallet_decryption_error_message);
                }
              },
              leading: walletModel.status == WalletModel.statusActive
                  ? TagText(
                      text: S.of(context).on_chain,
                      radius: 10.0,
                      background: const Color.fromARGB(255, 200, 248, 255),
                      textColor: const Color.fromARGB(255, 18, 134, 159))
                  : TagText(
                      text: S.of(context).inactivate_wallet,
                      radius: 10.0,
                      background: ProtonColors.signalError,
                      textColor: ProtonColors.white,
                    ),
              title: Container(
                transform: Matrix4.translationValues(0, 0.0, 0.0),
                child: Text(walletModel.name),
              ),
              trailing: viewModel.currentWallet == null
                  ? null
                  : walletModel.id == viewModel.currentWallet!.id
                      ? const Icon(Icons.done)
                      : null),
      Container(
          padding: const EdgeInsets.symmetric(horizontal: 26.0),
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: ButtonV5(
            text: S.of(context).add_wallet,
            width: MediaQuery.of(context).size.width,
            backgroundColor: ProtonColors.surfaceLight,
            borderColor: ProtonColors.wMajor1,
            textStyle: FontManager.body1Median(ProtonColors.textNorm),
            height: 48,
            onPressed: () {
              viewModel.coordinator.move(ViewIdentifiers.setupOnboard, context);
            },
          )),
    ],
  );
}
