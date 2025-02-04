import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:card_loading/card_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/avatar.color.helper.dart';
import 'package:wallet/helper/bitcoin.amount.dart';
import 'package:wallet/helper/common.helper.dart';
import 'package:wallet/helper/exchange.caculator.dart';
import 'package:wallet/helper/extension/enum.extension.dart';
import 'package:wallet/helper/fiat.currency.dart';
import 'package:wallet/helper/local_toast.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/scenes/components/back.button.v1.dart';
import 'package:wallet/scenes/components/button.v5.dart';
import 'package:wallet/scenes/components/close.button.v1.dart';
import 'package:wallet/scenes/components/custom.header.dart';
import 'package:wallet/scenes/components/custom.loading.dart';
import 'package:wallet/scenes/components/dropdown.button.v2.dart';
import 'package:wallet/scenes/components/dropdown.currency.v1.dart';
import 'package:wallet/scenes/components/flying.animation.dart';
import 'package:wallet/scenes/components/flying.background.animation.dart';
import 'package:wallet/scenes/components/protonmail.autocomplete.dart';
import 'package:wallet/scenes/components/recipient.detail.dart';
import 'package:wallet/scenes/components/textfield.send.btc.v2.dart';
import 'package:wallet/scenes/components/textfield.text.v2.dart';
import 'package:wallet/scenes/components/transaction.history.item.v2.dart';
import 'package:wallet/scenes/components/transaction.history.send.item.dart';
import 'package:wallet/scenes/components/wallet.account.dropdown.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/send/send.viewmodel.dart';

