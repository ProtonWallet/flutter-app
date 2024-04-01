import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/components/tag.text.dart';
import 'package:wallet/components/textfield.text.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/currency_helper.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/history/details.viewmodel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wallet/theme/theme.font.dart';

class HistoryDetailView extends ViewBase<HistoryDetailViewModel> {
  HistoryDetailView(HistoryDetailViewModel viewModel)
      : super(viewModel, const Key("HistoryDetailView"));

  @override
  Widget buildWithViewModel(BuildContext context,
      HistoryDetailViewModel viewModel, ViewSize viewSize) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
          statusBarBrightness: Brightness.light, // For iOS (dark icons)
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text(S.of(context).trans_details),
        scrolledUnderElevation:
            0.0, // don't change background color when scroll down
      ),
      body: buildNoHistory(context, viewModel, viewSize),
    );
  }

  Widget buildNoHistory(BuildContext context, HistoryDetailViewModel viewModel,
      ViewSize viewSize) {
    return SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: ProtonColors.wMajor1,
                        ),
                        margin: const EdgeInsets.only(right: 4, top: 2),
                        padding: const EdgeInsets.all(2.0),
                        child: Icon(
                            viewModel.isSend
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            size: 12,
                            color: ProtonColors.textHint)),
                    Text(
                        viewModel.isSend
                            ? S.of(context).send
                            : S.of(context).receive,
                        style: FontManager.body2Regular(ProtonColors.textHint))
                  ],
                ),
                viewModel.isSend
                    ? Text("${viewModel.amount} SAT",
                        style: FontManager.titleHero(ProtonColors.signalError))
                    : Text("+${viewModel.amount} SAT",
                        style:
                            FontManager.titleHero(ProtonColors.signalSuccess)),
                Text(
                    viewModel.isSend
                        ? "-\$${viewModel.notional}"
                        : "+\$${viewModel.notional}",
                    style: FontManager.titleSubHeadline(ProtonColors.textHint)),
                const SizedBox(height: 40),
                viewModel.isSend
                    ? buildSendInfo(context, viewModel, viewSize)
                    : buildReceiveInfo(context, viewModel, viewSize),
                Container(
                  height: 30,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(S.of(context).trans_submitted,
                            style: FontManager.captionMedian(
                                Theme.of(context).colorScheme.primary)),
                        Text(parsetime(viewModel.submitTimestamp),
                            style: FontManager.captionMedian(
                                Theme.of(context).colorScheme.primary)),
                      ]),
                ),
                Container(
                  height: 30,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(S.of(context).trans_completed,
                            style: FontManager.captionMedian(
                                Theme.of(context).colorScheme.primary)),
                        Text(parsetime(viewModel.completeTimestamp),
                            style: FontManager.captionMedian(
                                Theme.of(context).colorScheme.primary)),
                      ]),
                ),
                Container(
                  height: 30,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(S.of(context).trans_amount,
                            style: FontManager.captionMedian(
                                Theme.of(context).colorScheme.primary)),
                        Row(children: [
                          Text(
                              viewModel.isSend
                                  ? "\$${CurrencyHelper.sat2usdt(viewModel.amount.abs() - viewModel.fee).toStringAsFixed(3)}"
                                  : "\$${CurrencyHelper.sat2usdt(viewModel.amount.abs()).toStringAsFixed(3)}",
                              style: FontManager.captionMedian(
                                  ProtonColors.textHint)),
                          const SizedBox(width: 8),
                          Text(
                              viewModel.isSend
                                  ? S.of(context).transaction_sats(
                                      viewModel.amount.abs() - viewModel.fee)
                                  : S
                                      .of(context)
                                      .transaction_sats(viewModel.amount.abs()),
                              style: FontManager.captionMedian(
                                  Theme.of(context).colorScheme.primary)),
                        ])
                      ]),
                ),
                Container(
                  height: 30,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(S.of(context).trans_metworkFee,
                            style: FontManager.captionMedian(
                                Theme.of(context).colorScheme.primary)),
                        Row(children: [
                          Text(
                              "\$${CurrencyHelper.sat2usdt(viewModel.fee).toStringAsFixed(3)}",
                              style: FontManager.captionMedian(
                                  ProtonColors.textHint)),
                          const SizedBox(width: 8),
                          Text(S.of(context).transaction_sats(viewModel.fee),
                              style: FontManager.captionMedian(
                                  Theme.of(context).colorScheme.primary)),
                        ])
                      ]),
                ),
                Container(
                  height: 30,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(S.of(context).trans_total,
                            style: FontManager.captionMedian(
                                Theme.of(context).colorScheme.primary)),
                        Row(children: [
                          Text(
                              viewModel.isSend
                                  ? "\$${CurrencyHelper.sat2usdt(viewModel.amount.abs()).toStringAsFixed(3)}"
                                  : "\$${CurrencyHelper.sat2usdt(viewModel.amount.abs() + viewModel.fee).toStringAsFixed(3)}",
                              style: FontManager.captionMedian(
                                  ProtonColors.textHint)),
                          const SizedBox(width: 8),
                          Text(
                              viewModel.isSend
                                  ? "${viewModel.amount.abs()} SAT"
                                  : "${viewModel.amount.abs() + viewModel.fee} SAT",
                              style: FontManager.captionMedian(
                                  Theme.of(context).colorScheme.primary)),
                        ])
                      ]),
                ),
                Container(
                    height: 30,
                    margin: const EdgeInsets.only(top: 8.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(S.of(context).trans_userLable,
                              style: FontManager.captionMedian(
                                  Theme.of(context).colorScheme.primary))
                        ])),
                Container(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: TextFieldText(
                      width: MediaQuery.of(context).size.width,
                      height: 120,
                      multiLine: true,
                      suffixIcon: const Icon(Icons.save_as_rounded),
                      showSuffixIcon: false,
                      controller: viewModel.memoController,
                      focusNode: viewModel.memoFocusNode,
                    )),
                const SizedBox(height: 40),
                ButtonV5(
                    onPressed: () {
                      launchUrl(Uri.parse(
                          "https://blockstream.info/testnet/search?q=${viewModel.txid}"));
                    },
                    text: S.of(context).view_on_blockstream,
                    width: MediaQuery.of(context).size.width,
                    backgroundColor: ProtonColors.surfaceLight,
                    borderColor: const Color.fromARGB(255, 226, 226, 226),
                    textStyle: FontManager.body1Median(
                        Theme.of(context).colorScheme.primary),
                    height: 48),
              ],
            )));
  }

  Widget buildSendInfo(BuildContext context, HistoryDetailViewModel viewModel,
      ViewSize viewSize) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
            height: 30,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(S.of(context).trans_from,
                      style: FontManager.captionMedian(
                          Theme.of(context).colorScheme.primary)),
                  Row(children: [
                    TagText(text: viewModel.strWallet),
                    const SizedBox(width: 4),
                    TagText(text: viewModel.strAccount)
                  ])
                ])),
        Container(
            height: 30,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(S.of(context).trans_to,
                      style: FontManager.captionMedian(
                          Theme.of(context).colorScheme.primary)),
                  TagText(text: viewModel.address)
                ])),
      ],
    );
  }

  Widget buildReceiveInfo(BuildContext context,
      HistoryDetailViewModel viewModel, ViewSize viewSize) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
            height: 30,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(S.of(context).trans_from,
                      style: FontManager.captionMedian(
                          Theme.of(context).colorScheme.primary)),
                  TagText(text: viewModel.address)
                ])),
        Container(
            height: 30,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(S.of(context).trans_to,
                      style: FontManager.captionMedian(
                          Theme.of(context).colorScheme.primary)),
                  Row(children: [
                    TagText(text: viewModel.strWallet),
                    const SizedBox(width: 4),
                    TagText(text: viewModel.strAccount)
                  ])
                ])),
      ],
    );
  }

  String parsetime(int timestemp) {
    var millis = timestemp;
    var dt = DateTime.fromMillisecondsSinceEpoch(millis * 1000);

    var d12 =
        DateFormat('MM/dd/yyyy, hh:mm a').format(dt); // 12/31/2000, 10:00 PM

    // var d24 = DateFormat('dd/MM/yyyy, HH:mm').format(dt); // 31/12/2000, 22:00
    return d12.toString();
  }
}
