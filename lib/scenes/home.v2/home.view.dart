import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:wallet/components/alert.warning.dart';
import 'package:wallet/components/custom.fullpage.loading.dart';
import 'package:wallet/components/custom.piechart.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/currency_helper.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/event_loop_helper.dart';
import 'package:wallet/helper/local_toast.dart';
import 'package:wallet/helper/secure_storage_helper.dart';
import 'package:wallet/helper/wallet_manager.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/home.v2/home.viewmodel.dart';
import 'package:wallet/scenes/setup/onboard.coordinator.dart';
import 'package:wallet/theme/theme.font.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/components/custom.newsbox.dart';
import 'package:wallet/components/tag.text.dart';
import 'package:wallet/helper/user.session.dart';
import 'package:wallet/rust/api/proton_api.dart' as proton_api;

class HomeView extends ViewBase<HomeViewModel> {
  HomeView(HomeViewModel viewModel) : super(viewModel, const Key("HomeView"));

  @override
  Widget buildWithViewModel(
      BuildContext context, HomeViewModel viewModel, ViewSize viewSize) {
    if (viewModel.hasWallet == false) {
      // viewModel.setOnBoard(context);
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
          S.of(context).proton_wallet,
          style: FontManager.titleHeadline(ProtonColors.textNorm),
        ),
        scrolledUnderElevation:
            0.0, // don't change background color when scroll down
      ),
      body: Center(
        child: ListView(scrollDirection: Axis.vertical, children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width - 52,
              height: 169,
              decoration: BoxDecoration(
                  color: ProtonColors.surfaceLight,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: const Color.fromARGB(255, 226, 226, 226),
                    width: 1.0,
                  )),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: SvgPicture.asset(
                      'assets/images/wallet_creation/bg.svg',
                      width: MediaQuery.of(context).size.width - 52,
                      fit: BoxFit.fill,
                    ),
                  ),
                  Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        Text(
                            "${S.of(context).welcome} ${Provider.of<UserSessionProvider>(context).userSession.userName} 👋",
                            style: FontManager.body1Bold(ProtonColors.white)),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(left: 50, right: 50),
                          child: Text(
                            S.of(context).start_using_your_proton_wallet_by_,
                            style:
                                FontManager.captionRegular(ProtonColors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ButtonV5(
                                onPressed: () {},
                                text: S.of(context).buy_bitcoin,
                                width: 140,
                                radius: 28,
                                backgroundColor: ProtonColors.surfaceLight,
                                borderColor:
                                    const Color.fromARGB(255, 226, 226, 226),
                                textStyle: FontManager.captionRegular(
                                    ProtonColors.textNorm),
                                height: 32),
                            const SizedBox(width: 10),
                            ButtonV5(
                                onPressed: () {},
                                text: S.of(context).transfer_bitcoin,
                                width: 140,
                                radius: 28,
                                backgroundColor: ProtonColors.surfaceLight,
                                borderColor:
                                    const Color.fromARGB(255, 226, 226, 226),
                                textStyle: FontManager.captionRegular(
                                    ProtonColors.textNorm),
                                height: 32),
                          ],
                        ),
                      ])),
                ],
              ),
            )
          ]),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            Container(
                width: MediaQuery.of(context).size.width / 2 - 36,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                    color: ProtonColors.surfaceLight,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: const Color.fromARGB(255, 226, 226, 226),
                      width: 1.0,
                    )),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(S.of(context).my_assets,
                        style:
                            FontManager.captionRegular(ProtonColors.textWeak)),
                    Text("${viewModel.totalBalance} Sat",
                        style: FontManager.titleSubHeadline(
                            ProtonColors.textNorm)),
                    Text(
                        "${CurrencyHelper.sat2usdt(viewModel.totalBalance).toStringAsFixed(2)} USD",
                        style:
                            FontManager.overlineRegular(ProtonColors.textWeak)),
                  ],
                )),
            const SizedBox(
              width: 20,
            ),
            Container(
                width: MediaQuery.of(context).size.width / 2 - 36,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                    color: ProtonColors.surfaceLight,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: const Color.fromARGB(255, 226, 226, 226),
                      width: 1.0,
                    )),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(S.of(context).last_7_days,
                        style:
                            FontManager.captionRegular(ProtonColors.textWeak)),
                    Text("+${viewModel.totalBalance} Sat",
                        style: FontManager.titleSubHeadline(
                            ProtonColors.signalSuccess)),
                    Text(
                        "${CurrencyHelper.sat2usdt(viewModel.totalBalance).toStringAsFixed(2)} USD",
                        style:
                            FontManager.overlineRegular(ProtonColors.textWeak)),
                  ],
                )),
          ]),
          const SizedBox(height: 20),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                    padding: const EdgeInsets.only(left: 26.0, right: 26.0),
                    child: Text(S.of(context).your_wallets,
                        style: FontManager.body1Median(ProtonColors.textNorm))),
                GestureDetector(
                    onTap: () {
                      viewModel.move(ViewIdentifiers.setupOnboard);
                    },
                    child: Padding(
                        padding: const EdgeInsets.only(left: 26.0, right: 26.0),
                        child: Text(S.of(context).add_wallet,
                            style: FontManager.body1Median(
                                ProtonColors.interactionNorm)))),
              ]),
          const SizedBox(height: 10),
          Center(
              child: Container(
                  height: 140,
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                  child: ListView(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      children: <Widget>[
                        for (WalletModel wallet in viewModel.userWallets)
                          GestureDetector(
                              onTap: () {
                                if (wallet.status ==
                                    WalletModel.statusDisabled) {
                                  LocalToast.showErrorToast(
                                      context,
                                      S
                                          .of(context)
                                          .wallet_decryption_error_message);
                                } else {
                                  viewModel.setSelectedWallet(wallet.id ?? 0);
                                  viewModel.move(ViewIdentifiers.wallet);
                                }
                              },
                              child: Container(
                                  width: 200.0,
                                  height: 140.0,
                                  padding: const EdgeInsets.all(10.0),
                                  margin: const EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                      color: ProtonColors.surfaceLight,
                                      borderRadius: BorderRadius.circular(10.0),
                                      border: Border.all(
                                        color: const Color.fromARGB(
                                            255, 226, 226, 226),
                                        width: 1.0,
                                      )),
                                  child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 5, right: 0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    TagText(
                                                      text: S
                                                          .of(context)
                                                          .on_chain,
                                                      radius: 10.0,
                                                      background:
                                                          const Color.fromARGB(
                                                              255,
                                                              200,
                                                              248,
                                                              255),
                                                      textColor:
                                                          const Color.fromARGB(
                                                              255,
                                                              18,
                                                              134,
                                                              159),
                                                    ),
                                                    const SizedBox(width: 2),
                                                    if (wallet.status ==
                                                        WalletModel
                                                            .statusDisabled)
                                                      const Icon(Icons.error,
                                                          color: Colors.red),
                                                  ],
                                                ),
                                                GestureDetector(
                                                    onTap: () {
                                                      showWalletMoreDialog(
                                                          viewModel,
                                                          wallet,
                                                          context,
                                                          expired: wallet
                                                                  .status ==
                                                              WalletModel
                                                                  .statusDisabled);
                                                    },
                                                    child: const Icon(
                                                        Icons.more_vert_sharp))
                                              ]),
                                          const SizedBox(
                                            height: 4,
                                          ),
                                          Text(wallet.name,
                                              style: FontManager.captionRegular(
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .secondary)),
                                          Text("${wallet.balance} Sat",
                                              style:
                                                  FontManager.titleSubHeadline(
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .primary)),
                                          Text(
                                              "${wallet.accountCount} accounts",
                                              style: FontManager.captionRegular(
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .secondary)),
                                        ],
                                      ))))
                      ]))),
          if (!viewModel.hasMailIntegration)
            Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.symmetric(vertical: 20),
                color: ProtonColors.accentSlateblue,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.only(
                      left: 24, top: 12, right: 24, bottom: 12),
                  decoration: BoxDecoration(
                      color: ProtonColors.mailIntegrationBox,
                      borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset("assets/images/mail_integration.svg",
                          width: 54),
                      Text(
                        S.of(context).you_can_send_and_receive_bitcoin_w_emial_,
                        style:
                            FontManager.captionRegular(ProtonColors.textNorm),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                              onTap: () {
                                // viewModel.mailIntegration();
                                viewModel.move(ViewIdentifiers.mailList);
                              },
                              child: Container(
                                constraints: const BoxConstraints(
                                  minWidth: 100.0,
                                ),
                                child: Text(
                                  S.of(context).set_up_address,
                                  style: FontManager.captionSemiBold(
                                      ProtonColors.textNorm),
                                  textAlign: TextAlign.center,
                                ),
                              )),
                          GestureDetector(
                              onTap: () {
                                viewModel.updateHasMailIntegration(true);
                              },
                              child: Container(
                                constraints: const BoxConstraints(
                                  minWidth: 100.0,
                                ),
                                child: Text(
                                  S.of(context).later,
                                  style: FontManager.captionSemiBold(
                                      ProtonColors.textNorm),
                                  textAlign: TextAlign.center,
                                ),
                              )),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                )),
          if (viewModel.totalBalance > 0)
            Column(children: [
              Padding(
                  padding: const EdgeInsets.only(left: 26.0, right: 26.0),
                  child: Text(S.of(context).statistic,
                      style: FontManager.body1Median(ProtonColors.textNorm))),
              CustomPieChart(
                width: 400,
                height: 240,
                data: viewModel.userWallets
                    .where((walletModel) => walletModel.balance > 0)
                    .map((walletModel) => ChartData(
                        name: walletModel.name, value: walletModel.balance))
                    .toList(),
              ),
            ]),
          const SizedBox(
            height: 20,
          ),
          Padding(
              padding: const EdgeInsets.only(left: 26.0, right: 26.0),
              child: Text(S.of(context).quick_actions,
                  style: FontManager.body1Median(ProtonColors.textNorm))),
          const SizedBox(
            height: 10,
          ),
          ButtonV5(
              onPressed: () {
                viewModel.move(ViewIdentifiers.send);
              },
              text: S.of(context).send_button,
              width: MediaQuery.of(context).size.width - 52,
              backgroundColor: ProtonColors.surfaceLight,
              borderColor: const Color.fromARGB(255, 226, 226, 226),
              textStyle: FontManager.body1Median(ProtonColors.textNorm),
              height: 48),
          const SizedBox(
            height: 10,
          ),
          ButtonV5(
              onPressed: () {
                viewModel.move(ViewIdentifiers.receive);
              },
              text: S.of(context).receive_button,
              width: MediaQuery.of(context).size.width - 52,
              backgroundColor: ProtonColors.surfaceLight,
              borderColor: const Color.fromARGB(255, 226, 226, 226),
              textStyle: FontManager.body1Median(ProtonColors.textNorm),
              height: 48),
          const SizedBox(
            height: 10,
          ),
          ButtonV5(
              onPressed: () {},
              text: S.of(context).swap_button,
              width: MediaQuery.of(context).size.width - 52,
              backgroundColor: ProtonColors.surfaceLight,
              borderColor: const Color.fromARGB(255, 226, 226, 226),
              textStyle: FontManager.body1Median(ProtonColors.textNorm),
              height: 48),
          const SizedBox(
            height: 10,
          ),
          ButtonV5(
              onPressed: () {
                DBHelper.reset();
              },
              text: "Reset DB",
              width: MediaQuery.of(context).size.width - 52,
              backgroundColor: ProtonColors.surfaceLight,
              borderColor: const Color.fromARGB(255, 226, 226, 226),
              textStyle: FontManager.body1Median(ProtonColors.textNorm),
              height: 48),
          const SizedBox(
            height: 10,
          ),
          ButtonV5(
              onPressed: () async {
                viewModel.fetchWallets();
              },
              text: "API Sync",
              width: MediaQuery.of(context).size.width - 52,
              backgroundColor: ProtonColors.surfaceLight,
              borderColor: const Color.fromARGB(255, 226, 226, 226),
              textStyle: FontManager.body1Median(ProtonColors.textNorm),
              height: 48),
          const SizedBox(
            height: 10,
          ),
          ButtonV5(
              onPressed: () async {
                EventLoopHelper.runOnce();
              },
              text: "Event Loop Check",
              width: MediaQuery.of(context).size.width - 52,
              backgroundColor: ProtonColors.surfaceLight,
              borderColor: const Color.fromARGB(255, 226, 226, 226),
              textStyle: FontManager.body1Median(ProtonColors.textNorm),
              height: 48),
          const SizedBox(
            height: 10,
          ),
          ButtonV5(
              onPressed: () async {},
              text: "Get ExchangeRate",
              width: MediaQuery.of(context).size.width - 52,
              backgroundColor: ProtonColors.surfaceLight,
              borderColor: const Color.fromARGB(255, 226, 226, 226),
              textStyle: FontManager.body1Median(ProtonColors.textNorm),
              height: 48),
          const SizedBox(
            height: 10,
          ),
          ButtonV5(
              onPressed: () async {
                List<String> contents = [];
                contents.add(
                    "userId = ${await SecureStorageHelper.get("userId")}\n");
                contents.add(
                    "userMail = ${await SecureStorageHelper.get("userMail")}\n");
                contents.add(
                    "userName = ${await SecureStorageHelper.get("userName")}\n");
                contents.add(
                    "userDisplayName = ${await SecureStorageHelper.get("userDisplayName")}\n");
                contents.add(
                    "sessionId = ${await SecureStorageHelper.get("sessionId")}\n");
                contents.add(
                    "accessToken = ${await SecureStorageHelper.get("accessToken")}\n");
                contents.add(
                    "refreshToken = ${await SecureStorageHelper.get("refreshToken")}\n");
                contents.add(
                    "userKeyID = ${await SecureStorageHelper.get("userKeyID")}\n");
                contents.add(
                    "userPrivateKey = ${await SecureStorageHelper.get("userPrivateKey")}\n");
                contents.add(
                    "userPassphrase = ${await SecureStorageHelper.get("userPassphrase")}\n");
                if (context.mounted) {
                  showMyAlertDialog(context, contents.join("\n"));
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
              padding: const EdgeInsets.only(left: 26.0, right: 26.0),
              child: Text(S.of(context).explore_wallet,
                  style: FontManager.body1Median(ProtonColors.textNorm))),
          const SizedBox(height: 10),
          CustomNewsBox(
              title: S.of(context).security_n_proton_wallet,
              content: S.of(context).how_to_stay_safe_and_protect_your_assets,
              iconPath: "assets/images/icon/protect.svg",
              width: MediaQuery.of(context).size.width - 52),
          const SizedBox(height: 10),
          CustomNewsBox(
              title: S.of(context).wallets_n_accounts,
              content: S.of(context).whats_the_different_and_how_to_use_them,
              iconPath: "assets/images/icon/wallet.svg",
              width: MediaQuery.of(context).size.width - 52),
          const SizedBox(height: 10),
          CustomNewsBox(
              title: S.of(context).transfer_bitcoin,
              content:
                  S.of(context).how_to_send_and_receive_bitcoin_with_proton,
              iconPath: "assets/images/icon/transfer.svg",
              width: MediaQuery.of(context).size.width - 52),
          const SizedBox(height: 10),
          CustomNewsBox(
              title: S.of(context).mobile_apps,
              content: S.of(context).start_using_proton_wallet_on_your_phone,
              iconPath: "assets/images/icon/mobile.svg",
              width: MediaQuery.of(context).size.width - 52),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }
}

