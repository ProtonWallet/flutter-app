import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:wallet/components/bottom.sheets/placeholder.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/components/dropdown.button.v2.dart';
import 'package:wallet/components/protonmail.autocomplete.dart';
import 'package:wallet/components/recipient.detail.dart';
import 'package:wallet/components/tag.text.dart';
import 'package:wallet/components/textfield.send.btc.v2.dart';
import 'package:wallet/components/textfield.text.v2.dart';
import 'package:wallet/components/transaction.history.item.dart';
import 'package:wallet/components/wallet.account.dropdown.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/fiat.currency.helper.dart';
import 'package:wallet/helper/local_toast.dart';
import 'package:wallet/helper/user.settings.provider.dart';
import 'package:wallet/provider/proton.wallet.provider.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/send/send.viewmodel.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/theme/theme.font.dart';

class SendView extends ViewBase<SendViewModel> {
  const SendView(SendViewModel viewModel)
      : super(viewModel, const Key("SendView"));

  @override
  Widget buildWithViewModel(
      BuildContext context, SendViewModel viewModel, ViewSize viewSize) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
          statusBarBrightness: Brightness.light, // For iOS (dark icons)
        ),
        backgroundColor: ProtonColors.white,
        title: Text(
            viewModel.inReview
                ? "Review your transaction"
                : S.of(context).send_bitcoin,
            style: FontManager.body2Median(ProtonColors.textNorm)),
        centerTitle: true,
        leading: viewModel.inReview
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: ProtonColors.textNorm),
                onPressed: () {
                  viewModel.updatePageStatus(inReview: false);
                },
              )
            : IconButton(
                icon: Icon(Icons.close, color: ProtonColors.textNorm),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
        ),
        scrolledUnderElevation:
            0.0, // don't change background color when scroll down
      ),
      body: viewModel.inReview
          ? buildReviewContent(context, viewModel, viewSize)
          : buildContent(context, viewModel, viewSize),
    );
  }

  Widget buildReviewContent(
      BuildContext context, SendViewModel viewModel, ViewSize viewSize) {
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
        color: ProtonColors.white,
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
                            getTransactionValueWidget(context, viewModel),
                            const SizedBox(height: 20),
                            for (String recipient in viewModel.recipients)
                              if (viewModel.bitcoinAddresses
                                      .containsKey(recipient) &&
                                  viewModel.bitcoinAddresses[recipient]! !=
                                      "" &&
                                  viewModel.selfBitcoinAddresses.contains(
                                          viewModel.bitcoinAddresses[
                                                  recipient] ??
                                              "") ==
                                      false)
                                Column(children: [
                                  TransactionHistoryItem(
                                    title: S.of(context).trans_to,
                                    content: recipient,
                                    memo: viewModel.bitcoinAddresses[recipient],
                                    amountInSATS:
                                        viewModel.recipients.length > 1
                                            ? viewModel.amountInSATS
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
                                  "${Provider.of<UserSettingProvider>(context).getFiatCurrencySign()}${Provider.of<UserSettingProvider>(context).getNotionalInFiatCurrency(estimatedFee).toStringAsFixed(defaultDisplayDigits)}",
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
                                                        child: Flexible(
                                                            child: Text(
                                                                viewModel
                                                                    .emailBodyController
                                                                    .text,
                                                                style: FontManager
                                                                    .body2Median(
                                                                        ProtonColors
                                                                            .textNorm)))),
                                                  Text(
                                                      S
                                                          .of(context)
                                                          .message_to_recipient_optional,
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
                                            .message_to_recipient_optional,
                                        textController:
                                            viewModel.emailBodyController,
                                        myFocusNode:
                                            viewModel.emailBodyFocusNode,
                                        paddingSize: 7,
                                        maxLines: 3,
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
                                                      child: Flexible(
                                                          child: Text(
                                                              viewModel
                                                                  .memoTextController
                                                                  .text,
                                                              style: FontManager
                                                                  .body2Median(
                                                                      ProtonColors
                                                                          .textNorm)))),
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
                    viewModel.coordinator.end();
                    Navigator.of(context).pop();
                  } else if (context.mounted && success == false) {
                    LocalToast.showErrorToast(context, viewModel.errorMessage);
                    viewModel.errorMessage = "";
                  }
                },
                enable:
                    (viewModel.isEditingEmailBody | viewModel.isEditingMemo) ==
                        false,
                backgroundColor: ProtonColors.protonBlue,
                text: S.of(context).submit,
                width: MediaQuery.of(context).size.width,
                textStyle: FontManager.body1Median(ProtonColors.white),
                height: 48),
          ),
        ]));
  }

  Widget getTransactionValueWidget(
      BuildContext context, SendViewModel viewModel) {
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Text(S.of(context).you_are_sending,
          style: FontManager.titleSubHeadline(ProtonColors.textHint)),
      Text(
          "${Provider.of<UserSettingProvider>(context).getFiatCurrencySign()}${Provider.of<UserSettingProvider>(context).getNotionalInFiatCurrency(viewModel.totalAmountInSAT).toStringAsFixed(defaultDisplayDigits)}",
          style: FontManager.sendAmount(ProtonColors.textNorm)),
      Text(
          Provider.of<UserSettingProvider>(context)
              .getBitcoinUnitLabel(viewModel.totalAmountInSAT),
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
          "${Provider.of<UserSettingProvider>(context).getFiatCurrencySign()}${(estimatedFeeInNotional + estimatedTotalValueInNotional).toStringAsFixed(defaultDisplayDigits)}",
      memo: Provider.of<UserSettingProvider>(context)
          .getBitcoinUnitLabel((viewModel.totalAmountInSAT + estimatedFee)),
    );
  }

  Widget buildContent(
      BuildContext context, SendViewModel viewModel, ViewSize viewSize) {
    return Container(
        color: ProtonColors.white,
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
                                name: viewModel.recipients[index],
                                email: viewModel.recipients[index],
                                bitcoinAddress: viewModel.bitcoinAddresses
                                        .containsKey(
                                            viewModel.recipients[index])
                                    ? viewModel.bitcoinAddresses[
                                            viewModel.recipients[index]] ??
                                        ""
                                    : "",
                                isSelfBitcoinAddress: viewModel
                                    .selfBitcoinAddresses
                                    .contains(viewModel.bitcoinAddresses[
                                            viewModel.recipients[index]] ??
                                        ""),
                                callback: () {
                                  viewModel.removeRecipient(index);
                                },
                              ),
                            const SizedBox(height: 20),
                            if (Provider.of<ProtonWalletProvider>(context)
                                    .protonWallet
                                    .currentAccount ==
                                null)
                              Column(children: [
                                WalletAccountDropdown(
                                    labelText: S.of(context).trans_from,
                                    backgroundColor:
                                        ProtonColors.backgroundProton,
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
                                  height: 10,
                                ),
                              ]),
                            Row(children: [
                              Expanded(
                                  child: TextFieldSendBTCV2(
                                backgroundColor: ProtonColors.backgroundProton,
                                labelText: S.of(context).amount,
                                textController: viewModel.amountTextController,
                                myFocusNode: viewModel.amountFocusNode,
                                currency:
                                    Provider.of<UserSettingProvider>(context)
                                        .walletUserSetting
                                        .fiatCurrency,
                                currencyExchangeRate:
                                    Provider.of<UserSettingProvider>(context)
                                        .walletUserSetting
                                        .exchangeRate
                                        .exchangeRate,
                                btcBalance: viewModel.balance / 100000000,
                                userSettingProvider:
                                    Provider.of<UserSettingProvider>(context),
                                validation: (String value) {
                                  return "";
                                },
                              )),
                              const SizedBox(
                                width: 10,
                              ),
                              DropdownButtonV2(
                                  width: 90,
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10, top: 2, bottom: 2),
                                  maxSuffixIconWidth: 20,
                                  textStyle: FontManager.captionMedian(
                                      ProtonColors.textNorm),
                                  backgroundColor:
                                      ProtonColors.backgroundProton,
                                  items: fiatCurrencies,
                                  itemsText: fiatCurrencies
                                      .map((v) => FiatCurrencyHelper.getName(v))
                                      .toList(),
                                  valueNotifier:
                                      viewModel.fiatCurrencyNotifier),
                            ]),
                            const SizedBox(height: 20),
                            if (viewModel.errorMessage.isNotEmpty)
                              Text(
                                viewModel.errorMessage,
                                style: FontManager.body2Median(
                                    ProtonColors.signalError),
                              ),
                            // Text(viewModel.feeRateHighPriority.toStringAsFixed(6)),
                            // Text(
                            //     viewModel.feeRateMedianPriority.toStringAsFixed(6)),
                            // Text(viewModel.feeRateLowPriority.toStringAsFixed(6)),
                          ]))))),
          Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              margin:
                  const EdgeInsets.symmetric(horizontal: defaultButtonPadding),
              child: ButtonV5(
                  onPressed: () {
                    viewModel.updatePageStatus(inReview: true);
                  },
                  enable: viewModel.validRecipientCount() > 0,
                  text: S.of(context).review_transaction,
                  width: MediaQuery.of(context).size.width,
                  backgroundColor: ProtonColors.protonBlue,
                  textStyle: FontManager.body1Median(ProtonColors.white),
                  height: 48)),
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
      "${Provider.of<UserSettingProvider>(context).getFiatCurrencySign()}${Provider.of<UserSettingProvider>(context).getNotionalInFiatCurrency(estimatedFee).toStringAsFixed(defaultDisplayDigits)}";
  String estimatedFeeInSATS = Provider.of<UserSettingProvider>(context)
      .getBitcoinUnitLabel(estimatedFee);
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(feeModeStr, style: FontManager.body2Regular(ProtonColors.textNorm)),
    Text("$estimatedFeeInFiatCurrency ($estimatedFeeInSATS)",
        style: FontManager.captionRegular(ProtonColors.textHint)),
  ]);
}

Widget getTransactionFeeModeWidget(
    BuildContext context, SendViewModel viewModel) {
  switch (viewModel.userTransactionFeeMode) {
    case TransactionFeeMode.highPriority:
      return TagText(
        width: 120,
        text: "High Priority",
        radius: 10.0,
        background: const Color.fromARGB(255, 40, 116, 4),
        textColor: ProtonColors.white,
      );
    case TransactionFeeMode.lowPriority:
      return TagText(
        width: 120,
        text: "Low Priority",
        radius: 10.0,
        background: const Color.fromARGB(255, 247, 65, 143),
        textColor: ProtonColors.white,
      );
    default:
      return TagText(
        width: 120,
        text: "Median Priority",
        radius: 10.0,
        background: const Color.fromARGB(255, 255, 152, 0),
        textColor: ProtonColors.white,
      );
  }
}
