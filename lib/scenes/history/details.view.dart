import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wallet/constants/app.config.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/bitcoin.amount.dart';
import 'package:wallet/helper/common.helper.dart';
import 'package:wallet/helper/exchange.caculator.dart';
import 'package:wallet/helper/extension/build.context.extension.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/models/transaction.info.model.dart';
import 'package:wallet/scenes/components/button.v5.dart';
import 'package:wallet/scenes/components/button.v6.dart';
import 'package:wallet/scenes/components/custom.card_loading.builder.dart';
import 'package:wallet/scenes/components/page.layout.v2.dart';
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
    return PageLayoutV2(
      title: context.local.trans_details,
      backgroundColor: ProtonColors.backgroundSecondary,
      child: buildNoHistory(context),
    );
  }

  Widget buildNoHistory(BuildContext context) {
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          !viewModel.initialized
              ? const CustomCardLoadingBuilder(
                  height: 50,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  margin: EdgeInsets.only(top: 4),
                ).build(context)
              : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  /// Row [icon | receive/send ]
                  Row(
                    children: [
                      viewModel.isSend
                          ? context.images.iconSend.svg(
                              fit: BoxFit.fill,
                              width: 32,
                              height: 32,
                            )
                          : context.images.iconReceive.svg(
                              fit: BoxFit.fill,
                              width: 32,
                              height: 32,
                            ),
                      SizedBoxes.box12,
                      Text(
                        viewModel.isSend
                            ? S.of(context).you_sent
                            : S.of(context).you_received,
                        style: ProtonStyles.body2Medium(
                          color: ProtonColors.textHint,
                        ),
                      )
                    ],
                  ),
                  SizedBoxes.box12,

                  /// Row [amount | currency]
                  Row(
                    children: [
                      viewModel.displayBalance
                          ? Text(
                              "$fiatCurrencySign${CommonHelper.formatDouble(ExchangeCalculator.getNotionalInFiatCurrency(viewModel.exchangeRate ?? viewModel.userSettingsDataProvider.exchangeRate, viewModel.amount.toInt()).abs(), displayDigits: displayDigits)}",
                              style: ProtonStyles.headlineHugeSemibold(
                                color: ProtonColors.textNorm,
                              ))
                          : Text("$fiatCurrencySign$hidedBalanceString",
                              style: ProtonStyles.headlineHugeSemibold(
                                color: ProtonColors.textNorm,
                              )),
                      const SizedBox(width: 8),
                      Text(
                        fiatCurrencyName,
                        style: ProtonStyles.body1Medium(
                          color: ProtonColors.textNorm,
                        ),
                      ),
                    ],
                  ),
                  SizedBoxes.box12,

                  /// Text [btc sats]
                  Text(
                    viewModel.displayBTCLabel,
                    style: ProtonStyles.body2Medium(
                      color: ProtonColors.textHint,
                      fontSize: 15,
                    ),
                  )
                ]),
          const SizedBox(height: 12),
          viewModel.isSend ? buildSendInfo(context) : buildReceiveInfo(context),
          const Divider(
            thickness: 0.2,
            height: 1,
          ),
          if (viewModel.transactionTime != null)
            TransactionHistoryItem(
              title: S.of(context).trans_date,
              content: CommonHelper.formatLocaleTime(
                  context, viewModel.transactionTime!),
              backgroundColor: ProtonColors.backgroundSecondary,
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
                backgroundColor: ProtonColors.backgroundSecondary,
                isLoading: !viewModel.initialized,
              ),
              const Divider(
                thickness: 0.2,
                height: 1,
              ),
            ]),
          !viewModel.initialized
              ? const CustomCardLoadingBuilder(
                  height: 50,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  margin: EdgeInsets.only(top: 4),
                ).build(context)
              : !viewModel.isEditing
                  ? GestureDetector(
                      onTap: viewModel.editMemo,
                      child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 10.0),
                          padding: const EdgeInsets.all(defaultPadding),
                          decoration: BoxDecoration(
                              color: ProtonColors.backgroundNorm,
                              borderRadius: BorderRadius.circular(32.0)),
                          child: Row(
                            children: [
                              context.images.iconNotes.svg(
                                fit: BoxFit.fill,
                                width: 32,
                                height: 32,
                              ),
                              const SizedBox(width: 10),
                              viewModel.memoController.text.isNotEmpty
                                  ? Expanded(
                                      child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(S.of(context).message_to_myself,
                                            style: ProtonStyles.captionRegular(
                                                color: ProtonColors.textHint)),
                                        Row(children: [
                                          Expanded(
                                              child: Text(
                                                  viewModel.memoController.text,
                                                  style:
                                                      ProtonStyles.body1Medium(
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
                                        Text(S.of(context).message_to_myself,
                                            style: ProtonStyles.captionRegular(
                                                color: ProtonColors.textNorm)),
                                        Text(S.of(context).trans_add_note,
                                            style: ProtonStyles.body2Medium(
                                                color: ProtonColors.textHint)),
                                      ],
                                    )),
                            ],
                          )))
                  : Container(
                      margin: const EdgeInsets.symmetric(vertical: 10.0),
                      child: TextFieldTextV2(
                        labelText: S.of(context).message_to_myself,
                        textController: viewModel.memoController,
                        myFocusNode: viewModel.memoFocusNode,
                        paddingSize: 7,
                        maxLines: null,
                        showCounterText: true,
                        maxLength: maxMemoTextCharSize,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(maxMemoTextCharSize)
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
                    style:
                        ProtonStyles.body2Medium(color: ProtonColors.textWeak)),
              ),
              iconColor: ProtonColors.textHint,
              collapsedIconColor: ProtonColors.textHint,
              onExpansionChanged: (isExpanded) {
                if (isExpanded) {
                  Future.delayed(const Duration(milliseconds: 300), () {
                    viewModel.scrollController.animateTo(
                      viewModel.scrollController.position.maxScrollExtent,
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
                        titleTooltip: S.of(context).trans_metwork_fee_desc,
                        content:
                            "$fiatCurrencyName ${CommonHelper.formatDouble(ExchangeCalculator.getNotionalInFiatCurrency(viewModel.exchangeRate ?? viewModel.userSettingsDataProvider.exchangeRate, viewModel.fee.toInt()), displayDigits: displayDigits)}",
                        memo: ExchangeCalculator.getBitcoinUnitLabel(
                            viewModel.userSettingsDataProvider.bitcoinUnit,
                            viewModel.fee.toInt()),
                        backgroundColor: ProtonColors.backgroundSecondary,
                        isLoading: !viewModel.initialized,
                      )
                    : TransactionHistoryItem(
                        title: S.of(context).trans_metwork_fee,
                        titleTooltip: S.of(context).trans_metwork_fee_desc,
                        content: "$fiatCurrencyName $hidedBalanceString",
                        memo: viewModel.hidedBitcoinAmountString,
                        backgroundColor: ProtonColors.backgroundSecondary,
                        isLoading: !viewModel.initialized,
                      ),
                const Divider(
                  thickness: 0.2,
                  height: 1,
                ),
                viewModel.displayBalance
                    ? TransactionHistoryItem(
                        title: S.of(context).trans_total,
                        content:
                            "$fiatCurrencyName ${CommonHelper.formatDouble(ExchangeCalculator.getNotionalInFiatCurrency(viewModel.exchangeRate ?? viewModel.userSettingsDataProvider.exchangeRate, viewModel.amountWithFee.toInt()).abs(), displayDigits: displayDigits)}",
                        memo: ExchangeCalculator.getBitcoinUnitLabel(
                            viewModel.userSettingsDataProvider.bitcoinUnit,
                            viewModel.amountWithFee.toInt()),
                        backgroundColor: ProtonColors.backgroundSecondary,
                        isLoading: !viewModel.initialized,
                      )
                    : TransactionHistoryItem(
                        title: S.of(context).trans_total,
                        content: "$fiatCurrencyName $hidedBalanceString",
                        memo: viewModel.hidedBitcoinAmountString,
                        backgroundColor: ProtonColors.backgroundSecondary,
                        isLoading: !viewModel.initialized,
                      ),
                const SizedBox(height: 20),
                ButtonV5(
                    onPressed: () {
                      launchUrl(
                          Uri.parse(
                              "${appConfig.esploraWebpageUrl}search?q=${viewModel.frbTransactionDetails.txid}"),
                          mode: LaunchMode.externalApplication);
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
    );
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
            backgroundColor: ProtonColors.interActionWeakDisable,
            borderColor: ProtonColors.interActionWeakDisable,
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
          ? ProtonColors.notificationSuccess
          : ProtonColors.notificationError,
      backgroundColor: ProtonColors.backgroundSecondary,
      isLoading: !viewModel.initialized,
    );
  }

  Widget buildSendInfo(BuildContext context) {
    final yourEmail = WalletManager.getEmailFromWalletTransaction(
      viewModel.fromEmail,
    );
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
                backgroundColor: ProtonColors.backgroundSecondary,
                isLoading: !viewModel.initialized,
              )
            : TransactionHistoryItem(
                title: S.of(context).trans_from,
                content: "${viewModel.walletName} - ${viewModel.accountName}",
                backgroundColor: ProtonColors.backgroundSecondary,
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
            backgroundColor: ProtonColors.backgroundSecondary,
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
                child: context.images.iconPencil.svg(
                  fit: BoxFit.fill,
                  width: 40,
                  height: 40,
                ),
              ),
            ),
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
