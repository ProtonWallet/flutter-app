import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:wallet/components/add_account_dialog.dart';
import 'package:wallet/components/button.icon.with.text.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/components/custom.newsbox.dart';
import 'package:wallet/components/custom.symbol.box.dart';
import 'package:wallet/components/custom.todo.dart';
import 'package:wallet/components/dropdown.button.v1.dart';
import 'package:wallet/components/text.choices.dart';
import 'package:wallet/components/textfield.text.dart';
import 'package:wallet/components/transaction.fee.box.dart';
import 'package:wallet/components/transaction/transaction.listtitle.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/currency_helper.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/fiat.currency.helper.dart';
import 'package:wallet/helper/local_toast.dart';
import 'package:wallet/helper/secure_storage_helper.dart';
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
      backgroundColor: ProtonColors.backgroundProton,
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
          statusBarBrightness: Brightness.light, // For iOS (dark icons)
        ),
        backgroundColor: ProtonColors.backgroundProton,
        title: Text(
          viewModel.currentWallet != null
              ? viewModel.currentWallet!.name
                  .substring(0, min(viewModel.currentWallet!.name.length, 10))
              : S.of(context).proton_wallet,
          style: FontManager.titleHeadline(ProtonColors.textNorm),
        ),
        actions: [
          Container(
              margin: const EdgeInsets.only(right: defaultPadding),
              child: CircleAvatar(
                backgroundColor: ProtonColors.primaryColor,
                radius: 14,
                child: Text(
                  "He",
                  style: TextStyle(
                      fontSize: 12, color: ProtonColors.backgroundSecondary),
                ),
              ))
        ],
        centerTitle: true,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(
                Icons.menu,
                size: 26,
              ),
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
          backgroundColor: ProtonColors.backgroundProton,
          width: min(MediaQuery.of(context).size.width, drawerMaxWidth),
          child: viewModel.walletDrawerStatus ==
                  WalletDrawerStatus.openWalletPreference
              ? buildWalletPreference(context, viewModel)
              : buildSidebar(context, viewModel)),
      onDrawerChanged: (isOpen) {
        if (isOpen == false) {
          viewModel.saveUserSettings();
        } else {
          viewModel.updateDrawerStatus(WalletDrawerStatus.openSetting);
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
                  viewModel.move(ViewIdentifiers.setupBackup);
                }
              }),
          CustomTodos(
            title: "Setup Email Integration",
            content: "Send Bitcoin via email address",
            checked: viewModel.hadSetupEmailIntegration,
            callback: () {
              showEmailIntegrationSettingGuide(context, viewModel);
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
                color: ProtonColors.surfaceLight,
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
                              .map((v) => v.labelDecrypt)
                              .toList(),
                          textStyle: FontManager.captionSemiBold(
                              ProtonColors.textNorm),
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
                                  child: CircularProgressIndicator(
                                    color: ProtonColors.textNorm,
                                  ))
                              : GestureDetector(
                                  onTap: () {
                                    viewModel.syncWallet();
                                  },
                                  child: Container(
                                      margin: const EdgeInsets.only(left: 8),
                                      width: 26,
                                      height: 26,
                                      child: CircularProgressIndicator(
                                        color: ProtonColors.textNorm,
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
                    style: FontManager.titleSubHeadline(ProtonColors.textNorm)),
                const SizedBox(
                  height: 4,
                ),
                Text(
                    "${viewModel.exchangeRate * viewModel.balance / 100 / 100000000}  ${viewModel.fiatCurrencyNotifier.value.name.toUpperCase()}",
                    style: FontManager.captionRegular(ProtonColors.textWeak)),
                const SizedBox(
                  height: 24,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ButtonIconWithText(
                      text: S.of(context).send_button,
                      icon: Icon(
                        Icons.arrow_upward,
                        color: ProtonColors.backgroundSecondary,
                        size: 24,
                      ),
                      callback: () {
                        if (viewModel.currentWallet == null) {
                          LocalToast.showToast(
                              context, "Please select your wallet first",
                              icon: null);
                        } else {
                          viewModel.move(ViewIdentifiers.send);
                        }
                      },
                    ),
                    ButtonIconWithText(
                      text: S.of(context).receive_button,
                      icon: Icon(
                        Icons.arrow_downward,
                        color: ProtonColors.backgroundSecondary,
                        size: 24,
                      ),
                      callback: () {
                        if (viewModel.currentWallet == null) {
                          LocalToast.showToast(
                              context, "Please select your wallet first",
                              icon: null);
                        } else {
                          viewModel.move(ViewIdentifiers.receive);
                        }
                      },
                    ),
                    ButtonIconWithText(
                      text: "Buy",
                      icon: Icon(
                        Icons.monetization_on,
                        color: ProtonColors.backgroundSecondary,
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
          ButtonV5(
              onPressed: () async {
                List<String> contents = [];
                contents.add(
                    "userId: '${await SecureStorageHelper.get("userId")}',\n");
                contents.add(
                    "userKeyID: '${await SecureStorageHelper.get("userKeyID")}',\n");
                contents.add(
                    "userPrivateKey: '''${await SecureStorageHelper.get("userPrivateKey")}''',\n");
                contents.add(
                    "userPassphrase: '${await SecureStorageHelper.get("userPassphrase")}',\n");
                contents.add(
                    "userDisplayName: '${await SecureStorageHelper.get("userDisplayName")}',\n");
                if (context.mounted) {
                  showMyAlertDialog(context, contents.join(""));
                }
              },
              text: "Secure Storage",
              width: MediaQuery.of(context).size.width - 52,
              backgroundColor: ProtonColors.surfaceLight,
              borderColor: const Color.fromARGB(255, 226, 226, 226),
              textStyle: FontManager.body1Median(ProtonColors.textNorm),
              height: 48),
          const SizedBox(
            height: 20,
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Text("History Transactions",
                  style: FontManager.body1Median(ProtonColors.textNorm))),
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
                  viewModel.move(ViewIdentifiers.historyDetails);
                },
              )
          ]),
          const SizedBox(
            height: 20,
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Text("Transaction Fees",
                  style: FontManager.body1Median(ProtonColors.textNorm))),
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
                  style: FontManager.body1Median(ProtonColors.textNorm))),
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
                      textStyle:
                          FontManager.captionSemiBold(ProtonColors.textNorm),
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
                          textStyle: FontManager.body1Median(
                              ProtonColors.backgroundSecondary),
                          height: 48)),
                ]));
      });
}

