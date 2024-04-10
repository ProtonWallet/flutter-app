import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wallet/components/dropdown.button.v1.dart';
import 'package:wallet/helper/local_toast.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/wallet/wallet.viewmodel.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/components/add_account_dialog.dart';
import 'package:wallet/components/custom.barchart.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/theme/theme.font.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';

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
          backgroundColor: ProtonColors.backgroundProton,
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
                          style: TextStyle(
                            fontSize: 16.0,
                            color: ProtonColors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 60),
                        Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 72.0),
                            child: Text(
                              S.of(context).bitcoin_wallet,
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
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color: ProtonColors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )),
                              Container(
                                  margin: const EdgeInsets.only(right: 50.0),
                                  child: Text(
                                    viewModel.initialed
                                        ? viewModel.walletModel.serverWalletID
                                            .substring(0, 20)
                                        : "",
                                    style: TextStyle(
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
                      child: Text(S.of(context).your_account,
                          style: FontManager.body1Median(
                              ProtonColors.textNorm))),
                  GestureDetector(
                      onTap: () {
                        if (viewModel.initialed) {
                          AddAccountAlertDialog.show(
                              context,
                              viewModel.walletID,
                              viewModel.walletModel.serverWalletID,
                              callback: () {
                            viewModel.loadData();
                          });
                        }
                      },
                      child: Padding(
                          padding:
                              const EdgeInsets.only(left: 40.0, right: 40.0),
                          child: Text(S.of(context).add_account,
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
                        color: ProtonColors.backgroundProton,
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
                          Text(
                              S.of(context).transaction_sats(viewModel.balance),
                              style: FontManager.titleHeadline(
                                  ProtonColors.textNorm)),
                          Text(
                              S
                                  .of(context)
                                  .confirmed_trans(viewModel.confirmed),
                              style: FontManager.captionRegular(
                                  ProtonColors.textWeak)),
                          Text(
                              S
                                  .of(context)
                                  .unconfirmed_trans(viewModel.unconfirmed),
                              style: FontManager.captionRegular(
                                  ProtonColors.textWeak)),
                          Text(viewModel.isSyncing ? S.of(context).syncing : "",
                              style: FontManager.captionRegular(
                                  ProtonColors.textWeak)),
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
            Text(S.of(context).trans_past_seven,
                style: FontManager.body1Median(
                    ProtonColors.textNorm)),
            const SizedBox(
              height: 20,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              SizedBox(
                  width: 120,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      viewModel.move(ViewIdentifiers.send);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6D4AFF), elevation: 0),
                    child: Text(
                      S.of(context).send,
                      style: const TextStyle(
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
                      viewModel.move(ViewIdentifiers.receive);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6D4AFF), elevation: 0),
                    child: Text(
                      S.of(context).receive,
                      style: const TextStyle(
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
                    child: Text(
                      S.of(context).mnemonic,
                      style: const TextStyle(
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
                    child: Text(
                      S.of(context).sync,
                      style: const TextStyle(
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
                      viewModel.move(ViewIdentifiers.history);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6D4AFF), elevation: 0),
                    child: Text(
                      S.of(context).history,
                      style: const TextStyle(
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
                      viewModel.move(ViewIdentifiers.walletDeletion);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6D4AFF), elevation: 0),
                    child: Text(
                      S.of(context).delete,
                      style: const TextStyle(
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
                    onPressed: () async {
                      await viewModel.deleteAccount();
                      if (context.mounted) {
                        LocalToast.showToast(
                            context, S.of(context).account_deleted);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6D4AFF), elevation: 0),
                    child: Text(
                      S.of(context).delete_account,
                      style: const TextStyle(
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
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return showUpdateLabelDialog(
                                context, viewModel, viewSize);
                          });
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6D4AFF), elevation: 0),
                    child: Text(
                      S.of(context).update_account,
                      style: const TextStyle(
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

  Widget showUpdateLabelDialog(
      BuildContext context, WalletViewModel viewModel, ViewSize viewSize) {
    TextEditingController textEditingController = TextEditingController();
    textEditingController.text = viewModel.accountModel.labelDecrypt;
    return AlertDialog(
      title: Text(S.of(context).update_label),
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
            await viewModel.updateAccountLabel(textEditingController.text);
          },
          child: Text(S.of(context).submit),
        ),
      ],
    );
  }
}
