import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wallet/components/dropdown.button.v1.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/wallet/wallet.viewmodel.dart';

import '../../components/add_account_dialog.dart';
import '../../components/custom.barchart.dart';
import '../../constants/proton.color.dart';
import '../../theme/theme.font.dart';
import '../core/view.navigatior.identifiers.dart';

class WalletView extends ViewBase<WalletViewModel> {
  WalletView(WalletViewModel viewModel)
      : super(viewModel, const Key("WalletView"));

  @override
  Widget buildWithViewModel(
      BuildContext context, WalletViewModel viewModel, ViewSize viewSize) {
    return Scaffold(
        appBar: AppBar(
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                Brightness.dark, // For Android (dark icons)
            statusBarBrightness: Brightness.light, // For iOS (dark icons)
          ),
          backgroundColor: Theme.of(context).colorScheme.background,
          scrolledUnderElevation:
              0.0, // don't change background color when scroll down
        ),
        body: ListView(children: [
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Center(
                child: Stack(children: <Widget>[
              Center(
                  child: SizedBox(
                      width: MediaQuery.of(context).size.width - 52,
                      height: 212,
                      child: SvgPicture.asset(
                        'assets/images/wallet_creation/card.svg',
                        width: MediaQuery.of(context).size.width - 52,
                        fit: BoxFit.fill,
                      ))),
              Center(
                child: SizedBox(
                    width: MediaQuery.of(context).size.width - 52,
                    height: 200,
                    child: Column(
                      children: <Widget>[
                        const SizedBox(height: 40),
                        Text(
                          viewModel.initialed ? viewModel.walletModel.name : "",
                          style: const TextStyle(
                            fontSize: 16.0,
                            color: ProtonColors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 60),
                        Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 72.0),
                            child: const Text(
                              "Bitcoin Wallet",
                              style: TextStyle(
                                  fontSize: 14.0, color: ProtonColors.wMajor1),
                            )),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                  margin: const EdgeInsets.only(left: 50.0),
                                  child: Text(
                                    viewModel.initialed
                                        ? "${viewModel.totalBalance} Sat"
                                        : "",
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      color: ProtonColors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )),
                              Container(
                                  margin: const EdgeInsets.only(right: 50.0),
                                  child: Text(
                                    viewModel.initialed
                                        ? viewModel.walletModel.localDBName
                                            .substring(0, 20)
                                        : "",
                                    style: const TextStyle(
                                        fontSize: 14.0,
                                        color: ProtonColors.wMajor1),
                                  )),
                            ]),
                      ],
                    )),
              )
            ])),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                      padding: const EdgeInsets.only(left: 26.0, right: 26.0),
                      child: Text("Your Accounts",
                          style: FontManager.body1Median(
                              Theme.of(context).colorScheme.primary))),
                  GestureDetector(
                      onTap: () {
                        if (viewModel.initialed) {
                          AddAccountAlertDialog.show(
                              context, viewModel.walletID);
                        }
                      },
                      child: Padding(
                          padding:
                              const EdgeInsets.only(left: 40.0, right: 40.0),
                          child: Text("Add Account",
                              style: FontManager.body1Median(
                                  ProtonColors.interactionNorm)))),
                ]),
            const SizedBox(height: 10),
            if (viewModel.initialed)
              DropdownButtonV1(
                  width: 400,
                  items: viewModel.accounts,
                  itemsText: viewModel.accounts
                      .map((v) => "${v.labelDecrypt} ${v.derivationPath}")
                      .toList(),
                  valueNotifier: viewModel.valueNotifier),
            if (viewModel.initialed)
              GestureDetector(
                  onTap: () {},
                  child: Container(
                      width: 400.0,
                      height: 100.0,
                      padding: const EdgeInsets.all(10.0),
                      margin: const EdgeInsets.all(6.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.4),
                            spreadRadius: 1,
                            blurRadius: 1,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("${viewModel.balance} Sat",
                              style: FontManager.titleHeadline(
                                  Theme.of(context).colorScheme.primary)),
                          Text("Confirmed Transactions: ${viewModel.confirmed}",
                              style: FontManager.captionRegular(
                                  Theme.of(context).colorScheme.secondary)),
                          Text(
                              "Unconfirmed Transactions: ${viewModel.unconfirmed}",
                              style: FontManager.captionRegular(
                                  Theme.of(context).colorScheme.secondary)),
                          Text(viewModel.isSyncing ? "Syncing.." : "",
                              style: FontManager.captionRegular(
                                  Theme.of(context).colorScheme.secondary)),
                        ],
                      ))),
            const SizedBox(
              height: 10,
            ),
            Container(
                width: 180,
                height: 180,
                margin: const EdgeInsets.only(left: 10, right: 10),
                child: const BarChartSample3()),
            Text("Transactions in past 7 days",
                style: FontManager.body1Median(
                    Theme.of(context).colorScheme.primary)),
            const SizedBox(
              height: 20,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              SizedBox(
                  width: 120,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      viewModel.coordinator.move(ViewIdentifiers.send, context);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6D4AFF), elevation: 0),
                    child: const Text(
                      "Send",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  )),
              const SizedBox(
                width: 10,
              ),
              SizedBox(
                  width: 120,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      viewModel.coordinator
                          .move(ViewIdentifiers.receive, context);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6D4AFF), elevation: 0),
                    child: const Text(
                      "Receive",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  )),
              const SizedBox(
                width: 10,
              ),
              SizedBox(
                  width: 120,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      viewModel.copyMnemonic(context);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6D4AFF), elevation: 0),
                    child: const Text(
                      "Mnemonic",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  )),
            ]),
            const SizedBox(
              height: 10,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              SizedBox(
                  width: 120,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      viewModel.syncWallet();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6D4AFF), elevation: 0),
                    child: const Text(
                      "Sync",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  )),
              const SizedBox(
                width: 10,
              ),
              SizedBox(
                  width: 120,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      viewModel.coordinator
                          .move(ViewIdentifiers.history, context);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6D4AFF), elevation: 0),
                    child: const Text(
                      "History",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  )),
              const SizedBox(
                width: 10,
              ),
              SizedBox(
                  width: 120,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      viewModel.coordinator.move(ViewIdentifiers.walletDeletion, context);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6D4AFF), elevation: 0),
                    child: const Text(
                      "Delete",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  )),
            ])
          ]),
        ]));
  }
}