void showEmailIntegrationSettingGuide(
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
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          // need to use StatefulBuilder other-wise the state cannot update since showModalBottomSheet() will open new page
          return SingleChildScrollView(
              child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset("assets/images/icon/wallet.svg",
                            fit: BoxFit.fill, width: 32, height: 32),
                        const SizedBox(height: 6),
                        Text(S.of(context).setting_email_integration_label,
                            style:
                                FontManager.body1Bold(ProtonColors.textNorm)),
                        const SizedBox(height: 12),
                        ToggleSwitch(
                          minWidth: 60.0,
                          cornerRadius: 20.0,
                          activeBgColors: [
                            [ProtonColors.signalError],
                            [ProtonColors.signalSuccess],
                          ],
                          activeFgColor: ProtonColors.backgroundSecondary,
                          inactiveBgColor: ProtonColors.textWeak,
                          inactiveFgColor: ProtonColors.backgroundSecondary,
                          initialLabelIndex:
                              viewModel.emailIntegrationEnable ? 1 : 0,
                          totalSwitches: 2,
                          labels: [S.of(context).no, S.of(context).yes],
                          radiusStyle: true,
                          onToggle: (index) {
                            setState(() {
                              viewModel.emailIntegrationEnable = index == 1;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        if (viewModel.emailIntegrationEnable)
                          for (String addressID in viewModel.integratedEmailIDs)
                            Container(
                                margin: const EdgeInsets.only(bottom: 5),
                                child: TextFieldText(
                                  width: MediaQuery.of(context).size.width - 60,
                                  height: 50,
                                  color: ProtonColors.backgroundSecondary,
                                  suffixIcon: const Icon(Icons.close),
                                  showSuffixIcon: true,
                                  showEnabledBorder: false,
                                  suffixIconOnPressed: () async {
                                    EasyLoading.show(
                                        status: "removing email..",
                                        maskType: EasyLoadingMaskType.black);
                                    await viewModel
                                        .removeEmailAddress(addressID);
                                    EasyLoading.dismiss();
                                    if (context.mounted) {
                                      Navigator.of(context)
                                          .pop(); // pop current dialog
                                    }
                                  },
                                  controller: TextEditingController(
                                      text: viewModel
                                          .getProtonAddressByID(addressID)!
                                          .email),
                                )),
                        if (viewModel.emailIntegrationEnable)
                          DropdownButtonV1(
                            items: viewModel.protonAddresses,
                            itemsText: viewModel.protonAddresses
                                .map((e) => e.email)
                                .toList(),
                            valueNotifier: viewModel.emailIntegrationNotifier,
                            width: MediaQuery.of(context).size.width - 60,
                          ),
                        Container(
                            padding: const EdgeInsets.only(top: 20),
                            margin: const EdgeInsets.symmetric(
                                horizontal: defaultButtonPadding),
                            child: Column(children: [
                              ButtonV5(
                                  onPressed: () async {
                                    EasyLoading.show(
                                        status: "adding email..",
                                        maskType: EasyLoadingMaskType.black);
                                    await viewModel.updateEmailIntegration();
                                    EasyLoading.dismiss();
                                    if (context.mounted) {
                                      Navigator.of(context)
                                          .pop(); // pop current dialog
                                    }
                                  },
                                  backgroundColor: ProtonColors.backgroundBlack,
                                  text: S.of(context).save,
                                  width: MediaQuery.of(context).size.width,
                                  textStyle: FontManager.body1Median(
                                      ProtonColors.backgroundSecondary),
                                  height: 48),
                            ])),
                      ])));
        });
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
                      style: FontManager.body2Regular(ProtonColors.textNorm)),
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
                  leading: const Icon(Icons.add, size: 18),
                  title: Text(S.of(context).create_account,
                      style: FontManager.body2Regular(ProtonColors.textNorm)),
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
                      style: FontManager.body2Regular(ProtonColors.textNorm)),
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
                      style: FontManager.body2Regular(ProtonColors.textNorm)),
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

