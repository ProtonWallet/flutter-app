import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:wallet/components/bottom.sheets/placeholder.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/components/dropdown.button.v2.dart';
import 'package:wallet/components/protonmail.autocomplete.dart';
import 'package:wallet/components/recipient.detail.dart';
import 'package:wallet/components/textfield.send.btc.v2.dart';
import 'package:wallet/components/textfield.text.v2.dart';
import 'package:wallet/components/transaction.history.item.dart';
import 'package:wallet/components/wallet.account.dropdown.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/fiat.currency.helper.dart';
import 'package:wallet/helper/local_toast.dart';
import 'package:wallet/helper/user.settings.provider.dart';
import 'package:wallet/managers/wallet/proton.wallet.provider.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/send/send.viewmodel.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/theme/theme.font.dart';

class SendView extends ViewBase<SendViewModel> {
  const SendView(SendViewModel viewModel)
      : super(viewModel, const Key("SendView"));

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
        title: getTitleWidget(context),
        centerTitle: true,
        leading: getLeadingWidget(context),
        actions: [
          if (viewModel.sendFlowStatus == SendFlowStatus.editAmount)
            GestureDetector(
                onTap: () {
                  viewModel.updatePageStatus(SendFlowStatus.addRecipient);
                },
                child: Padding(
                    padding: const EdgeInsets.only(right: defaultPadding),
                    child: Text(
                      S.of(context).add_recipient,
                      style: FontManager.body2Median(ProtonColors.protonBlue),
                    )))
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
        ),
        scrolledUnderElevation:
            0.0, // don't change background color when scroll down
      ),
      body: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: buildMainView(context)),
    );
  }

  Widget? getTitleWidget(BuildContext context) {
    if (viewModel.sendFlowStatus == SendFlowStatus.reviewTransaction) {
      return Text(S.of(context).review_your_transaction,
          style: FontManager.body2Median(ProtonColors.textNorm));
    }
    return null;
  }

  Widget getLeadingWidget(BuildContext context) {
    if ([SendFlowStatus.addRecipient, SendFlowStatus.sendSuccess]
        .contains(viewModel.sendFlowStatus)) {
      return IconButton(
        icon: Icon(Icons.close, color: ProtonColors.textNorm),
        onPressed: () {
          Navigator.of(context).pop();
        },
      );
    }
    return IconButton(
      icon: Icon(Icons.arrow_back, color: ProtonColors.textNorm),
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
      case SendFlowStatus.sendSuccess:
        return buildSuccessContent(context);
    }
  }

  Widget buildEditAmount(BuildContext context) {
    return Container(
        color: ProtonColors.backgroundProton,
        child: Column(children: [
          Expanded(
              child: SingleChildScrollView(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: defaultPadding),
                      child: Center(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                            const SizedBox(height: 20),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(width: defaultPadding),
                                  Text(
                                    "${Provider.of<UserSettingProvider>(context).getFiatCurrencyName()} ${Provider.of<UserSettingProvider>(context).getNotionalInFiatCurrency(viewModel.balance).toStringAsFixed(defaultDisplayDigits)} ${S.of(context).available_bitcoin_value}",
                                    style: FontManager.captionRegular(
                                        ProtonColors.textWeak),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () {
                                      // TODO:: fix logic to remain more accurate fee
                                      viewModel.amountTextController.text =
                                          Provider.of<UserSettingProvider>(
                                                  context,
                                                  listen: false)
                                              .getNotionalInFiatCurrency(
                                                  viewModel.balance)
                                              .toStringAsFixed(
                                                  defaultDisplayDigits);
                                      viewModel.splitAmountToRecipients();
                                    },
                                    child: Text(S.of(context).send_all,
                                        style: FontManager.captionMedian(
                                            ProtonColors.protonBlue)),
                                  )
                                ]),
                            const SizedBox(height: 4),
                            Row(children: [
                              Expanded(
                                  child: TextFieldSendBTCV2(
                                backgroundColor: ProtonColors.white,
                                labelText: S.of(context).amount,
                                textController: viewModel.amountTextController,
                                myFocusNode: viewModel.amountFocusNode,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d*\.?\d*$'))
                                ],
                                currency:
                                    Provider.of<UserSettingProvider>(context)
                                        .walletUserSetting
                                        .fiatCurrency,
                                currencyExchangeRate:
                                    Provider.of<UserSettingProvider>(context)
                                        .walletUserSetting
                                        .exchangeRate
                                        .exchangeRate,
                                userSettingProvider:
                                    Provider.of<UserSettingProvider>(context),
                                validation: (String value) {
                                  return "";
                                },
                              )),
                              const SizedBox(
                                width: 10,
                              ),
                              Container(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: DropdownButtonV2(
                                      width: 80,
                                      padding: const EdgeInsets.only(
                                          left: 10,
                                          right: 10,
                                          top: 4,
                                          bottom: 2),
                                      maxSuffixIconWidth: 20,
                                      textStyle: FontManager.captionMedian(
                                          ProtonColors.textNorm),
                                      backgroundColor: ProtonColors.white,
                                      items: fiatCurrencies,
                                      canSearch: true,
                                      itemsText: fiatCurrencies
                                          .map((v) =>
                                              FiatCurrencyHelper.getFullName(v))
                                          .toList(),
                                      itemsTextForDisplay: fiatCurrencies
                                          .map((v) =>
                                              FiatCurrencyHelper.getDisplayName(
                                                  v))
                                          .toList(),
                                      valueNotifier:
                                          viewModel.fiatCurrencyNotifier)),
                            ]),
                            if (viewModel.recipients.isNotEmpty)
                              Container(
                                margin:
                                    const EdgeInsets.only(top: 20, bottom: 10),
                                width: MediaQuery.of(context).size.width,
                                child: Text(
                                  S.of(context).recipients,
                                  style: FontManager.captionMedian(
                                      ProtonColors.textNorm),
                                ),
                              ),
                            for (int index = 0;
                                index < viewModel.recipients.length;
                                index++)
                              RecipientDetail(
                                name: viewModel.recipients[index].email,
                                email: viewModel.recipients[index].email,
                                bitcoinAddress: viewModel.bitcoinAddresses
                                        .containsKey(
                                            viewModel.recipients[index].email)
                                    ? viewModel.bitcoinAddresses[viewModel
                                            .recipients[index].email] ??
                                        ""
                                    : "",
                                isSignatureInvalid: viewModel
                                            .bitcoinAddressesInvalidSignature[
                                        viewModel.recipients[index].email] ??
                                    false,
                                isSelfBitcoinAddress:
                                    viewModel.selfBitcoinAddresses.contains(
                                        viewModel.bitcoinAddresses[viewModel
                                                .recipients[index].email] ??
                                            ""),
                                callback: () {
                                  viewModel.removeRecipient(index);
                                },
                                amountController:
                                    viewModel.recipients.length > 1
                                        ? viewModel
                                            .recipients[index].amountController
                                        : null,
                                amountFocusNode: viewModel.recipients.length > 1
                                    ? viewModel.recipients[index].focusNode
                                    : null,
                              ),
                            const SizedBox(height: 20),
                            if (viewModel.errorMessage.isNotEmpty)
                              Text(
                                viewModel.errorMessage,
                                style: FontManager.body2Median(
                                    ProtonColors.signalError),
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
                    textStyle: FontManager.body1Median(ProtonColors.white),
                    height: 48)),
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
      case TransactionFeeMode.lowPriority:
        estimatedFee =
            (viewModel.baseFeeInSAT * viewModel.feeRateLowPriority).ceil();
        break;
      case TransactionFeeMode.medianPriority:
        estimatedFee =
            (viewModel.baseFeeInSAT * viewModel.feeRateMedianPriority).ceil();
        break;
      case TransactionFeeMode.highPriority:
        estimatedFee =
            (viewModel.baseFeeInSAT * viewModel.feeRateHighPriority).ceil();
        break;
    }
    return Container(
        color: ProtonColors.backgroundProton,
        child: Column(children: [
          Expanded(
              child: SingleChildScrollView(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: defaultPadding),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            getTransactionValueWidget(context),
                            const SizedBox(height: 20),
                            for (ProtonRecipient protonRecipient
                                in viewModel.recipients)
                              if (viewModel.bitcoinAddresses
                                      .containsKey(protonRecipient.email) &&
                                  viewModel.bitcoinAddresses[
                                          protonRecipient.email]! !=
                                      "" &&
                                  viewModel.selfBitcoinAddresses.contains(
                                          viewModel.bitcoinAddresses[
                                                  protonRecipient.email] ??
                                              "") ==
                                      false)
                                Column(children: [
                                  TransactionHistoryItem(
                                    title: S.of(context).trans_to,
                                    content: protonRecipient.email,
                                    memo: viewModel.bitcoinAddresses[
                                        protonRecipient.email],
                                    amountInSATS:
                                        viewModel.recipients.length > 1
                                            ? protonRecipient.amountInSATS
                                            : null,
                                  ),
                                  const Divider(
                                    thickness: 0.2,
                                    height: 1,
                                  ),
                                ]),
                            TransactionHistoryItem(
                              title: S.of(context).trans_metworkFee,
                              titleCallback: () {
                                CustomPlaceholder.show(context);
                              },
                              titleOptionsCallback: () {
                                showSelectTransactionFeeMode(
                                    context, viewModel);
                              },
                              content:
                                  "${Provider.of<UserSettingProvider>(context).getFiatCurrencyName()}${Provider.of<UserSettingProvider>(context).getNotionalInFiatCurrency(estimatedFee).toStringAsFixed(defaultDisplayDigits)}",
                              memo: Provider.of<UserSettingProvider>(context)
                                  .getBitcoinUnitLabel(estimatedFee),
                            ),
                            const Divider(
                              thickness: 0.2,
                              height: 1,
                            ),
                            getTransactionTotalValueWidget(
                                context, viewModel, estimatedFee),
                            const Divider(
                              thickness: 0.2,
                              height: 1,
                            ),
                            const SizedBox(height: 10),
                            if (viewModel.hasEmailIntegrationRecipient)
                              viewModel.isEditingEmailBody == false
                                  ? Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 5.0),
                                      padding:
                                          const EdgeInsets.all(defaultPadding),
                                      decoration: BoxDecoration(
                                          color: ProtonColors
                                              .transactionNoteBackground,
                                          borderRadius:
                                              BorderRadius.circular(40.0)),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset(
                                              "assets/images/icon/ic_message.svg",
                                              fit: BoxFit.fill,
                                              width: 32,
                                              height: 32),
                                          const SizedBox(width: 10),
                                          GestureDetector(
                                              onTap: () {
                                                viewModel.editEmailBody();
                                              },
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  if (viewModel
                                                      .emailBodyController
                                                      .text
                                                      .isNotEmpty)
                                                    SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width -
                                                            defaultPadding * 6 -
                                                            10,
                                                        child: Flex(
                                                            direction:
                                                                Axis.horizontal,
                                                            children: [
                                                              Flexible(
                                                                  child: Text(
                                                                      viewModel
                                                                          .emailBodyController
                                                                          .text,
                                                                      style: FontManager.body2Median(
                                                                          ProtonColors
                                                                              .textNorm)))
                                                            ])),
                                                  Text(
                                                      S
                                                          .of(context)
                                                          .message_to_recipient_optional(
                                                              viewModel
                                                                  .validRecipientCount()),
                                                      style: FontManager
                                                          .body2Median(
                                                              ProtonColors
                                                                  .protonBlue)),
                                                ],
                                              ))
                                        ],
                                      ))
                                  : Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 5.0),
                                      child: TextFieldTextV2(
                                        labelText: S
                                            .of(context)
                                            .message_to_recipient_optional(
                                                viewModel
                                                    .validRecipientCount()),
                                        textController:
                                            viewModel.emailBodyController,
                                        myFocusNode:
                                            viewModel.emailBodyFocusNode,
                                        paddingSize: 7,
                                        maxLines: 3,
                                        scrollPadding: EdgeInsets.only(
                                            bottom: MediaQuery.of(context)
                                                    .viewInsets
                                                    .bottom +
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
                            viewModel.isEditingMemo == false
                                ? Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 5.0),
                                    padding:
                                        const EdgeInsets.all(defaultPadding),
                                    decoration: BoxDecoration(
                                        color: ProtonColors
                                            .transactionNoteBackground,
                                        borderRadius:
                                            BorderRadius.circular(40.0)),
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
                                        GestureDetector(
                                            onTap: () {
                                              viewModel.editMemo();
                                            },
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                if (viewModel.memoTextController
                                                    .text.isNotEmpty)
                                                  SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width -
                                                              defaultPadding *
                                                                  6 -
                                                              10,
                                                      child: Flex(
                                                          direction:
                                                              Axis.horizontal,
                                                          children: [
                                                            Flexible(
                                                                child: Text(
                                                                    viewModel
                                                                        .memoTextController
                                                                        .text,
                                                                    style: FontManager.body2Median(
                                                                        ProtonColors
                                                                            .textNorm)))
                                                          ])),
                                                Text(
                                                    S
                                                        .of(context)
                                                        .message_to_myself,
                                                    style:
                                                        FontManager.body2Median(
                                                            ProtonColors
                                                                .protonBlue)),
                                              ],
                                            ))
                                      ],
                                    ))
                                : Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 5.0),
                                    child: TextFieldTextV2(
                                      labelText:
                                          S.of(context).message_to_myself,
                                      textController:
                                          viewModel.memoTextController,
                                      myFocusNode: viewModel.memoFocusNode,
                                      paddingSize: 7,
                                      maxLines: 3,
                                      scrollPadding: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                                  .viewInsets
                                                  .bottom +
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
                          ])))),
          if (MediaQuery.of(context).viewInsets.bottom < 80)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              margin:
                  const EdgeInsets.symmetric(horizontal: defaultButtonPadding),
              child: ButtonV5(
                  onPressed: () async {
                    // TODO:: Send bitcoin with Esplora client
                    bool success = await viewModel.sendCoin();
                    if (context.mounted && success) {
                      Provider.of<ProtonWalletProvider>(context, listen: false)
                          .syncWallet();
                      viewModel.updatePageStatus(SendFlowStatus.sendSuccess);
                    } else if (context.mounted && success == false) {
                      LocalToast.showErrorToast(
                          context, viewModel.errorMessage);
                      viewModel.errorMessage = "";
                    }
                  },
                  backgroundColor: ProtonColors.protonBlue,
                  text: S.of(context).submit,
                  width: MediaQuery.of(context).size.width,
                  textStyle: FontManager.body1Median(ProtonColors.white),
                  height: 48),
            ),
        ]));
  }

  Widget getTransactionValueWidget(BuildContext context) {
    int amountInSATS = getTotalAmountInSATS();
    double amountInFiatCurrency = getTotalAmountInFiatCurrency();
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Text(S.of(context).you_are_sending,
          style: FontManager.titleSubHeadline(ProtonColors.textHint)),
      Text(
          "${Provider.of<UserSettingProvider>(context).getFiatCurrencyName()}${amountInFiatCurrency.toStringAsFixed(defaultDisplayDigits)}",
          style: FontManager.sendAmount(ProtonColors.textNorm)),
      Text(
          Provider.of<UserSettingProvider>(context)
              .getBitcoinUnitLabel(amountInSATS),
          style: FontManager.body2Regular(ProtonColors.textNorm)),
    ]);
  }

  Widget getTransactionTotalValueWidget(
      BuildContext context, SendViewModel viewModel, int estimatedFee) {
    double estimatedFeeInNotional = Provider.of<UserSettingProvider>(context)
        .getNotionalInFiatCurrency(estimatedFee);
    double estimatedTotalValueInNotional =
        Provider.of<UserSettingProvider>(context)
            .getNotionalInFiatCurrency(viewModel.totalAmountInSAT);
    return TransactionHistoryItem(
      title: S.of(context).trans_total,
      content:
          "${Provider.of<UserSettingProvider>(context).getFiatCurrencyName()}${(estimatedFeeInNotional + estimatedTotalValueInNotional).toStringAsFixed(defaultDisplayDigits)}",
      memo: Provider.of<UserSettingProvider>(context)
          .getBitcoinUnitLabel((viewModel.totalAmountInSAT + estimatedFee)),
    );
  }

  Widget buildAddRecipient(BuildContext context) {
    return Container(
        color: ProtonColors.backgroundProton,
        child: Column(children: [
          Expanded(
              child: SingleChildScrollView(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: defaultPadding),
                      child: Center(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(height: 20),
                                Column(children: [
                                  ProtonMailAutoComplete(
                                      labelText: S.of(context).send_to_recipient_s,
                                      emails: viewModel.contactsEmail,
                                      color: ProtonColors.white,
                                      focusNode: viewModel.addressFocusNode,
                                      textEditingController:
                                      viewModel.recipientTextController,
                                      callback: () {
                                        viewModel.addressAutoCompleteCallback();
                                      }),
                                  const SizedBox(height: 5),
                                  if (Provider.of<ProtonWalletProvider>(context)
                                      .protonWallet
                                      .currentAccount ==
                                      null &&
                                      Provider.of<ProtonWalletProvider>(context)
                                          .protonWallet
                                          .currentAccounts
                                          .length >
                                          1)
                                    WalletAccountDropdown(
                                        labelText: S.of(context).trans_from,
                                        backgroundColor: ProtonColors.white,
                                        width: MediaQuery.of(context).size.width -
                                            defaultPadding * 2,
                                        accounts: Provider.of<ProtonWalletProvider>(
                                            context)
                                            .protonWallet
                                            .currentAccounts,
                                        valueNotifier: viewModel.initialized
                                            ? viewModel.accountValueNotifier
                                            : ValueNotifier(
                                            Provider.of<ProtonWalletProvider>(
                                                context)
                                                .protonWallet
                                                .currentAccounts
                                                .first)),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(width: defaultPadding),
                                        Text(
                                          "${Provider.of<UserSettingProvider>(context).getFiatCurrencyName()} ${Provider.of<UserSettingProvider>(context).getNotionalInFiatCurrency(viewModel.balance).toStringAsFixed(defaultDisplayDigits)} ${S.of(context).available_bitcoin_value}",
                                          style: FontManager.captionRegular(
                                              ProtonColors.textWeak),
                                        ),
                                      ]),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ]),
                                if (viewModel.recipients.isNotEmpty)
                                  Container(
                                    margin:
                                    const EdgeInsets.only(top: 20, bottom: 10),
                                    width: MediaQuery.of(context).size.width,
                                    child: Text(
                                      S.of(context).recipients,
                                      style: FontManager.captionMedian(
                                          ProtonColors.textNorm),
                                    ),
                                  ),
                                for (int index = 0;
                                index < viewModel.recipients.length;
                                index++)
                                  RecipientDetail(
                                    name: viewModel.recipients[index].email,
                                    email: viewModel.recipients[index].email,
                                    bitcoinAddress: viewModel.bitcoinAddresses
                                        .containsKey(
                                        viewModel.recipients[index].email)
                                        ? viewModel.bitcoinAddresses[viewModel
                                        .recipients[index].email] ??
                                        ""
                                        : "",
                                    isSignatureInvalid: viewModel
                                        .bitcoinAddressesInvalidSignature[
                                    viewModel.recipients[index].email] ??
                                        false,
                                    isSelfBitcoinAddress:
                                    viewModel.selfBitcoinAddresses.contains(
                                        viewModel.bitcoinAddresses[viewModel
                                            .recipients[index].email] ??
                                            ""),
                                    callback: () {
                                      viewModel.removeRecipient(index);
                                    },
                                  ),
                              ]))))),
          if (MediaQuery.of(context).viewInsets.bottom < 80)
            Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                margin: const EdgeInsets.symmetric(
                    horizontal: defaultButtonPadding),
                child: ButtonV5(
                    onPressed: () {
                      viewModel.updatePageStatus(SendFlowStatus.editAmount);
                    },
                    enable: viewModel.validRecipientCount() > 0,
                    text: S.of(context).confirm,
                    width: MediaQuery.of(context).size.width,
                    backgroundColor: ProtonColors.protonBlue,
                    textStyle: FontManager.body1Median(ProtonColors.white),
                    height: 48)),
        ]));
  }

  Widget buildSuccessContent(BuildContext context) {
    return Container(
        color: ProtonColors.backgroundProton,
        child: Column(children: [
          Expanded(
              child: SingleChildScrollView(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: defaultPadding),
                      child: Center(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                    "assets/images/icon/send_success.svg",
                                    fit: BoxFit.fill,
                                    width: 240,
                                    height: 240),
                                Text(
                                  S.of(context).send_success_title,
                                  style: FontManager.titleHeadline(ProtonColors.textNorm),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  S.of(context).send_success_content,
                                  style: FontManager.body2Regular(ProtonColors.textWeak),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 40),
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: defaultPadding),
                                    child: Column(children: [
                                      ButtonV5(
                                          onPressed: () async {
                                            viewModel.coordinator.end();
                                            Navigator.of(context).pop();
                                          },
                                          text: S.of(context).done,
                                          width: MediaQuery.of(context).size.width,
                                          textStyle:
                                          FontManager.body1Median(ProtonColors.white),
                                          backgroundColor: ProtonColors.protonBlue,
                                          borderColor: ProtonColors.protonBlue,
                                          height: 48),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      ButtonV5(
                                          onPressed: () async {
                                            // TODO:: add invite friend dialog and api call here
                                            LocalToast.showToast(context, "TODO");
                                          },
                                          text: S.of(context).invite_a_friend,
                                          width: MediaQuery.of(context).size.width,
                                          textStyle: FontManager.body1Median(
                                              ProtonColors.textNorm),
                                          backgroundColor: ProtonColors.textWeakPressed,
                                          borderColor: ProtonColors.textWeakPressed,
                                          height: 48),
                                    ])),
                              ]))))),
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
                          ? SvgPicture.asset(
                              "assets/images/icon/ic-checkmark.svg",
                              fit: BoxFit.fill,
                              width: 20,
                              height: 20)
                          : null,
                      onTap: () async {
                        TransactionFeeMode originTransactionFeeMode =
                            viewModel.userTransactionFeeMode;
                        viewModel.updateTransactionFeeMode(
                            TransactionFeeMode.highPriority);
                        bool success = await viewModel.buildTransactionScript();
                        if (success == false) {
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
                          ? SvgPicture.asset(
                              "assets/images/icon/ic-checkmark.svg",
                              fit: BoxFit.fill,
                              width: 20,
                              height: 20)
                          : null,
                      onTap: () async {
                        TransactionFeeMode originTransactionFeeMode =
                            viewModel.userTransactionFeeMode;
                        viewModel.updateTransactionFeeMode(
                            TransactionFeeMode.medianPriority);
                        bool success = await viewModel.buildTransactionScript();
                        if (success == false) {
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
                          ? SvgPicture.asset(
                              "assets/images/icon/ic-checkmark.svg",
                              fit: BoxFit.fill,
                              width: 20,
                              height: 20)
                          : null,
                      title: getEstimatedFeeInfo(
                          context, viewModel, TransactionFeeMode.lowPriority),
                      onTap: () async {
                        TransactionFeeMode originTransactionFeeMode =
                            viewModel.userTransactionFeeMode;
                        viewModel.updateTransactionFeeMode(
                            TransactionFeeMode.lowPriority);
                        bool success = await viewModel.buildTransactionScript();
                        if (success == false) {
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
      estimatedFee =
          (viewModel.baseFeeInSAT * viewModel.feeRateHighPriority).ceil();
      break;
    case TransactionFeeMode.medianPriority:
      feeModeStr = S.of(context).median_priority;
      estimatedFee =
          (viewModel.baseFeeInSAT * viewModel.feeRateMedianPriority).ceil();
      break;
    case TransactionFeeMode.lowPriority:
      feeModeStr = S.of(context).low_priority;
      estimatedFee =
          (viewModel.baseFeeInSAT * viewModel.feeRateLowPriority).ceil();
      break;
  }
  String estimatedFeeInFiatCurrency =
      "${Provider.of<UserSettingProvider>(context).getFiatCurrencyName()}${Provider.of<UserSettingProvider>(context).getNotionalInFiatCurrency(estimatedFee).toStringAsFixed(defaultDisplayDigits)}";
  String estimatedFeeInSATS = Provider.of<UserSettingProvider>(context)
      .getBitcoinUnitLabel(estimatedFee);
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(feeModeStr, style: FontManager.body2Regular(ProtonColors.textNorm)),
    Text("$estimatedFeeInFiatCurrency ($estimatedFeeInSATS)",
        style: FontManager.captionRegular(ProtonColors.textHint)),
  ]);
}
