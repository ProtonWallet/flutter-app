import 'dart:math';

import 'package:card_loading/card_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wallet/constants/app.config.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/bitcoin.amount.dart';
import 'package:wallet/helper/common.helper.dart';
import 'package:wallet/helper/exchange.caculator.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/models/transaction.info.model.dart';
import 'package:wallet/scenes/components/button.v5.dart';
import 'package:wallet/scenes/components/button.v6.dart';
import 'package:wallet/scenes/components/close.button.v1.dart';
import 'package:wallet/scenes/components/custom.header.dart';
import 'package:wallet/scenes/components/textfield.text.v2.dart';
import 'package:wallet/scenes/components/transaction.history.item.dart';
import 'package:wallet/scenes/components/transaction.history.send.item.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/history/bottom.sheet/edit.sender.dart';
import 'package:wallet/scenes/history/details.viewmodel.dart';

class HistoryDetailView extends ViewBase<HistoryDetailViewModel> {
  const HistoryDetailView(HistoryDetailViewModel viewModel)
      : super(viewModel, const Key("HistoryDetailView"));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: buildNoHistory(context, viewModel)),
    );
  }

  Widget buildNoHistory(
    BuildContext context,
    HistoryDetailViewModel viewModel,
  ) {
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
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
        color: ProtonColors.white,
      ),
      child: SafeArea(
        child: Column(
          children: [
            CustomHeader(
              title: S.of(context).transaction_detail,
              buttonDirection: AxisDirection.left,
              button: CloseButtonV1(
                  backgroundColor: ProtonColors.backgroundNorm,
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: viewModel.scrollController,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      !viewModel.initialized
                          ? const CardLoading(
                              height: 50,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4)),
                              margin: EdgeInsets.only(top: 4),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                  Row(
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(
                                            right: 4, top: 2),
                                        padding: const EdgeInsets.all(2.0),
                                        child: viewModel.isSend
                                            ? Assets.images.icon.send.svg(
                                                fit: BoxFit.fill,
                                                width: 25,
                                                height: 25,
                                              )
                                            : Assets.images.icon.receive.svg(
                                                fit: BoxFit.fill,
                                                width: 25,
                                                height: 25,
                                              ),
                                      ),
                                      Text(
                                          viewModel.isSend
                                              ? S.of(context).you_sent
                                              : S.of(context).you_received,
                                          style: ProtonStyles.body2Regular(
                                              color: ProtonColors.textHint))
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      viewModel.displayBalance
                                          ? Text(
                                              "$fiatCurrencySign${CommonHelper.formatDouble(ExchangeCalculator.getNotionalInFiatCurrency(viewModel.exchangeRate ?? viewModel.userSettingsDataProvider.exchangeRate, viewModel.amount.toInt()).abs(), displayDigits: displayDigits)}",
                                              style:
                                                  ProtonWalletStyles.textAmount(
                                                color: ProtonColors.textNorm,
                                                fontSize: 32,
                                              ))
                                          : Text(
                                              "$fiatCurrencySign$hidedBalanceString",
                                              style:
                                                  ProtonWalletStyles.textAmount(
                                                color: ProtonColors.textNorm,
                                                fontSize: 32,
                                              )),
                                      const SizedBox(width: 4),
                                      Text(fiatCurrencyName,
                                          style: ProtonStyles.body2Regular(
                                              color: ProtonColors.textNorm)),
                                    ],
                                  ),
                                  viewModel.displayBalance
                                      ? Text(
                                          ExchangeCalculator
                                              .getBitcoinUnitLabel(
                                                  viewModel
                                                      .userSettingsDataProvider
                                                      .bitcoinUnit,
                                                  viewModel.amount
                                                      .toInt()
                                                      .abs()),
                                          style: ProtonStyles.body2Regular(
                                              color: ProtonColors.textHint))
                                      : Text(getHidedBitcoinAmountString(),
                                          style: ProtonStyles.body2Regular(
                                              color: ProtonColors.textHint)),
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
                          isLoading: !viewModel.initialized,
                        ),
                      const Divider(
                        thickness: 0.2,
                        height: 1,
                      ),
                      buildTransactionStatusWithBoost(context),
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
                            isLoading: !viewModel.initialized,
                          ),
                          const Divider(
                            thickness: 0.2,
                            height: 1,
                          ),
                        ]),
                      !viewModel.initialized
                          ? const CardLoading(
                              height: 50,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4)),
                              margin: EdgeInsets.only(top: 4),
                            )
                          : !viewModel.isEditing
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
                                          color: ProtonColors.backgroundNorm,
                                          borderRadius:
                                              BorderRadius.circular(32.0)),
                                      child: Row(
                                        children: [
                                          Assets.images.icon.icNote.svg(
                                              fit: BoxFit.fill,
                                              width: 32,
                                              height: 32),
                                          const SizedBox(width: 10),
                                          viewModel.memoController.text
                                                  .isNotEmpty
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
                                                        style: ProtonStyles
                                                            .captionRegular(
                                                                color: ProtonColors
                                                                    .textHint)),
                                                    Row(children: [
                                                      Expanded(
                                                          child: Text(
                                                              viewModel
                                                                  .memoController
                                                                  .text,
                                                              style: ProtonStyles
                                                                  .body2Medium(
                                                                      color: ProtonColors
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
                                                        style: ProtonStyles
                                                            .captionRegular(
                                                                color: ProtonColors
                                                                    .textNorm)),
                                                    Text(
                                                        S
                                                            .of(context)
                                                            .trans_add_note,
                                                        style: ProtonStyles
                                                            .body2Medium(
                                                                color: ProtonColors
                                                                    .textHint)),
                                                  ],
                                                )),
                                        ],
                                      )))
                              : Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 10.0),
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
                          title: Transform.translate(
                            offset: const Offset(-16, 0),
                            child: Text(S.of(context).view_more,
                                style: ProtonStyles.body2Medium(
                                    color: ProtonColors.textWeak)),
                          ),
                          iconColor: ProtonColors.textHint,
                          collapsedIconColor: ProtonColors.textHint,
                          onExpansionChanged: (isExpanded) {
                            if (isExpanded) {
                              Future.delayed(const Duration(milliseconds: 300),
                                  () {
                                viewModel.scrollController.animateTo(
                                  viewModel.scrollController.position
                                      .maxScrollExtent,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                              });
                            }
                          },
                          children: [
                            viewModel.displayBalance
                                ? TransactionHistoryItem(
                                    title: S.of(context).trans_metwork_fee,
                                    titleTooltip:
                                        S.of(context).trans_metwork_fee_desc,
                                    content:
                                        "$fiatCurrencyName ${CommonHelper.formatDouble(ExchangeCalculator.getNotionalInFiatCurrency(viewModel.exchangeRate ?? viewModel.userSettingsDataProvider.exchangeRate, viewModel.fee.toInt()), displayDigits: displayDigits)}",
                                    memo:
                                        ExchangeCalculator.getBitcoinUnitLabel(
                                            viewModel.userSettingsDataProvider
                                                .bitcoinUnit,
                                            viewModel.fee.toInt()),
                                    backgroundColor: ProtonColors.white,
                                    isLoading: !viewModel.initialized,
                                  )
                                : TransactionHistoryItem(
                                    title: S.of(context).trans_metwork_fee,
                                    titleTooltip:
                                        S.of(context).trans_metwork_fee_desc,
                                    content:
                                        "$fiatCurrencyName $hidedBalanceString",
                                    memo: getHidedBitcoinAmountString(),
                                    backgroundColor: ProtonColors.white,
                                    isLoading: !viewModel.initialized,
                                  ),
                            const Divider(
                              thickness: 0.2,
                              height: 1,
                            ),
                            viewModel.displayBalance
                                ? TransactionHistoryItem(
                                    title: S.of(context).trans_total,
                                    content: viewModel.isSend
                                        ? "$fiatCurrencyName ${CommonHelper.formatDouble(ExchangeCalculator.getNotionalInFiatCurrency(viewModel.exchangeRate ?? viewModel.userSettingsDataProvider.exchangeRate, viewModel.amount.toInt() - viewModel.fee.toInt()).abs(), displayDigits: displayDigits)}"
                                        : "$fiatCurrencyName ${CommonHelper.formatDouble(ExchangeCalculator.getNotionalInFiatCurrency(viewModel.exchangeRate ?? viewModel.userSettingsDataProvider.exchangeRate, viewModel.amount.toInt() + viewModel.fee.toInt()).abs(), displayDigits: displayDigits)}",
                                    memo: viewModel.isSend
                                        ? ExchangeCalculator
                                            .getBitcoinUnitLabel(
                                                viewModel
                                                    .userSettingsDataProvider
                                                    .bitcoinUnit,
                                                (viewModel.amount.toInt() -
                                                        viewModel.fee.toInt())
                                                    .abs())
                                        : ExchangeCalculator
                                            .getBitcoinUnitLabel(
                                                viewModel
                                                    .userSettingsDataProvider
                                                    .bitcoinUnit,
                                                viewModel.amount.toInt() +
                                                    viewModel.fee.toInt()),
                                    backgroundColor: ProtonColors.white,
                                    isLoading: !viewModel.initialized,
                                  )
                                : TransactionHistoryItem(
                                    title: S.of(context).trans_total,
                                    content:
                                        "$fiatCurrencyName $hidedBalanceString",
                                    memo: getHidedBitcoinAmountString(),
                                    backgroundColor: ProtonColors.white,
                                    isLoading: !viewModel.initialized,
                                  ),
                            const SizedBox(height: 20),
                            ButtonV5(
                                onPressed: () {
                                  launchUrl(Uri.parse(
                                      "${appConfig.esploraWebpageUrl}search?q=${viewModel.frbTransactionDetails.txid}"));
                                },
                                text: S.of(context).view_on_blockstream,
                                width: MediaQuery.of(context).size.width,
                                backgroundColor: ProtonColors.protonBlue,
                                textStyle: ProtonStyles.body1Medium(
                                    color: ProtonColors.textInverted),
                                height: 55),
                            const SizedBox(height: 20),
                          ])
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getHidedBitcoinAmountString() {
    return "$hidedBalanceString ${viewModel.userSettingsDataProvider.bitcoinUnit.name.toUpperCase() != "MBTC" ? viewModel.userSettingsDataProvider.bitcoinUnit.name.toUpperCase() : "mBTC"}";
  }

  Widget buildTransactionStatusWithBoost(BuildContext context) {
    if (viewModel.initialized &&
        viewModel.isSend &&
        viewModel.transactionTime == null) {
      return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        buildTransactionStatus(context),
        Expanded(
          child: ButtonV6(
            onPressed: () async {
              viewModel.move(NavID.rbf);
            },
            text: S.of(context).boost_priority,
            width: 160,
            textStyle: ProtonStyles.body1Medium(color: ProtonColors.textNorm),
            backgroundColor: ProtonColors.interActionWeak,
            borderColor: ProtonColors.interActionWeak,
            height: 55,
            alignment: Alignment.centerRight,
          ),
        ),
      ]);
    }
    return buildTransactionStatus(context);
  }

  Widget buildTransactionStatus(BuildContext context) {
    return TransactionHistoryItem(
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
      isLoading: !viewModel.initialized,
    );
  }

  Widget buildSendInfo(BuildContext context) {
    final String yourEmail =
        WalletManager.getEmailFromWalletTransaction(viewModel.fromEmail);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
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
                    : "",
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
                memo: "${viewModel.walletName} - ${viewModel.accountName}",
                backgroundColor: ProtonColors.white,
                isLoading: !viewModel.initialized,
              )
            : TransactionHistoryItem(
                title: S.of(context).trans_from,
                content: "${viewModel.walletName} - ${viewModel.accountName}",
                backgroundColor: ProtonColors.white,
                isLoading: !viewModel.initialized,
              ),
      ],
    );
  }

  Widget buildTransToInfo(
    BuildContext context, {
    required bool multiRecipient,
    String? email,
    String? bitcoinAddress,
    String? walletAccountName,
    int? amountInSatoshi,
  }) {
    return Column(children: [
      if (viewModel.exchangeRate != null)
        TransactionHistorySendItem(
          content: email ?? bitcoinAddress ?? "",
          bitcoinAddress: bitcoinAddress ?? "",
          bitcoinAmount: multiRecipient
              ? BitcoinAmount(
                  amountInSatoshi: amountInSatoshi ?? 0,
                  bitcoinUnit: viewModel.userSettingsDataProvider.bitcoinUnit,
                  exchangeRate: viewModel.exchangeRate!)
              : null,
          isLoading: !viewModel.initialized,
          displayBalance: viewModel.displayBalance,
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
      children: [
        Stack(children: [
          TransactionHistoryItem(
            title: S.of(context).trans_from,
            content: viewModel.fromEmail.isNotEmpty
                ? WalletManager.getEmailFromWalletTransaction(
                    viewModel.fromEmail)
                : viewModel.isInternalTransaction
                    ? "Anonymous sender"
                    : "Unknown",
            backgroundColor: ProtonColors.white,
            isLoading: !viewModel.initialized,
          ),
          if (!viewModel.isInternalTransaction && viewModel.initialized)
            Positioned(
                top: 20,
                right: defaultPadding,
                child: GestureDetector(
                    onTap: () {
                      EditSenderSheet.show(context, viewModel);
                    },
                    child: Assets.images.icon.editUnknown.svg(
                      fit: BoxFit.fill,
                      width: 40,
                      height: 40,
                    ))),
        ]),
        const Divider(
          thickness: 0.2,
          height: 1,
        ),
        for (final selfBitcoinAddress in viewModel.selfBitcoinAddresses)
          TransactionHistorySendItem(
            content: viewModel.getToEmail(),
            walletAccountName: viewModel.getWalletAccountName(),
            bitcoinAddress: selfBitcoinAddress,
            isLoading: !viewModel.initialized,
            displayBalance: viewModel.displayBalance,
          ),
      ],
    );
  }
}
