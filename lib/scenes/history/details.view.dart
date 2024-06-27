import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:wallet/components/textfield.text.v2.dart';
import 'package:wallet/components/transaction.history.item.dart';
import 'package:wallet/components/transaction.history.send.item.dart';
import 'package:wallet/constants/app.config.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/helper/bitcoin.amount.dart';
import 'package:wallet/helper/exchange.caculator.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/models/transaction.info.model.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/history/bottom.sheet/edit.sender.dart';
import 'package:wallet/scenes/history/details.viewmodel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wallet/theme/theme.font.dart';

class HistoryDetailView extends ViewBase<HistoryDetailViewModel> {
  const HistoryDetailView(HistoryDetailViewModel viewModel)
      : super(viewModel, const Key("HistoryDetailView"));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
          statusBarBrightness: Brightness.light, // For iOS (dark icons)
        ),
        backgroundColor: ProtonColors.backgroundProton,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
        ),
        scrolledUnderElevation:
            0.0, // don't change background color when scroll down
      ),
      body: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: buildNoHistory(context, viewModel)),
    );
  }

  Widget buildNoHistory(
      BuildContext context, HistoryDetailViewModel viewModel) {
    String fiatCurrencyName =
        viewModel.userSettingsDataProvider.getFiatCurrencyName();
    String fiatCurrencySign =
        viewModel.userSettingsDataProvider.getFiatCurrencySign();
    int displayDigits = defaultDisplayDigits;
    if (viewModel.exchangeRate != null) {
      fiatCurrencyName = viewModel.userSettingsDataProvider.getFiatCurrencyName(
          fiatCurrency: viewModel.exchangeRate!.fiatCurrency);
      fiatCurrencySign = viewModel.userSettingsDataProvider.getFiatCurrencySign(
          fiatCurrency: viewModel.exchangeRate!.fiatCurrency);
      displayDigits = (log(viewModel.exchangeRate!.cents) / log(10)).round();
    } else {
      displayDigits =
          (log(viewModel.userSettingsDataProvider.exchangeRate.cents) / log(10))
              .round();
    }
    return Container(
        color: ProtonColors.backgroundProton,
        height: double.infinity,
        child: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                            margin: const EdgeInsets.only(right: 4, top: 2),
                            padding: const EdgeInsets.all(2.0),
                            child: SvgPicture.asset(
                                viewModel.isSend
                                    ? "assets/images/icon/send.svg"
                                    : "assets/images/icon/receive.svg",
                                fit: BoxFit.fill,
                                width: 25,
                                height: 25)),
                        Text(
                            viewModel.isSend
                                ? S.of(context).you_sent
                                : S.of(context).you_received,
                            style:
                                FontManager.body2Regular(ProtonColors.textHint))
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                            "$fiatCurrencySign${ExchangeCalculator.getNotionalInFiatCurrency(viewModel.exchangeRate ?? viewModel.userSettingsDataProvider.exchangeRate, viewModel.amount.toInt()).abs().toStringAsFixed(displayDigits)}",
                            style: FontManager.transactionHistoryAmountTitle(
                                ProtonColors.textNorm)),
                        const SizedBox(width: 4),
                        Text(fiatCurrencyName,
                            style: FontManager.body2Regular(
                                ProtonColors.textNorm)),
                      ],
                    ),
                    Text(
                        ExchangeCalculator.getBitcoinUnitLabel(
                            viewModel.userSettingsDataProvider.bitcoinUnit,
                            viewModel.amount.toInt().abs()),
                        style: FontManager.body2Regular(ProtonColors.textHint)),
                    const SizedBox(height: 20),
                    viewModel.isEditing == false
                        ? GestureDetector(
                            onTap: () {
                              viewModel.editMemo();
                            },
                            child: Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 10.0),
                                padding: const EdgeInsets.all(defaultPadding),
                                decoration: BoxDecoration(
                                    color:
                                        ProtonColors.transactionNoteBackground,
                                    borderRadius: BorderRadius.circular(40.0)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                        "assets/images/icon/ic_note.svg",
                                        fit: BoxFit.fill,
                                        width: 32,
                                        height: 32),
                                    const SizedBox(width: 10),
                                    Expanded(
                                        child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (viewModel
                                            .memoController.text.isNotEmpty)
                                          Row(children: [
                                            Expanded(
                                                child: Text(
                                                    viewModel
                                                        .memoController.text,
                                                    style:
                                                        FontManager.body2Median(
                                                            ProtonColors
                                                                .textNorm)))
                                          ]),
                                        Text(S.of(context).trans_edit_note,
                                            style: FontManager.body2Median(
                                                ProtonColors.protonBlue)),
                                      ],
                                    ))
                                  ],
                                )))
                        : Container(
                            margin: const EdgeInsets.symmetric(vertical: 10.0),
                            child: TextFieldTextV2(
                              labelText: S.of(context).trans_userLable,
                              textController: viewModel.memoController,
                              myFocusNode: viewModel.memoFocusNode,
                              paddingSize: 7,
                              maxLines: null,
                              showCounterText: true,
                              maxLength: maxMemoTextCharSize,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(
                                    maxMemoTextCharSize)
                              ],
                              validation: (String value) {
                                return "";
                              },
                            ),
                          ),
                    viewModel.isSend
                        ? buildSendInfo(context)
                        : buildReceiveInfo(context),
                    const Divider(
                      thickness: 0.2,
                      height: 1,
                    ),
                    if (viewModel.blockConfirmTimestamp != null)
                      TransactionHistoryItem(
                          title: S.of(context).trans_date,
                          content: parsetime(
                              context, viewModel.blockConfirmTimestamp!)),
                    const Divider(
                      thickness: 0.2,
                      height: 1,
                    ),
                    TransactionHistoryItem(
                        title: S.of(context).trans_status,
                        content: viewModel.blockConfirmTimestamp != null
                            ? S.of(context).completed
                            : S.of(context).in_progress,
                        contentColor: viewModel.blockConfirmTimestamp != null
                            ? ProtonColors.signalSuccess
                            : ProtonColors.signalError),
                    const Divider(
                      thickness: 0.2,
                      height: 1,
                    ),
                    if (viewModel.body.isNotEmpty)
                      Column(children: [
                        TransactionHistoryItem(
                            title: viewModel.isSend
                                ? S.of(context).trans_message_to_recipient
                                : S.of(context).trans_message_from_sender,
                            content: viewModel.body),
                        const Divider(
                          thickness: 0.2,
                          height: 1,
                        ),
                      ]),
                    ExpansionTile(
                        shape: const Border(),
                        initiallyExpanded: false,
                        title: Text(S.of(context).view_more,
                            style:
                                FontManager.body2Median(ProtonColors.textWeak)),
                        iconColor: ProtonColors.textHint,
                        collapsedIconColor: ProtonColors.textHint,
                        children: [
                          TransactionHistoryItem(
                            title: S.of(context).trans_metwork_fee,
                            titleTooltip: S.of(context).trans_metwork_fee_desc,
                            content:
                                "$fiatCurrencyName ${ExchangeCalculator.getNotionalInFiatCurrency(viewModel.exchangeRate ?? viewModel.userSettingsDataProvider.exchangeRate, viewModel.fee.toInt()).toStringAsFixed(displayDigits)}",
                            memo: ExchangeCalculator.getBitcoinUnitLabel(
                                viewModel.userSettingsDataProvider.bitcoinUnit,
                                viewModel.fee.toInt()),
                          ),
                          const Divider(
                            thickness: 0.2,
                            height: 1,
                          ),
                          TransactionHistoryItem(
                              title: S.of(context).trans_total,
                              content: viewModel.isSend
                                  ? "$fiatCurrencyName ${ExchangeCalculator.getNotionalInFiatCurrency(viewModel.exchangeRate ?? viewModel.userSettingsDataProvider.exchangeRate, viewModel.amount.toInt() - viewModel.fee.toInt()).abs().toStringAsFixed(displayDigits)}"
                                  : "$fiatCurrencyName ${ExchangeCalculator.getNotionalInFiatCurrency(viewModel.exchangeRate ?? viewModel.userSettingsDataProvider.exchangeRate, viewModel.amount.toInt() + viewModel.fee.toInt()).toStringAsFixed(displayDigits)}",
                              memo: viewModel.isSend
                                  ? ExchangeCalculator.getBitcoinUnitLabel(
                                      viewModel
                                          .userSettingsDataProvider.bitcoinUnit,
                                      viewModel.amount.toInt() -
                                          viewModel.fee.toInt().abs())
                                  : ExchangeCalculator.getBitcoinUnitLabel(
                                      viewModel
                                          .userSettingsDataProvider.bitcoinUnit,
                                      viewModel.amount.toInt() +
                                          viewModel.fee.toInt())),
                          const SizedBox(height: 20),
                          ButtonV5(
                              onPressed: () {
                                launchUrl(Uri.parse(
                                    "${appConfig.esploraWebpageUrl}search?q=${viewModel.txid}"));
                              },
                              text: S.of(context).view_on_blockstream,
                              width: MediaQuery.of(context).size.width,
                              backgroundColor: ProtonColors.protonBlue,
                              textStyle:
                                  FontManager.body1Median(ProtonColors.white),
                              height: 48),
                          const SizedBox(height: 20),
                        ])
                  ],
                ))));
  }

  Widget buildSendInfo(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        viewModel.recipients.isEmpty
            ? buildTransToInfo(
                context,
                email: viewModel.toEmail.isNotEmpty
                    ? WalletManager.getEmailFromWalletTransaction(
                        viewModel.toEmail)
                    : null,
                bitcoinAddress: viewModel.toEmail.isNotEmpty
                    ? WalletManager.getBitcoinAddressFromWalletTransaction(
                        viewModel.toEmail)
                    : viewModel.addresses.firstOrNull ?? "",
              )
            : Column(children: [
                for (TransactionInfoModel info in viewModel.recipients)
                  buildTransToInfo(context,
                      email: info.toEmail.isNotEmpty ? info.toEmail : null,
                      bitcoinAddress: info.toBitcoinAddress,
                      amountInSatoshi: info.amountInSATS)
              ]),
        TransactionHistoryItem(
          title: S.of(context).trans_from,
          content:
              "${WalletManager.getEmailFromWalletTransaction(viewModel.fromEmail)} (You)",
          memo: "${viewModel.strWallet} - ${viewModel.strAccount}",
        ),
      ],
    );
  }

  Widget buildTransToInfo(BuildContext context,
      {String? email,
      String? bitcoinAddress,
      String? walletAccountName,
      int? amountInSatoshi}) {
    return Column(children: [
      if (viewModel.exchangeRate != null && amountInSatoshi != null)
        TransactionHistorySendItem(
          content: email ?? bitcoinAddress ?? "",
          bitcoinAddress: bitcoinAddress ?? "",
          bitcoinAmount: BitcoinAmount(
              amountInSatoshi: amountInSatoshi,
              bitcoinUnit: viewModel.userSettingsDataProvider.bitcoinUnit,
              exchangeRate: viewModel.exchangeRate!),
        ),
      const Divider(
        thickness: 0.2,
        height: 1,
      ),
    ]);
  }

  Widget buildReceiveInfo(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(children: [
          TransactionHistoryItem(
            title: S.of(context).trans_from,
            content: viewModel.fromEmail.isNotEmpty
                ? WalletManager.getEmailFromWalletTransaction(
                    viewModel.fromEmail)
                : "Unknown",
          ),
          Positioned(
              top: 20,
              right: defaultPadding,
              child: GestureDetector(
                  onTap: () {
                    EditSenderSheet.show(context, viewModel);
                  },
                  child: SvgPicture.asset(
                    "assets/images/icon/edit_unknown.svg",
                    fit: BoxFit.fill,
                    width: 40,
                    height: 40,
                  ))),
        ]),
        const Divider(
          thickness: 0.2,
          height: 1,
        ),
        TransactionHistorySendItem(
          content: viewModel.toEmail.isNotEmpty
              ? "${WalletManager.getEmailFromWalletTransaction(viewModel.toEmail)} (You)"
              : "${viewModel.strWallet} - ${viewModel.strAccount}",
          walletAccountName: "${viewModel.strWallet} - ${viewModel.strAccount}",
          bitcoinAddress: viewModel.selfBitcoinAddress ?? "",
          bitcoinAmount: viewModel.exchangeRate != null
              ? BitcoinAmount(
                  amountInSatoshi: viewModel.amount.toInt(),
                  bitcoinUnit: viewModel.userSettingsDataProvider.bitcoinUnit,
                  exchangeRate: viewModel.exchangeRate!)
              : null,
        ),
      ],
    );
  }

  String parsetime(BuildContext context, int timestemp) {
    var millis = timestemp;
    var dt = DateTime.fromMillisecondsSinceEpoch(millis * 1000);

    var dateLocalFormat =
        DateFormat.yMd(Platform.localeName).add_jm().format(dt);
    return dateLocalFormat.toString();
  }
}

void showNetworkFee(BuildContext context) {
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
          return SafeArea(
            child: SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                            "assets/images/icon/no_wallet_found.svg",
                            fit: BoxFit.fill,
                            width: 86,
                            height: 87),
                        const SizedBox(height: 10),
                        Text(S.of(context).placeholder,
                            style:
                                FontManager.body1Median(ProtonColors.textNorm)),
                        const SizedBox(height: 5),
                        Text(S.of(context).placeholder,
                            style: FontManager.body2Regular(
                                ProtonColors.textWeak)),
                        const SizedBox(height: 20),
                        ButtonV5(
                          text: S.of(context).ok,
                          width: MediaQuery.of(context).size.width,
                          backgroundColor: ProtonColors.protonBlue,
                          textStyle:
                              FontManager.body1Median(ProtonColors.white),
                          height: 48,
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        const SizedBox(height: 10),
                      ],
                    ))),
          );
        });
      });
}