Widget buildWalletPreference(BuildContext context, HomeViewModel viewModel) {
  return SingleChildScrollView(
      child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
                alignment: Alignment.centerLeft,
                child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.transparent,
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        size: 26,
                        color: ProtonColors.textNorm,
                      ),
                      onPressed: () {
                        viewModel
                            .updateDrawerStatus(WalletDrawerStatus.openSetting);
                      },
                    ))),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Column(children: [
                Text("Wallet Settings",
                    style: FontManager.body1Bold(ProtonColors.textNorm)),
                const SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    S.of(context).wallet_name,
                    style: FontManager.captionMedian(ProtonColors.textNorm),
                  ),
                ),
                const SizedBox(height: 5),
                TextFieldText(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  color: ProtonColors.backgroundSecondary,
                  suffixIcon: const Icon(Icons.close),
                  showSuffixIcon: false,
                  showEnabledBorder: false,
                  controller: viewModel.walletPreferenceTextEditingController,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    "Accounts",
                    style: FontManager.captionMedian(ProtonColors.textNorm),
                  ),
                ),
                const SizedBox(height: 5),
                DropdownButtonV1(
                  width: MediaQuery.of(context).size.width,
                  items: viewModel.userAccountsForPreference,
                  valueNotifier: viewModel.accountValueNotifierForPreference,
                  itemsText: viewModel.userAccountsForPreference
                      .map(((v) => v.labelDecrypt))
                      .toList(),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Email Integration",
                          style:
                              FontManager.captionMedian(ProtonColors.textNorm),
                        ),
                        ToggleSwitch(
                          minWidth: 60.0,
                          cornerRadius: 20.0,
                          activeBgColors: [
                            [ProtonColors.signalError],
                            [ProtonColors.signalSuccess],
                          ],
                          activeFgColor: ProtonColors.backgroundSecondary,
                          inactiveBgColor: ProtonColors.textWeak,
                          inactiveFgColor: ProtonColors.backgroundSecondary,
                          initialLabelIndex:
                              viewModel.emailIntegrationEnable ? 1 : 0,
                          totalSwitches: 2,
                          labels: [S.of(context).no, S.of(context).yes],
                          radiusStyle: true,
                          onToggle: (index) {
                            viewModel.emailIntegrationEnable = index == 1;
                            viewModel.reloadPage();
                          },
                        ),
                      ]),
                ),
                const SizedBox(height: 5),
                if (viewModel.emailIntegrationEnable)
                  DropdownButtonV1(
                    items: viewModel.protonAddresses,
                    itemsText:
                        viewModel.protonAddresses.map((e) => e.email).toList(),
                    valueNotifier: viewModel.emailIntegrationNotifier,
                    width: MediaQuery.of(context).size.width,
                  ),
                const SizedBox(height: 20),
                ButtonV5(
                  text: S.of(context).backup_wallet,
                  width: MediaQuery.of(context).size.width,
                  backgroundColor: ProtonColors.surfaceLight,
                  borderColor: ProtonColors.wMajor1,
                  textStyle: FontManager.body1Median(ProtonColors.textNorm),
                  height: 48,
                  onPressed: () {
                    viewModel.currentWallet = viewModel.walletForPreference;
                    viewModel.move(ViewIdentifiers.setupBackup);
                  },
                ),
                const SizedBox(height: 10),
                ButtonV5(
                  text: S.of(context).delete_wallet,
                  width: MediaQuery.of(context).size.width,
                  backgroundColor: ProtonColors.surfaceLight,
                  borderColor: ProtonColors.wMajor1,
                  textStyle: FontManager.body1Median(ProtonColors.textNorm),
                  height: 48,
                  onPressed: () {
                    viewModel.currentWallet = viewModel.walletForPreference;
                    viewModel.move(ViewIdentifiers.walletDeletion);
                  },
                ),
                const SizedBox(height: 20),
                ButtonV5(
                    onPressed: () async {
                      EasyLoading.show(
                          status: "loading..",
                          maskType: EasyLoadingMaskType.black);
                      await proton_api.updateWalletName(
                          walletId:
                              viewModel.walletForPreference!.serverWalletID,
                          newName: viewModel
                              .walletPreferenceTextEditingController.text);
                      viewModel.walletForPreference!.name =
                          viewModel.walletPreferenceTextEditingController.text;
                      await DBHelper.walletDao!
                          .update(viewModel.walletForPreference!);
                      await viewModel.checkAccounts();
                      EasyLoading.dismiss();
                    },
                    text: S.of(context).save.toUpperCase(),
                    width: MediaQuery.of(context).size.width,
                    textStyle: FontManager.body1Median(ProtonColors.white),
                    height: 48),
              ]),
            ),
          ])));
}