void showWalletMoreDialog(
    HomeViewModel viewModel, WalletModel walletModel, BuildContext context,
    {bool expired = false}) {
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
            expired
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 5,
                      ),
                      Align(
                          alignment: Alignment.center,
                          child: AlertWarning(
                              content:
                                  S.of(context).wallet_decryption_error_message,
                              width: MediaQuery.of(context).size.width - 30)),
                      const SizedBox(
                        height: 5,
                      ),
                      ListTile(
                        leading: const Icon(Icons.lock_open, size: 18),
                        title: Text(
                            S.of(context).wallet_recover_with_old_password,
                            style: FontManager.body2Regular(
                                ProtonColors.textNorm)),
                        onTap: () {},
                      ),
                      ListTile(
                        leading: const Icon(Icons.import_export, size: 18),
                        title: Text(S.of(context).wallet_recover_with_mnemonic,
                            style: FontManager.body2Regular(
                                ProtonColors.textNorm)),
                        onTap: () {},
                      ),
                      ListTile(
                        leading: const Icon(Icons.delete, size: 18),
                        title: Text(S.of(context).delete_wallet,
                            style: FontManager.body2Regular(
                                ProtonColors.textNorm)),
                        onTap: () {
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                          viewModel.setSelectedWallet(walletModel.id ?? 0);
                          viewModel.move(ViewIdentifiers.walletDeletion);
                        },
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        ListTile(
                          leading: const Icon(Icons.key, size: 18),
                          title: Text(S.of(context).set_passphrase,
                              style: FontManager.body2Regular(
                                  ProtonColors.textNorm)),
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return showUpdateWalletPassphraseDialog(
                                      context, viewModel, walletModel);
                                });
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.edit, size: 18),
                          title: Text(S.of(context).rename_wallet,
                              style: FontManager.body2Regular(
                                  ProtonColors.textNorm)),
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return showUpdateWalletNameDialog(
                                      context, viewModel, walletModel);
                                });
                          },
                        ),
                        ListTile(
                          leading:
                              const Icon(Icons.download_for_offline, size: 18),
                          title: Text(S.of(context).backup_wallet,
                              style: FontManager.body2Regular(
                                  ProtonColors.textNorm)),
                          onTap: () async {
                            Clipboard.setData(ClipboardData(
                                    text: await WalletManager.getMnemonicWithID(
                                        walletModel.id!)))
                                .then((_) {
                              LocalToast.showToast(
                                  context, S.of(context).copied_mnemonic);
                            });
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.delete, size: 18),
                          title: Text(S.of(context).delete_wallet,
                              style: FontManager.body2Regular(
                                  ProtonColors.textNorm)),
                          onTap: () async {
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                            viewModel.setSelectedWallet(walletModel.id ?? 0);
                            viewModel.move(ViewIdentifiers.walletDeletion);
                          },
                        )
                      ])
          ],
        ),
      );
    },
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
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return const CustomFullpageLoading();
            },
          );
          await proton_api.updateWalletName(
              walletId: walletModel.serverWalletID,
              newName: textEditingController.text);
          walletModel.name = textEditingController.text;
          await DBHelper.walletDao!.update(walletModel);
          viewModel.forceReloadWallet = true;
          if (context.mounted) {
            Navigator.of(context).pop(); // pop progressing overlay
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
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return const CustomFullpageLoading();
            },
          );
          await SecureStorageHelper.set(
              walletModel.serverWalletID, textEditingController.text);
          viewModel.forceReloadWallet = true;
          if (context.mounted) {
            Navigator.of(context).pop(); // pop progressing overlay
            Navigator.of(context).pop(); // pop current dialog
          }
        },
        child: Text(S.of(context).submit),
      ),
    ],
  );
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
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(S.of(context).ok),
          ),
        ],
      );
    },
  );
}

class NestedDialog extends StatelessWidget {
  const NestedDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Navigator(
            key: const Key("NestedDialogForSetup"),
            // add a unique key to refer to this navigator programmatically

            initialRoute: '/',
            onGenerateRoute: (RouteSettings settings) {
              return MaterialPageRoute(
                  builder: (_) => SetupOnbaordCoordinator().start());
            }));
  }
}
