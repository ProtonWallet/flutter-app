import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:wallet/components/custom.piechart.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/currency_helper.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/local_toast.dart';
import 'package:wallet/helper/secure_storage_helper.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/home.v2/home.viewmodel.dart';
import 'package:wallet/scenes/setup/onboard.coordinator.dart';
import 'package:wallet/theme/theme.font.dart';

import '../../components/button.v5.dart';
import '../../components/custom.newsbox.dart';
import '../../components/tag.text.dart';
import '../../helper/user.session.dart';

class HomeView extends ViewBase<HomeViewModel> {
  HomeView(HomeViewModel viewModel) : super(viewModel, const Key("HomeView"));

  @override
  Widget buildWithViewModel(
      BuildContext context, HomeViewModel viewModel, ViewSize viewSize) {
    if (viewModel.hasWallet == false) {
      // viewModel.setOnBoard(context);
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
          "Proton Wallet",
          style:
              FontManager.titleHeadline(Theme.of(context).colorScheme.primary),
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
                  color: Theme.of(context).colorScheme.surface,
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
                            "Welcome ${Provider.of<UserSessionProvider>(context).userSession.userName} 👋",
                            style: FontManager.body1Bold(ProtonColors.white)),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(left: 50, right: 50),
                          child: Text(
                            "Start using your Proton Wallet by either buying or transferring Bitcoin.",
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
                                text: "Buy Bitcoin",
                                width: 140,
                                radius: 28,
                                backgroundColor:
                                    Theme.of(context).colorScheme.surface,
                                borderColor:
                                    const Color.fromARGB(255, 226, 226, 226),
                                textStyle: FontManager.captionRegular(
                                    Theme.of(context).colorScheme.primary),
                                height: 32),
                            const SizedBox(width: 10),
                            ButtonV5(
                                onPressed: () {},
                                text: "Transfer Bitcoin",
                                width: 140,
                                radius: 28,
                                backgroundColor:
                                    Theme.of(context).colorScheme.surface,
                                borderColor:
                                    const Color.fromARGB(255, 226, 226, 226),
                                textStyle: FontManager.captionRegular(
                                    Theme.of(context).colorScheme.primary),
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
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: const Color.fromARGB(255, 226, 226, 226),
                      width: 1.0,
                    )),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("My Assets",
                        style: FontManager.captionRegular(
                            Theme.of(context).colorScheme.secondary)),
                    Text("${viewModel.totalBalance} Sat",
                        style: FontManager.titleSubHeadline(
                            Theme.of(context).colorScheme.primary)),
                    Text(
                        "${CurrencyHelper.sat2usdt(viewModel.totalBalance).toStringAsFixed(2)} USD",
                        style: FontManager.overlineRegular(
                            Theme.of(context).colorScheme.secondary)),
                  ],
                )),
            const SizedBox(
              width: 20,
            ),
            Container(
                width: MediaQuery.of(context).size.width / 2 - 36,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: const Color.fromARGB(255, 226, 226, 226),
                      width: 1.0,
                    )),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Last 7 days",
                        style: FontManager.captionRegular(
                            Theme.of(context).colorScheme.secondary)),
                    Text("+${viewModel.totalBalance} Sat",
                        style: FontManager.titleSubHeadline(
                            ProtonColors.signalSuccess)),
                    Text(
                        "${CurrencyHelper.sat2usdt(viewModel.totalBalance).toStringAsFixed(2)} USD",
                        style: FontManager.overlineRegular(
                            Theme.of(context).colorScheme.secondary)),
                  ],
                )),
          ]),
          const SizedBox(height: 20),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                    padding: const EdgeInsets.only(left: 26.0, right: 26.0),
                    child: Text("Your Wallets",
                        style: FontManager.body1Median(
                            Theme.of(context).colorScheme.primary))),
                GestureDetector(
                    onTap: () {
                      viewModel.coordinator
                          .move(ViewIdentifiers.setupOnboard, context);
                    },
                    child: Padding(
                        padding: const EdgeInsets.only(left: 26.0, right: 26.0),
                        child: Text("Add Wallet",
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
                                viewModel.updateWallet(wallet.id ?? 0);
                                viewModel.coordinator
                                    .move(ViewIdentifiers.wallet, context);
                              },
                              child: Container(
                                  width: 200.0,
                                  height: 140.0,
                                  padding: const EdgeInsets.all(10.0),
                                  margin: const EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.surface,
                                      borderRadius: BorderRadius.circular(10.0),
                                      border: Border.all(
                                        color: const Color.fromARGB(
                                            255, 226, 226, 226),
                                        width: 1.0,
                                      )),
                                  child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 5, right: 5),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const TagText(
                                            text: "OnChain",
                                            radius: 10.0,
                                            background: Color.fromARGB(
                                                255, 200, 248, 255),
                                            textColor: Color.fromARGB(
                                                255, 18, 134, 159),
                                          ),
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
                        "You can send and receive Bitcoin using your email address.",
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
                                viewModel.coordinator
                                    .move(ViewIdentifiers.mailList, context);
                              },
                              child: Container(
                                constraints: const BoxConstraints(
                                  minWidth: 100.0,
                                ),
                                child: Text(
                                  "Set up address",
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
                                  "Later",
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
                  child: Text("Statistic",
                      style: FontManager.body1Median(
                          Theme.of(context).colorScheme.primary))),
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
              child: Text("Quick Actions",
                  style: FontManager.body1Median(
                      Theme.of(context).colorScheme.primary))),
          const SizedBox(
            height: 10,
          ),
          ButtonV5(
              onPressed: () {
                viewModel.coordinator.move(ViewIdentifiers.send, context);
              },
              text: "Send",
              width: MediaQuery.of(context).size.width - 52,
              backgroundColor: Theme.of(context).colorScheme.surface,
              borderColor: const Color.fromARGB(255, 226, 226, 226),
              textStyle: FontManager.body1Median(
                  Theme.of(context).colorScheme.primary),
              height: 48),
          const SizedBox(
            height: 10,
          ),
          ButtonV5(
              onPressed: () {
                viewModel.coordinator.move(ViewIdentifiers.receive, context);
              },
              text: "Receive",
              width: MediaQuery.of(context).size.width - 52,
              backgroundColor: Theme.of(context).colorScheme.surface,
              borderColor: const Color.fromARGB(255, 226, 226, 226),
              textStyle: FontManager.body1Median(
                  Theme.of(context).colorScheme.primary),
              height: 48),
          const SizedBox(
            height: 10,
          ),
          ButtonV5(
              onPressed: () {},
              text: "Swap",
              width: MediaQuery.of(context).size.width - 52,
              backgroundColor: Theme.of(context).colorScheme.surface,
              borderColor: const Color.fromARGB(255, 226, 226, 226),
              textStyle: FontManager.body1Median(
                  Theme.of(context).colorScheme.primary),
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
              backgroundColor: Theme.of(context).colorScheme.surface,
              borderColor: const Color.fromARGB(255, 226, 226, 226),
              textStyle: FontManager.body1Median(
                  Theme.of(context).colorScheme.primary),
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
              backgroundColor: Theme.of(context).colorScheme.surface,
              borderColor: const Color.fromARGB(255, 226, 226, 226),
              textStyle: FontManager.body1Median(
                  Theme.of(context).colorScheme.primary),
              height: 48),
          const SizedBox(
            height: 10,
          ),
          ButtonV5(
              onPressed: () async {
                List<String> contents = [];
                contents.add("userId = ${await SecureStorageHelper.get("userId")}\n");
                contents.add("userMail = ${await SecureStorageHelper.get("userMail")}\n");
                contents.add("userName = ${await SecureStorageHelper.get("userName")}\n");
                contents.add("userDisplayName = ${await SecureStorageHelper.get("userDisplayName")}\n");
                contents.add("sessionId = ${await SecureStorageHelper.get("sessionId")}\n");
                contents.add("accessToken = ${await SecureStorageHelper.get("accessToken")}\n");
                contents.add("refreshToken = ${await SecureStorageHelper.get("refreshToken")}\n");
                contents.add("userKeyID = ${await SecureStorageHelper.get("userKeyID")}\n");
                if (context.mounted){
                  showMyAlertDialog(context, contents.join("\n"));
                }
              },
              text: "Secure Storage",
              width: MediaQuery.of(context).size.width - 52,
              backgroundColor: Theme.of(context).colorScheme.surface,
              borderColor: const Color.fromARGB(255, 226, 226, 226),
              textStyle: FontManager.body1Median(
                  Theme.of(context).colorScheme.primary),
              height: 48),
          const SizedBox(
            height: 10,
          ),
          ButtonV5(
              onPressed: () async {
                await SecureStorageHelper.deleteAll();
                if (context.mounted){
                  LocalToast.showToast(context, "Deleted!");
                }
              },
              text: "Clear Secure Storage",
              width: MediaQuery.of(context).size.width - 52,
              backgroundColor: Theme.of(context).colorScheme.surface,
              borderColor: const Color.fromARGB(255, 226, 226, 226),
              textStyle: FontManager.body1Median(
                  Theme.of(context).colorScheme.primary),
              height: 48),
          const SizedBox(
            height: 20,
          ),
          Padding(
              padding: const EdgeInsets.only(left: 26.0, right: 26.0),
              child: Text("Explore Proton Wallet",
                  style: FontManager.body1Median(
                      Theme.of(context).colorScheme.primary))),
          const SizedBox(height: 10),
          CustomNewsBox(
              title: "Security & Proton Wallet",
              content: "How to stay safe and protect your assets.",
              iconPath: "assets/images/icon/protect.svg",
              width: MediaQuery.of(context).size.width - 52),
          const SizedBox(height: 10),
          CustomNewsBox(
              title: "Wallets & Accounts",
              content: "Whats the different and how to use them.",
              iconPath: "assets/images/icon/wallet.svg",
              width: MediaQuery.of(context).size.width - 52),
          const SizedBox(height: 10),
          CustomNewsBox(
              title: "Transfer Bitcoin",
              content: "How to send and receive Bitcoin with Proton.",
              iconPath: "assets/images/icon/transfer.svg",
              width: MediaQuery.of(context).size.width - 52),
          const SizedBox(height: 10),
          CustomNewsBox(
              title: "Mobile Apps",
              content: "Start using Proton Wallet on your phone.",
              iconPath: "assets/images/icon/mobile.svg",
              width: MediaQuery.of(context).size.width - 52),
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
              Navigator.of(context).pop();
            },
            child: const Text("Ok"),
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