class SendView extends ViewBase<SendViewModel> {
  const SendView(SendViewModel viewModel)
      : super(viewModel, const Key("SendView"));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
          color: ProtonColors.white,
        ),
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Column(children: [
            CustomHeader(
              title: getTitleString(context),
              buttonDirection: AxisDirection.left,
              button: getLeadingButton(context),
            ),
            Expanded(
              child: SafeArea(child: buildMainView(context)),
            ),
          ]),
        ),
      ),
    );
  }

  String getTitleString(BuildContext context) {
    if (viewModel.sendFlowStatus == SendFlowStatus.reviewTransaction) {
      return S.of(context).review_your_transaction;
    }
    if (viewModel.sendFlowStatus == SendFlowStatus.addRecipient) {
      return S.of(context).send_step_who_are_you_sending_to;
    }
    if (viewModel.sendFlowStatus == SendFlowStatus.editAmount) {
      return S.of(context).send_step_how_much_are_you_sending;
    }
    return "";
  }

  Widget getLeadingButton(BuildContext context) {
    if ([SendFlowStatus.addRecipient, SendFlowStatus.sendSuccess]
        .contains(viewModel.sendFlowStatus)) {
      return CloseButtonV1(
        backgroundColor: ProtonColors.backgroundNorm,
        onPressed: () {
          Navigator.of(context).pop();
        },
      );
    }
    if (viewModel.sendFlowStatus == SendFlowStatus.broadcasting) {
      return const SizedBox();
    }
    return BackButtonV1(
      backgroundColor: ProtonColors.backgroundNorm,
      onPressed: () {
        if (viewModel.sendFlowStatus == SendFlowStatus.reviewTransaction) {
          viewModel.updatePageStatus(SendFlowStatus.editAmount);
        } else {
          viewModel.updatePageStatus(SendFlowStatus.addRecipient);
        }
      },
    );
  }

  Widget buildMainView(BuildContext context) {
    switch (viewModel.sendFlowStatus) {
      case SendFlowStatus.addRecipient:
        return buildAddRecipient(context);
      case SendFlowStatus.editAmount:
        return buildEditAmount(context);
      case SendFlowStatus.reviewTransaction:
        return buildReviewContent(context);
      case SendFlowStatus.broadcasting:
        return buildBroadcastingContent(context);
      case SendFlowStatus.sendSuccess:
        return buildSuccessContent(context);
    }
  }

  Widget buildEditAmount(BuildContext context) {
    return ColoredBox(
        color: ProtonColors.white,
        child: Column(children: [
          Expanded(
              child: SingleChildScrollView(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: defaultPadding),
                      child: Center(
                          child: Column(children: [
                        const SizedBox(height: 20),
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                viewModel.bitcoinBase
                                    ? ExchangeCalculator.getBitcoinUnitLabel(
                                        viewModel.fiatCurrencyNotifier.value
                                                .bitcoinCurrency?.bitcoinUnit ??
                                            BitcoinUnit.btc,
                                        viewModel.balance)
                                    : "${viewModel.userSettingsDataProvider.getFiatCurrencyName(fiatCurrency: viewModel.exchangeRate.fiatCurrency)} ${ExchangeCalculator.getNotionalInFiatCurrency(viewModel.exchangeRate, viewModel.balance).toStringAsFixed(ExchangeCalculator.getDisplayDigit(viewModel.exchangeRate))} ${S.of(context).available_bitcoin_value}",
                                style: ProtonStyles.captionRegular(
                                    color: ProtonColors.textWeak),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: viewModel.sendAll,
                                child: Text(
                                  S.of(context).send_all,
                                  style: ProtonStyles.captionMedium(
                                    color: ProtonColors.protonBlue,
                                  ),
                                ),
                              )
                            ]),
                        Row(children: [
                          Expanded(
                            child: TextFieldSendBTCV2(
                              bitcoinBase: viewModel.bitcoinBase,
                              backgroundColor: ProtonColors.white,
                              labelText: S.of(context).amount,
                              hintText: 0.toStringAsFixed(
                                  viewModel.amountDisplayDigit),
                              textController: viewModel.amountTextController,
                              myFocusNode: viewModel.amountFocusNode,
                              exchangeRate: viewModel.exchangeRate,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d*$'))
                              ],
                              bitcoinUnit: viewModel.bitcoinBase
                                  ? viewModel.fiatCurrencyNotifier.value
                                          .bitcoinCurrency?.bitcoinUnit ??
                                      BitcoinUnit.btc
                                  : viewModel
                                      .userSettingsDataProvider.bitcoinUnit,
                              validation: (String value) {
                                return "";
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Container(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: DropdownCurrencyV1(
                                  width: 80,
                                  padding: const EdgeInsets.only(
                                    left: 10,
                                    right: 10,
                                  ),
                                  textStyle: ProtonStyles.captionMedium(
                                      color: ProtonColors.textNorm),
                                  backgroundColor: ProtonColors.backgroundNorm,
                                  items: fiatCurrenciesWithBitcoin,
                                  itemsText: fiatCurrenciesWithBitcoin
                                      .map((v) => v.toFullName())
                                      .toList(),
                                  itemsTextForDisplay: fiatCurrenciesWithBitcoin
                                      .map((v) => v.toShortName())
                                      .toList(),
                                  itemsLeadingIcons: fiatCurrenciesWithBitcoin
                                      .map((v) => v.getIcon())
                                      .toList(),
                                  valueNotifier:
                                      viewModel.fiatCurrencyNotifier)),
                        ]),
                        if (viewModel.recipients.isNotEmpty)
                          Row(children: [
                            Expanded(
                                child: Container(
                              margin:
                                  const EdgeInsets.only(top: 20, bottom: 10),
                              width: MediaQuery.of(context).size.width,
                              child: Text(
                                S.of(context).recipients,
                                style: ProtonStyles.captionMedium(
                                    color: ProtonColors.textNorm),
                              ),
                            )),
                            GestureDetector(
                              onTap: () {
                                viewModel.updatePageStatus(
                                    SendFlowStatus.addRecipient);
                              },
                              child: Text(
                                S.of(context).edit_recipient,
                                style: ProtonStyles.body2Medium(
                                    color: ProtonColors.protonBlue),
                              ),
                            ),
                          ]),
                        for (int index = 0;
                            index < viewModel.recipients.length;
                            index++)
                          RecipientDetail(
                            email: viewModel.recipients[index].email,
                            bitcoinAddress: viewModel.bitcoinAddresses
                                    .containsKey(
                                        viewModel.recipients[index].email)
                                ? viewModel.bitcoinAddresses[
                                        viewModel.recipients[index].email] ??
                                    ""
                                : "",
                            isSignatureInvalid:
                                viewModel.bitcoinAddressesInvalidSignature[
                                        viewModel.recipients[index].email] ??
                                    false,
                            isSelfBitcoinAddress: viewModel.selfBitcoinAddresses
                                .contains(viewModel.bitcoinAddresses[
                                        viewModel.recipients[index].email] ??
                                    ""),
                            closeCallback: () {
                              viewModel.removeRecipient(index);
                            },
                            canBeClosed: !viewModel.isLoadingBvE,
                            amountController: viewModel.recipients.length > 1
                                ? viewModel.recipients[index].amountController
                                : null,
                            amountFocusNode: viewModel.recipients.length > 1
                                ? viewModel.recipients[index].focusNode
                                : null,
                            showAvatar: false,
                            avatarColor:
                                AvatarColorHelper.getAvatarBackgroundColor(
                                    index),
                            avatarTextColor:
                                AvatarColorHelper.getAvatarTextColor(index),
                          ),
                        const SizedBox(height: 20),
                        if (viewModel.errorMessage.isNotEmpty)
                          Text(
                            viewModel.errorMessage,
                            style: ProtonStyles.body2Medium(
                                color: ProtonColors.signalError),
                          ),
                      ]))))),
          if (MediaQuery.of(context).viewInsets.bottom < 80)
            Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                margin: const EdgeInsets.symmetric(
                    horizontal: defaultButtonPadding),
                child: ButtonV5(
                    onPressed: () {
                      viewModel
                          .updatePageStatus(SendFlowStatus.reviewTransaction);
                    },
                    enable: viewModel.validRecipientCount() > 0 &&
                        viewModel.amountTextController.text.isNotEmpty,
                    text: S.of(context).review_transaction,
                    width: MediaQuery.of(context).size.width,
                    backgroundColor: ProtonColors.protonBlue,
                    textStyle: ProtonStyles.body1Medium(
                        color: ProtonColors.textInverted),
                    height: 55)),
        ]));
  }

  double getTotalAmountInFiatCurrency() {
    double totalAmountInFiatCurrency = 0;
    for (ProtonRecipient protonRecipient in viewModel.recipients) {
      if (protonRecipient.amountController.text.isNotEmpty) {
        double amount = 0.0;
        try {
          amount = double.parse(protonRecipient.amountController.text);
        } catch (e) {
          amount = 0.0;
        }
        totalAmountInFiatCurrency += amount;
      }
    }
    return totalAmountInFiatCurrency;
  }

  int getTotalAmountInSATS() {
    int totalAmountInSATS = 0;
    for (ProtonRecipient protonRecipient in viewModel.recipients) {
      totalAmountInSATS += protonRecipient.amountInSATS ?? 0;
    }
    return totalAmountInSATS;
  }

  Widget buildReviewContent(BuildContext context) {
    int estimatedFee = 0;
    switch (viewModel.userTransactionFeeMode) {
      case TransactionFeeMode.highPriority:
        estimatedFee = viewModel.estimatedFeeInSATHighPriority;
      case TransactionFeeMode.medianPriority:
        estimatedFee = viewModel.estimatedFeeInSATMedianPriority;
      case TransactionFeeMode.lowPriority:
        estimatedFee = viewModel.estimatedFeeInSATLowPriority;
    }
    return ColoredBox(
        color: ProtonColors.white,
        child: Column(children: [
          Expanded(
              child: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                const SizedBox(height: 40),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: defaultPadding),
                  child: getTransactionValueWidget(context),
                ),
                const SizedBox(height: 20),
                if (viewModel.recipients.isNotEmpty)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: defaultPadding),
                    child: Row(children: [
                      Expanded(
                          child: Container(
                        margin: const EdgeInsets.only(top: 20, bottom: 10),
                        width: MediaQuery.of(context).size.width,
                        child: Text(
                          S.of(context).recipients,
                          style: ProtonStyles.captionMedium(
                              color: ProtonColors.textNorm),
                        ),
                      )),
                      GestureDetector(
                        onTap: () {
                          viewModel.updatePageStatus(SendFlowStatus.editAmount);
                        },
                        child: Text(
                          S.of(context).edit_recipient,
                          style: ProtonStyles.body2Medium(
                            color: ProtonColors.protonBlue,
                          ),
                        ),
                      ),
                    ]),
                  ),
                for (final protonRecipient in viewModel.recipients)
                  if (viewModel.bitcoinAddresses
                          .containsKey(protonRecipient.email) &&
                      viewModel.bitcoinAddresses[protonRecipient.email]! !=
                          "" &&
                      !viewModel.selfBitcoinAddresses.contains(
                          viewModel.bitcoinAddresses[protonRecipient.email] ??
                              ""))
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: defaultPadding),
                      child: Column(children: [
                        TransactionHistorySendItem(
                          content: protonRecipient.email,
                          bitcoinAddress: viewModel
                                  .bitcoinAddresses[protonRecipient.email] ??
                              "",
                          bitcoinAmount: viewModel.recipients.length > 1
                              ? BitcoinAmount(
                                  amountInSatoshi:
                                      protonRecipient.amountInSATS ?? 0,
                                  bitcoinUnit: viewModel.bitcoinBase
                                      ? viewModel.fiatCurrencyNotifier.value
                                              .bitcoinCurrency?.bitcoinUnit ??
                                          BitcoinUnit.btc
                                      : viewModel
                                          .userSettingsDataProvider.bitcoinUnit,
                                  exchangeRate: viewModel.exchangeRate)
                              : null,
                        ),
                        const Divider(
                          thickness: 0.2,
                          height: 1,
                        ),
                      ]),
                    ),
                if (viewModel.hasEmailIntegrationRecipient)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: defaultPadding),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Text(S.of(context).email_integration,
                              style: ProtonStyles.body2Medium(
                                  color: ProtonColors.textWeak)),
                          DropdownButtonV2(
                            width: MediaQuery.of(context).size.width,
                            labelText: S.of(context).send_from_email,
                            title: S.of(context).choose_your_email,
                            items: viewModel.userAddresses,
                            itemsText: viewModel.userAddresses
                                .map((e) => e.email)
                                .toList(),
                            valueNotifier: viewModel.userAddressValueNotifier,
                            border:
                                Border.all(color: ProtonColors.interActionWeak),
                            padding: const EdgeInsets.only(
                                left: defaultPadding,
                                right: 8,
                                top: 12,
                                bottom: 12),
                          ),
                        ]),
                  ),
                if (viewModel.hasEmailIntegrationRecipient)
                  !viewModel.isEditingEmailBody
                      ? Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 5.0,
                            horizontal: 16,
                          ),
                          padding: const EdgeInsets.all(defaultPadding),
                          decoration: BoxDecoration(
                              color: ProtonColors.backgroundNorm,
                              borderRadius: BorderRadius.circular(40.0)),
                          child: Row(
                            children: [
                              Assets.images.icon.icMessage
                                  .svg(fit: BoxFit.fill, width: 32, height: 32),
                              const SizedBox(width: 10),
                              GestureDetector(
                                  onTap: viewModel.editEmailBody,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (viewModel
                                          .emailBodyController.text.isNotEmpty)
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                defaultPadding * 6 -
                                                10,
                                            child: Flex(
                                                direction: Axis.horizontal,
                                                children: [
                                                  Flexible(
                                                      child: Text(
                                                          viewModel
                                                              .emailBodyController
                                                              .text,
                                                          style: ProtonStyles
                                                              .body2Medium(
                                                                  color: ProtonColors
                                                                      .textNorm)))
                                                ])),
                                      Text(
                                          S
                                              .of(context)
                                              .message_to_recipient_optional(
                                                  viewModel
                                                      .validRecipientCount()),
                                          style: ProtonStyles.body2Medium(
                                              color: ProtonColors.textHint)),
                                    ],
                                  ))
                            ],
                          ))
                      : Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 5.0,
                            horizontal: 16,
                          ),
                          child: TextFieldTextV2(
                            labelText: S
                                .of(context)
                                .message_to_recipient_optional(
                                    viewModel.validRecipientCount()),
                            textController: viewModel.emailBodyController,
                            myFocusNode: viewModel.emailBodyFocusNode,
                            paddingSize: 7,
                            maxLines: null,
                            maxLength: maxMemoTextCharSize,
                            showCounterText: true,
                            scrollPadding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom +
                                        100),
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(
                                  maxMemoTextCharSize)
                            ],
                            validation: (String value) {
                              return "";
                            },
                          ),
                        ),
                if (viewModel.hasEmailIntegrationRecipient)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: defaultPadding),
                    child: Divider(
                      thickness: 0.2,
                      height: 1,
                    ),
                  ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: defaultPadding),
                  child: TransactionHistoryItemV2(
                    title: S.of(context).trans_metwork_fee,
                    titleTooltip: S.of(context).trans_metwork_fee_desc,
                    titleOptionsCallback: () {
                      showSelectTransactionFeeMode(context, viewModel);
                    },
                    backgroundColor: ProtonColors.white,
                    content: AnimatedFlipCounter(
                      duration: const Duration(milliseconds: 500),
                      value: ExchangeCalculator.getNotionalInFiatCurrency(
                          viewModel.exchangeRate, estimatedFee),
                      thousandSeparator: ",",
                      prefix:
                          "${viewModel.userSettingsDataProvider.getFiatCurrencyName(fiatCurrency: viewModel.exchangeRate.fiatCurrency)} ",
                      fractionDigits: ExchangeCalculator.getDisplayDigit(
                          viewModel.exchangeRate),
                      textStyle: ProtonStyles.body2Medium(
                          color: ProtonColors.textNorm),
                    ),
                    memo: ExchangeCalculator.getBitcoinUnitLabelWidget(
                        viewModel.bitcoinBase
                            ? viewModel.fiatCurrencyNotifier.value
                                    .bitcoinCurrency?.bitcoinUnit ??
                                BitcoinUnit.btc
                            : viewModel.userSettingsDataProvider.bitcoinUnit,
                        estimatedFee,
                        textStyle: ProtonStyles.body2Regular(
                            color: ProtonColors.textHint)),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: defaultPadding),
                  child: Divider(
                    thickness: 0.2,
                    height: 1,
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: defaultPadding),
                  child: getTransactionTotalValueWidget(
                      context, viewModel, estimatedFee),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: defaultPadding),
                  child: Divider(
                    thickness: 0.2,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 10),
                !viewModel.isEditingMemo
                    ? Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 5.0,
                          horizontal: 16,
                        ),
                        padding: const EdgeInsets.all(defaultPadding),
                        decoration: BoxDecoration(
                            color: ProtonColors.backgroundNorm,
                            borderRadius: BorderRadius.circular(40.0)),
                        child: Row(
                          children: [
                            Assets.images.icon.icNote
                                .svg(fit: BoxFit.fill, width: 32, height: 32),
                            const SizedBox(width: 10),
                            GestureDetector(
                                onTap: viewModel.editMemo,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (viewModel
                                        .memoTextController.text.isNotEmpty)
                                      SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              defaultPadding * 6 -
                                              10,
                                          child: Flex(
                                              direction: Axis.horizontal,
                                              children: [
                                                Flexible(
                                                    child: Text(
                                                        viewModel
                                                            .memoTextController
                                                            .text,
                                                        style: ProtonStyles
                                                            .body2Medium(
                                                                color: ProtonColors
                                                                    .textNorm)))
                                              ])),
                                    Text(S.of(context).message_to_myself,
                                        style: ProtonStyles.body2Medium(
                                            color: ProtonColors.textHint)),
                                  ],
                                ))
                          ],
                        ))
                    : Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 5.0,
                          horizontal: 16,
                        ),
                        child: TextFieldTextV2(
                          labelText: S.of(context).message_to_myself,
                          textController: viewModel.memoTextController,
                          myFocusNode: viewModel.memoFocusNode,
                          paddingSize: 7,
                          maxLines: null,
                          maxLength: maxMemoTextCharSize,
                          showCounterText: true,
                          scrollPadding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom +
                                  100),
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(
                                maxMemoTextCharSize)
                          ],
                          validation: (String value) {
                            return "";
                          },
                        ),
                      ),
                const SizedBox(height: 10),
              ]))),
          if (MediaQuery.of(context).viewInsets.bottom < 80)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              margin:
                  const EdgeInsets.symmetric(horizontal: defaultButtonPadding),
              child: ButtonV5(
                  onPressed: () async {
                    viewModel.updatePageStatus(SendFlowStatus.broadcasting);
                    viewModel.isSending = true;
                    bool success = false;
                    try {
                      success = await viewModel.sendCoin();
                    } catch (e) {
                      // e.toString();
                    }

                    // TODO(fix): improve this to update transactionBloc faster
                    await Future.delayed(const Duration(seconds: 1));
                    viewModel.isSending = false;
                    if (!success) {
                      viewModel
                          .updatePageStatus(SendFlowStatus.reviewTransaction);
                    }
                    if (context.mounted && success) {
                      LocalToast.showToast(
                        context,
                        S.of(context).syncing_new_data,
                        icon: null,
                      );
                      viewModel.updatePageStatus(SendFlowStatus.sendSuccess);
                    } else if (context.mounted && !success) {
                      LocalToast.showErrorToast(
                          context, viewModel.errorMessage);
                      viewModel.errorMessage = "";
                    }
                  },
                  backgroundColor: ProtonColors.protonBlue,
                  text: S.of(context).confirm_and_send,
                  width: MediaQuery.of(context).size.width,
                  textStyle:
                      ProtonStyles.body1Medium(color: ProtonColors.white),
                  height: 55),
            ),
        ]));
  }

  Widget getTransactionValueWidget(BuildContext context) {
    final int amountInSATS = getTotalAmountInSATS();
    final double amountInFiatCurrency = viewModel.bitcoinBase
        ? ExchangeCalculator.getNotionalInFiatCurrency(
            viewModel.exchangeRate, amountInSATS)
        : getTotalAmountInFiatCurrency();
    final int displayDigit =
        ExchangeCalculator.getDisplayDigit(viewModel.exchangeRate);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(S.of(context).you_are_sending,
          style: ProtonStyles.subheadline(
              color: ProtonColors.textHint, fontVariation: 400.0)),
      const SizedBox(height: 6),
      Row(children: [
        Text(
            "${viewModel.userSettingsDataProvider.getFiatCurrencySign(fiatCurrency: viewModel.exchangeRate.fiatCurrency)}${CommonHelper.formatDouble(amountInFiatCurrency, displayDigits: displayDigit)}",
            style: ProtonWalletStyles.textAmount(color: ProtonColors.textNorm)),
        const SizedBox(
          width: 6,
        ),
        Text(
            viewModel.userSettingsDataProvider.getFiatCurrencyName(
                fiatCurrency: viewModel.exchangeRate.fiatCurrency),
            style: ProtonStyles.body1Medium(color: ProtonColors.textWeak)),
      ]),
      const SizedBox(height: 4),
      ExchangeCalculator.getBitcoinUnitLabelWidget(
          viewModel.bitcoinBase
              ? viewModel.fiatCurrencyNotifier.value.bitcoinCurrency
                      ?.bitcoinUnit ??
                  BitcoinUnit.btc
              : viewModel.userSettingsDataProvider.bitcoinUnit,
          amountInSATS,
          textStyle: ProtonStyles.body2Regular(color: ProtonColors.textNorm)),
    ]);
  }

  Widget getTransactionTotalValueWidget(
      BuildContext context, SendViewModel viewModel, int estimatedFee) {
    final double estimatedFeeInNotional =
        ExchangeCalculator.getNotionalInFiatCurrency(
            viewModel.exchangeRate, estimatedFee);
    final double estimatedTotalValueInNotional =
        ExchangeCalculator.getNotionalInFiatCurrency(
            viewModel.exchangeRate, viewModel.totalAmountInSAT);
    final int displayDigit =
        ExchangeCalculator.getDisplayDigit(viewModel.exchangeRate);
    return TransactionHistoryItemV2(
      backgroundColor: ProtonColors.white,
      title: S.of(context).trans_total,
      content: AnimatedFlipCounter(
        duration: const Duration(milliseconds: 500),
        value: estimatedFeeInNotional + estimatedTotalValueInNotional,
        thousandSeparator: ",",
        prefix:
            "${viewModel.userSettingsDataProvider.getFiatCurrencyName(fiatCurrency: viewModel.exchangeRate.fiatCurrency)} ",
        fractionDigits: displayDigit,
        textStyle: ProtonStyles.body2Medium(color: ProtonColors.textNorm),
      ),
      memo: ExchangeCalculator.getBitcoinUnitLabelWidget(
          viewModel.bitcoinBase
              ? viewModel.fiatCurrencyNotifier.value.bitcoinCurrency
                      ?.bitcoinUnit ??
                  BitcoinUnit.btc
              : viewModel.userSettingsDataProvider.bitcoinUnit,
          (viewModel.totalAmountInSAT + estimatedFee),
          textStyle: ProtonStyles.body2Regular(color: ProtonColors.textHint)),
    );
  }

  Widget buildAddRecipient(BuildContext context) {
    return ColoredBox(
        color: ProtonColors.white,
        child: !viewModel.initialized
            ? const Column(children: [
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: defaultPadding),
                  child: CardLoading(
                    height: 50,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    margin: EdgeInsets.only(top: 4),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: defaultPadding),
                  child: CardLoading(
                    height: 20,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    margin: EdgeInsets.only(top: 4),
                  ),
                ),
                Expanded(
                  child: SizedBox(),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: defaultPadding),
                  child: CardLoading(
                    height: 50,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    margin: EdgeInsets.only(top: 4),
                  ),
                ),
                SizedBox(height: 20),
              ])
            : Column(children: [
                Expanded(
                    child: SingleChildScrollView(
                        child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: defaultPadding),
                            child: Center(
                                child: Column(children: [
                              Column(children: [
                                if (viewModel.accountsCount > 1)
                                  Column(children: [
                                    WalletAccountDropdown(
                                        labelText:
                                            S.of(context).send_from_account,
                                        width:
                                            MediaQuery.of(context).size.width -
                                                defaultPadding * 2,
                                        accounts:
                                            viewModel.walletData?.accounts ??
                                                [],
                                        padding: const EdgeInsets.only(
                                          left: defaultPadding,
                                          right: 8,
                                        ),
                                        valueNotifier:
                                            viewModel.accountValueNotifier),
                                    const Divider(
                                      thickness: 0.2,
                                      height: 1,
                                    ),
                                  ]),
                                const SizedBox(height: 8),
                                ProtonMailAutoComplete(
                                    labelText:
                                        S.of(context).send_to_recipient_s,
                                    emails: viewModel.contactsEmails,
                                    color: ProtonColors.white,
                                    focusNode: viewModel.addressFocusNode,
                                    textEditingController:
                                        viewModel.recipientTextController,
                                    callback:
                                        viewModel.addressAutoCompleteCallback),
                                const SizedBox(height: 5),
                                Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(width: defaultPadding),
                                      Text(
                                        "${viewModel.userSettingsDataProvider.getFiatCurrencyName(fiatCurrency: viewModel.exchangeRate.fiatCurrency)} ${ExchangeCalculator.getNotionalInFiatCurrency(viewModel.exchangeRate, viewModel.balance).toStringAsFixed(ExchangeCalculator.getDisplayDigit(viewModel.exchangeRate))} ${S.of(context).available_bitcoin_value}",
                                        style: ProtonStyles.captionRegular(
                                            color: ProtonColors.textWeak),
                                      ),
                                    ]),
                                const SizedBox(
                                  height: 10,
                                ),
                              ]),
                              if (viewModel.recipients.isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.only(
                                      top: 20, bottom: 10),
                                  width: MediaQuery.of(context).size.width,
                                  child: Text(
                                    S.of(context).recipients,
                                    style: ProtonStyles.captionMedium(
                                        color: ProtonColors.textNorm),
                                  ),
                                ),
                              for (int index = 0;
                                  index < viewModel.recipients.length;
                                  index++)
                                if (viewModel.recipients[index].isValid)
                                  RecipientDetail(
                                    name: viewModel.recipients[index].name,
                                    email: viewModel.recipients[index].email,
                                    bitcoinAddress: viewModel.bitcoinAddresses
                                            .containsKey(viewModel
                                                .recipients[index].email)
                                        ? viewModel.bitcoinAddresses[viewModel
                                                .recipients[index].email] ??
                                            ""
                                        : "",
                                    isSignatureInvalid: viewModel
                                                .bitcoinAddressesInvalidSignature[
                                            viewModel
                                                .recipients[index].email] ??
                                        false,
                                    isSelfBitcoinAddress:
                                        viewModel.selfBitcoinAddresses.contains(
                                            viewModel.bitcoinAddresses[viewModel
                                                    .recipients[index].email] ??
                                                ""),
                                    closeCallback: () {
                                      viewModel.removeRecipient(index);
                                    },
                                    canBeClosed: !viewModel.isLoadingBvE,
                                    avatarColor: AvatarColorHelper
                                        .getAvatarBackgroundColor(index),
                                    avatarTextColor:
                                        AvatarColorHelper.getAvatarTextColor(
                                            index),
                                  ),
                              if (viewModel.isLoadingBvE)
                                const CustomLoading(
                                  size: 40,
                                  strokeWidth: 3,
                                ),
                            ]))))),
                if (MediaQuery.of(context).viewInsets.bottom < 80)

                  /// continue button
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    margin: const EdgeInsets.symmetric(
                        horizontal: defaultButtonPadding),
                    child: ButtonV5(
                        onPressed: () {
                          viewModel.updatePageStatus(SendFlowStatus.editAmount);
                        },
                        enable: viewModel.validRecipientCount() > 0,
                        text: S.of(context).continue_buttion,
                        width: MediaQuery.of(context).size.width,
                        backgroundColor: ProtonColors.protonBlue,
                        textStyle:
                            ProtonStyles.body1Medium(color: ProtonColors.white),
                        height: 55),
                  ),
              ]));
  }

  Widget buildBroadcastingContent(BuildContext context) {
    return ColoredBox(
        color: ProtonColors.white,
        child: Column(children: [
          Expanded(
              child: SingleChildScrollView(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: defaultPadding),
                      child: Center(
                          child: Column(children: [
                        Stack(children: [
                          Column(
                            children: [
                              const SizedBox(
                                height: 16,
                              ),
                              FlyingBackgroundAnimation(
                                animationMilliSeconds: 2400,
                                delayMilliSeconds: 0,
                                child: Transform.rotate(
                                    angle: 40,
                                    child: Assets.images.icon.star.svg(
                                      fit: BoxFit.fill,
                                      width: 16,
                                      height: 16,
                                    )),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              FlyingBackgroundAnimation(
                                animationMilliSeconds: 3200,
                                delayMilliSeconds: 800,
                                child: Transform.rotate(
                                  angle: 40,
                                  child: Assets.images.icon.star.svg(
                                    fit: BoxFit.fill,
                                    width: 20,
                                    height: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 25,
                              ),
                              FlyingBackgroundAnimation(
                                animationMilliSeconds: 2000,
                                delayMilliSeconds: 300,
                                child: Transform.rotate(
                                  angle: 40,
                                  child: Assets.images.icon.star.svg(
                                    fit: BoxFit.fill,
                                    width: 16,
                                    height: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 14,
                              ),
                              FlyingBackgroundAnimation(
                                animationMilliSeconds: 4500,
                                delayMilliSeconds: 150,
                                child: Transform.rotate(
                                  angle: 40,
                                  child: Assets.images.icon.star.svg(
                                    fit: BoxFit.fill,
                                    width: 20,
                                    height: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              FlyingBackgroundAnimation(
                                animationMilliSeconds: 1800,
                                delayMilliSeconds: 700,
                                child: Transform.rotate(
                                  angle: 40,
                                  child: Assets.images.icon.star.svg(
                                    fit: BoxFit.fill,
                                    width: 12,
                                    height: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 31,
                              ),
                              FlyingBackgroundAnimation(
                                animationMilliSeconds: 2600,
                                delayMilliSeconds: 500,
                                child: Transform.rotate(
                                  angle: 40,
                                  child: Assets.images.icon.star.svg(
                                    fit: BoxFit.fill,
                                    width: 16,
                                    height: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(children: [
                            const SizedBox(
                              height: 80,
                            ),
                            FlyingAnimation(
                              child: Assets.images.icon.send1
                                  .svg(fit: BoxFit.fill, width: 80, height: 80),
                            ),
                            const SizedBox(
                              height: 80,
                            ),
                          ]),
                        ]),
                        Text(
                          S.of(context).send_broadcasting_content,
                          style: ProtonStyles.body2Regular(
                              color: ProtonColors.textWeak),
                          textAlign: TextAlign.center,
                        ),
                      ]))))),
        ]));
  }

  Widget buildSuccessContent(BuildContext context) {
    return ColoredBox(
        color: ProtonColors.white,
        child: Column(children: [
          Expanded(
              child: SingleChildScrollView(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: defaultPadding),
                      child: Center(
                          child: Column(children: [
                        Assets.images.icon.bitcoinBigIcon.image(
                          fit: BoxFit.fill,
                          width: 240,
                          height: 167,
                        ),
                        Text(
                          S.of(context).send_success_title,
                          style: ProtonStyles.headline(
                              color: ProtonColors.textNorm),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          S.of(context).send_success_content,
                          style: ProtonStyles.body2Regular(
                              color: ProtonColors.textWeak),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                      ]))))),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Column(children: [
                ButtonV5(
                    onPressed: () async {
                      Navigator.of(context).pop();
                    },
                    text: S.of(context).done,
                    width: MediaQuery.of(context).size.width,
                    textStyle:
                        ProtonStyles.body1Medium(color: ProtonColors.white),
                    backgroundColor: ProtonColors.protonBlue,
                    borderColor: ProtonColors.protonBlue,
                    height: 55),
                const SizedBox(
                  height: 8,
                ),
                ButtonV5(
                    onPressed: () async {
                      viewModel.showSendInvite();
                    },
                    text: S.of(context).invite_a_friend,
                    width: MediaQuery.of(context).size.width,
                    textStyle:
                        ProtonStyles.body1Medium(color: ProtonColors.textNorm),
                    backgroundColor: ProtonColors.interActionWeak,
                    borderColor: ProtonColors.interActionWeak,
                    height: 55),
                const SizedBox(height: 20),
              ])),
        ]));
  }
}

void showSelectTransactionFeeMode(
    BuildContext context, SendViewModel viewModel) {
  showModalBottomSheet(
      context: context,
      constraints: BoxConstraints(
        minWidth: MediaQuery.of(context).size.width,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 5,
                    ),
                    ListTile(
                      leading: const Icon(
                          Icons.keyboard_double_arrow_up_rounded,
                          size: 18),
                      title: getEstimatedFeeInfo(
                          context, viewModel, TransactionFeeMode.highPriority),
                      trailing: viewModel.userTransactionFeeMode ==
                              TransactionFeeMode.highPriority
                          ? Assets.images.icon.icCheckmark.svg(
                              fit: BoxFit.fill,
                              width: 20,
                              height: 20,
                            )
                          : null,
                      onTap: () async {
                        final TransactionFeeMode originTransactionFeeMode =
                            viewModel.userTransactionFeeMode;
                        viewModel.updateTransactionFeeMode(
                            TransactionFeeMode.highPriority);
                        final bool success =
                            await viewModel.buildTransactionScript();
                        if (!success) {
                          viewModel.updateTransactionFeeMode(
                              originTransactionFeeMode);
                        }
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                    const Divider(
                      thickness: 0.2,
                      height: 1,
                    ),
                    ListTile(
                      leading:
                          const Icon(Icons.horizontal_rule_rounded, size: 18),
                      title: getEstimatedFeeInfo(context, viewModel,
                          TransactionFeeMode.medianPriority),
                      trailing: viewModel.userTransactionFeeMode ==
                              TransactionFeeMode.medianPriority
                          ? Assets.images.icon.icCheckmark.svg(
                              fit: BoxFit.fill,
                              width: 20,
                              height: 20,
                            )
                          : null,
                      onTap: () async {
                        final TransactionFeeMode originTransactionFeeMode =
                            viewModel.userTransactionFeeMode;
                        viewModel.updateTransactionFeeMode(
                            TransactionFeeMode.medianPriority);
                        final bool success =
                            await viewModel.buildTransactionScript();
                        if (!success) {
                          viewModel.updateTransactionFeeMode(
                              originTransactionFeeMode);
                        }
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                    const Divider(
                      thickness: 0.2,
                      height: 1,
                    ),
                    ListTile(
                      leading: const Icon(
                          Icons.keyboard_double_arrow_down_rounded,
                          size: 18),
                      trailing: viewModel.userTransactionFeeMode ==
                              TransactionFeeMode.lowPriority
                          ? Assets.images.icon.icCheckmark.svg(
                              fit: BoxFit.fill,
                              width: 20,
                              height: 20,
                            )
                          : null,
                      title: getEstimatedFeeInfo(
                          context, viewModel, TransactionFeeMode.lowPriority),
                      onTap: () async {
                        final TransactionFeeMode originTransactionFeeMode =
                            viewModel.userTransactionFeeMode;
                        viewModel.updateTransactionFeeMode(
                            TransactionFeeMode.lowPriority);
                        final bool success =
                            await viewModel.buildTransactionScript();
                        if (!success) {
                          viewModel.updateTransactionFeeMode(
                              originTransactionFeeMode);
                        }
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ])),
        );
      });
}

Widget getEstimatedFeeInfo(BuildContext context, SendViewModel viewModel,
    TransactionFeeMode transactionFeeMode) {
  int estimatedFee = 0;
  String feeModeStr = "";
  switch (transactionFeeMode) {
    case TransactionFeeMode.highPriority:
      feeModeStr = S.of(context).high_priority;
      estimatedFee = viewModel.estimatedFeeInSATHighPriority;
    case TransactionFeeMode.medianPriority:
      feeModeStr = S.of(context).median_priority;
      estimatedFee = viewModel.estimatedFeeInSATMedianPriority;
    case TransactionFeeMode.lowPriority:
      feeModeStr = S.of(context).low_priority;
      estimatedFee = viewModel.estimatedFeeInSATLowPriority;
  }
  final int displayDigit =
      ExchangeCalculator.getDisplayDigit(viewModel.exchangeRate);
  final String estimatedFeeInFiatCurrency =
      "${viewModel.userSettingsDataProvider.getFiatCurrencyName(fiatCurrency: viewModel.exchangeRate.fiatCurrency)}${ExchangeCalculator.getNotionalInFiatCurrency(viewModel.exchangeRate, estimatedFee).toStringAsFixed(displayDigit)}";
  final String estimatedFeeInSATS = ExchangeCalculator.getBitcoinUnitLabel(
      viewModel.bitcoinBase
          ? viewModel.fiatCurrencyNotifier.value.bitcoinCurrency?.bitcoinUnit ??
              BitcoinUnit.btc
          : viewModel.userSettingsDataProvider.bitcoinUnit,
      estimatedFee);
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(feeModeStr,
        style: ProtonStyles.body2Regular(color: ProtonColors.textNorm)),
    Text("$estimatedFeeInFiatCurrency ($estimatedFeeInSATS)",
        style: ProtonStyles.captionRegular(color: ProtonColors.textHint)),
  ]);
}