Widget buildSidebar(BuildContext context, HomeViewModel viewModel) {
  return SingleChildScrollView(
    child: SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Stack(children: [
              Container(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      size: 26,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )),
              const AccountInfo(),
            ]),
            sidebarWalletItems(context, viewModel),
            Container(
              padding: const EdgeInsets.all(defaultPadding),
              child: const CommonSettings(),
            ),
            Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
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
                        textStyle:
                            FontManager.captionSemiBold(ProtonColors.textNorm),
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
                      viewModel.move(ViewIdentifiers.twoFactorAuthSetup);
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
                    viewModel.logout();
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
    title: Text(
      S.of(context).your_wallets,
      style: FontManager.body2Median(ProtonColors.textNorm),
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
              leading: CircleAvatar(
                backgroundColor: ProtonColors.primaryColor,
                radius: 20,
                child: Text(
                  CommonHelper.getFirstNChar(walletModel.name, 2),
                  style:
                      FontManager.body2Median(ProtonColors.backgroundSecondary),
                ),
              ),
              title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(CommonHelper.getFirstNChar(walletModel.name, 12),
                            style:
                                FontManager.body2Median(ProtonColors.textNorm)),
                        Text("${walletModel.accountCount} accounts",
                            style: FontManager.captionRegular(
                                ProtonColors.textNorm))
                      ],
                    ),
                    getWalletBalanceWidget(context, viewModel, walletModel)
                  ]),
              trailing: GestureDetector(
                  onTap: () {
                    viewModel.openWalletPreference(walletModel.id!);
                  },
                  child: const Icon(Icons.more_vert_rounded))),
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
              viewModel.move(ViewIdentifiers.setupOnboard);
            },
          )),
    ],
  );
}

Widget getWalletBalanceWidget(
    BuildContext context, HomeViewModel viewModel, WalletModel walletModel) {
  double esitmateValue = CommonHelper.getEstimateValue(
      amount: walletModel.balance / 100000000,
      isBitcoinBase: true,
      currencyExchangeRate: viewModel.exchangeRate);
  return Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
    Text(
        "${esitmateValue.toStringAsFixed(3)} ${viewModel.fiatCurrencyNotifier.value.name.toUpperCase()}",
        style: FontManager.captionSemiBold(ProtonColors.textNorm)),
    Text("${walletModel.balance / 100000000} BTC",
        style: FontManager.overlineRegular(ProtonColors.textNorm))
  ]);
}
