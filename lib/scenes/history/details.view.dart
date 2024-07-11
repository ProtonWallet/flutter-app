import 'dart:math';

import 'package:card_loading/card_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wallet/scenes/components/textfield.text.v2.dart';
import 'package:wallet/scenes/components/transaction.history.item.dart';
import 'package:wallet/scenes/components/transaction.history.send.item.dart';
import 'package:wallet/constants/app.config.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/helper/bitcoin.amount.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/exchange.caculator.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/button.v5.dart';
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
        backgroundColor: ProtonColors.white,
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
      displayDigits =
          (log(viewModel.exchangeRate!.cents.toInt()) / log(10)).round();
    } else {
      displayDigits =
          (log(viewModel.userSettingsDataProvider.exchangeRate.cents.toInt()) /
                  log(10))
              .round();
    }
    return Container(
        color: ProtonColors.white,
        height: double.infinity,
        child: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    viewModel.initialized == false
                        ? const CardLoading(
                            height: 50,
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                            margin: EdgeInsets.only(top: 4),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                        margin: const EdgeInsets.only(
                                            right: 4, top: 2),
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
                                        style: FontManager.body2Regular(
                                            ProtonColors.textHint))
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                        "$fiatCurrencySign${CommonHelper.formatDouble(ExchangeCalculator.getNotionalInFiatCurrency(viewModel.exchangeRate ?? viewModel.userSettingsDataProvider.exchangeRate, viewModel.amount.toInt()).abs(), displayDigits: displayDigits)}",
                                        style: FontManager
                                            .transactionHistoryAmountTitle(
                                                ProtonColors.textNorm)),
                                    const SizedBox(width: 4),
                                    Text(fiatCurrencyName,
                                        style: FontManager.body2Regular(
                                            ProtonColors.textNorm)),
                                  ],
                                ),
                                Text(
                                    ExchangeCalculator.getBitcoinUnitLabel(
                                        viewModel.userSettingsDataProvider
                                            .bitcoinUnit,
                                        viewModel.amount.toInt().abs()),
                                    style: FontManager.body2Regular(
                                        ProtonColors.textHint)),
                              ]),
                    const SizedBox(height: 20),
                    viewModel.isSend
                        ? buildSendInfo(context)
                        : buildReceiveInfo(context),
                    const Divider(
                      thickness: 0.2,
                      height: 1,
                    ),
                    if (viewModel.transactionTime != null)
                      TransactionHistoryItem(
                        title: S.of(context).trans_date,
                        content: CommonHelper.formatLocaleTime(
                            context, viewModel.transactionTime!),
                        backgroundColor: ProtonColors.white,
                        isLoading: viewModel.initialized == false,
                      ),
                    const Divider(
                      thickness: 0.2,
                      height: 1,
                    ),
                    TransactionHistoryItem(
                      title: S.of(context).trans_status,
                      content: viewModel.transactionTime != null
                          ? S.of(context).completed
                          : viewModel.isSend
                              ? S.of(context).in_progress_broadcasted
                              : S.of(context).in_progress_waiting_for_confirm,
                      contentColor: viewModel.transactionTime != null
                          ? ProtonColors.signalSuccess
                          : ProtonColors.signalError,
                      backgroundColor: ProtonColors.white,
                      isLoading: viewModel.initialized == false,
                    ),
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
                          content: viewModel.body,
                          backgroundColor: ProtonColors.white,
                          isLoading: viewModel.initialized == false,
                        ),
                        const Divider(
                          thickness: 0.2,
                          height: 1,
                        ),
                      ]),
                    viewModel.initialized == false
                        ? const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: defaultPadding),
                            child: CardLoading(
                              height: 50,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4)),
                              margin: EdgeInsets.only(top: 4),
                            ),
                          )
                        : viewModel.isEditing == false
                            ? GestureDetector(
                                onTap: () {
                                  viewModel.editMemo();
                                },
                                child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 10.0),
                                    padding:
                                        const EdgeInsets.all(defaultPadding),
                                    decoration: BoxDecoration(
                                        color: ProtonColors
                                            .transactionNoteBackground,
                                        borderRadius:
                                            BorderRadius.circular(32.0)),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(
                                            "assets/images/icon/ic_note.svg",
                                            fit: BoxFit.fill,
                                            width: 32,
                                            height: 32),
                                        const SizedBox(width: 10),
                                        viewModel.memoController.text.isNotEmpty
                                            ? Expanded(
                                                child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      S
                                                          .of(context)
                                                          .message_to_myself,
                                                      style: FontManager
                                                          .captionRegular(
                                                              ProtonColors
                                                                  .textHint)),
                                                  Row(children: [
                                                    Expanded(
                                                        child: Text(
                                                            viewModel
                                                                .memoController
                                                                .text,
                                                            style: FontManager
                                                                .body2Median(
                                                                    ProtonColors
                                                                        .textNorm)))
                                                  ]),
                                                ],
                                              ))
                                            : Expanded(
                                                child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      S
                                                          .of(context)
                                                          .message_to_myself,
                                                      style: FontManager
                                                          .captionRegular(
                                                              ProtonColors
                                                                  .textNorm)),
                                                  Text(
                                                      S
                                                          .of(context)
                                                          .trans_add_note,
                                                      style: FontManager
                                                          .body2Median(
                                                              ProtonColors
                                                                  .textHint)),
                                                ],
                                              )),
                                      ],
                                    )))
                            : Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 10.0),
                                child: TextFieldTextV2(
                                  labelText: S.of(context).message_to_myself,
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
                                  radius: 32,
                                ),
                              ),
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
                                "$fiatCurrencyName ${CommonHelper.formatDouble(ExchangeCalculator.getNotionalInFiatCurrency(viewModel.exchangeRate ?? viewModel.userSettingsDataProvider.exchangeRate, viewModel.fee.toInt()), displayDigits: displayDigits)}",
                            memo: ExchangeCalculator.getBitcoinUnitLabel(
                                viewModel.userSettingsDataProvider.bitcoinUnit,
                                viewModel.fee.toInt()),
                            backgroundColor: ProtonColors.white,
                            isLoading: viewModel.initialized == false,
                          ),
                          const Divider(
                            thickness: 0.2,
                            height: 1,
                          ),
                          TransactionHistoryItem(
                            title: S.of(context).trans_total,
                            content: viewModel.isSend
                                ? "$fiatCurrencyName ${CommonHelper.formatDouble(ExchangeCalculator.getNotionalInFiatCurrency(viewModel.exchangeRate ?? viewModel.userSettingsDataProvider.exchangeRate, viewModel.amount.toInt() - viewModel.fee.toInt()).abs(), displayDigits: displayDigits)}"
                                : "$fiatCurrencyName ${CommonHelper.formatDouble(ExchangeCalculator.getNotionalInFiatCurrency(viewModel.exchangeRate ?? viewModel.userSettingsDataProvider.exchangeRate, viewModel.amount.toInt() + viewModel.fee.toInt()).abs(), displayDigits: displayDigits)}",
                            memo: viewModel.isSend
                                ? ExchangeCalculator.getBitcoinUnitLabel(
                                    viewModel
                                        .userSettingsDataProvider.bitcoinUnit,
                                    (viewModel.amount.toInt() -
                                            viewModel.fee.toInt())
                                        .abs())
                                : ExchangeCalculator.getBitcoinUnitLabel(
                                    viewModel
                                        .userSettingsDataProvider.bitcoinUnit,
                                    viewModel.amount.toInt() +
                                        viewModel.fee.toInt()),
                            backgroundColor: ProtonColors.white,
                            isLoading: viewModel.initialized == false,
                          ),
                          const SizedBox(height: 20),
                          ButtonV5(
                              onPressed: () {
                                launchUrl(Uri.parse(
                                    "${appConfig.esploraWebpageUrl}search?q=${viewModel.txID}"));
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
    String yourEmail =
        WalletManager.getEmailFromWalletTransaction(viewModel.fromEmail);
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
                multiRecipient: false,
              )
            : Column(children: [
                for (TransactionInfoModel info in viewModel.recipients)
                  buildTransToInfo(
                    context,
                    email: info.toEmail.isNotEmpty ? info.toEmail : null,
                    bitcoinAddress: info.toBitcoinAddress,
                    amountInSatoshi: info.amountInSATS,
                    multiRecipient: viewModel.recipients.length > 1,
                  )
              ]),
        yourEmail.isNotEmpty
            ? TransactionHistoryItem(
                title: S.of(context).trans_from,
                content: "$yourEmail (You)",
                memo: "${viewModel.strWallet} - ${viewModel.strAccount}",
                backgroundColor: ProtonColors.white,
                isLoading: viewModel.initialized == false,
              )
            : TransactionHistoryItem(
                title: S.of(context).trans_from,
                content: "${viewModel.strWallet} - ${viewModel.strAccount}",
                backgroundColor: ProtonColors.white,
                isLoading: viewModel.initialized == false,
              ),
      ],
    );
  }

  Widget buildTransToInfo(
    BuildContext context, {
    String? email,
    String? bitcoinAddress,
    String? walletAccountName,
    int? amountInSatoshi,
    required bool multiRecipient,
  }) {
    return Column(children: [
      if (viewModel.exchangeRate != null && amountInSatoshi != null)
        TransactionHistorySendItem(
          content: email ?? bitcoinAddress ?? "",
          bitcoinAddress: bitcoinAddress ?? "",
          bitcoinAmount: multiRecipient
              ? BitcoinAmount(
                  amountInSatoshi: amountInSatoshi,
                  bitcoinUnit: viewModel.userSettingsDataProvider.bitcoinUnit,
                  exchangeRate: viewModel.exchangeRate!)
              : null,
          isLoading: viewModel.initialized == false,
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
            backgroundColor: ProtonColors.white,
            isLoading: viewModel.initialized == false,
          ),
          if (viewModel.isInternalTransaction == false && viewModel.initialized)
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
          bitcoinAmount: null,
          isLoading: viewModel.initialized == false,
        ),
      ],
    );
  }

  void showNetworkFee(BuildContext context) {
    showModalBottomSheet(
        context: context,
        backgroundColor: ProtonColors.white,
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
                              style: FontManager.body1Median(
                                  ProtonColors.textNorm)),
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
}
