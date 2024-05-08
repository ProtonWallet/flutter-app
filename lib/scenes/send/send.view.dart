import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/components/dropdown.button.v2.dart';
import 'package:wallet/components/protonmail.autocomplete.dart';
import 'package:wallet/components/recipient.detail.dart';
import 'package:wallet/components/tag.text.dart';
import 'package:wallet/components/textfield.send.btc.v2.dart';
import 'package:wallet/components/textfield.text.v2.dart';
import 'package:wallet/components/transaction.history.item.dart';
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
  SendView(SendViewModel viewModel) : super(viewModel, const Key("SendView"));

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
                            for (String recipent in viewModel.recipents)
                              if (viewModel.bitcoinAddresses
                                      .containsKey(recipent) &&
                                  viewModel.bitcoinAddresses[recipent]! != "")
                                Column(children: [
                                  TransactionHistoryItem(
                                    title: S.of(context).trans_to,
                                    content: recipent,
                                    memo: viewModel.bitcoinAddresses[recipent],
                                  ),
                                  const Divider(
                                    thickness: 0.2,
                                    height: 1,
                                  ),
                                ]),
                            TransactionHistoryItem(
                              title: S.of(context).trans_metworkFee,
                              titleCallback: () {
                                showNetworkFee(context);
                              },
                              titleOptionsCallback: () {
                                showSelectTransactionFeeMode(
                                    context, viewModel);
                              },
                              content:
                                  "${Provider.of<UserSettingProvider>(context).getFiatCurrencySign()}${Provider.of<UserSettingProvider>(context).getNotionalInFiatCurrency(estimatedFee).toStringAsFixed(3)}",
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
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (viewModel.emailBodyController
                                                .text.isNotEmpty)
                                              Text(
                                                  viewModel
                                                      .emailBodyController.text,
                                                  style:
                                                      FontManager.body2Median(
                                                          ProtonColors
                                                              .textNorm)),
                                            GestureDetector(
                                                onTap: () {
                                                  viewModel.editEmailBody();
                                                },
                                                child: Text(
                                                    S
                                                        .of(context)
                                                        .message_to_recipient_optional,
                                                    style:
                                                        FontManager.body2Median(
                                                            ProtonColors
                                                                .protonBlue))),
                                          ],
                                        )
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
                                      myFocusNode: viewModel.emailBodyFocusNode,
                                      paddingSize: 7,
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
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (viewModel.memoTextController
                                                .text.isNotEmpty)
                                              Text(
                                                  viewModel
                                                      .memoTextController.text,
                                                  style:
                                                      FontManager.body2Median(
                                                          ProtonColors
                                                              .textNorm)),
                                            GestureDetector(
                                                onTap: () {
                                                  viewModel.editMemo();
                                                },
                                                child: Text(
                                                    S
                                                        .of(context)
                                                        .message_to_myself,
                                                    style:
                                                        FontManager.body2Median(
                                                            ProtonColors
                                                                .protonBlue))),
                                          ],
                                        )
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
                                      validation: (String value) {
                                        return "";
                                      },
                                    ),
                                  ),
                            const SizedBox(height: 10),
                            // Padding(
                            //     padding: const EdgeInsets.symmetric(
                            //         horizontal: defaultPadding),
                            //     child: Column(children: [
                            //       ExpansionTile(
                            //           shape: const Border(),
                            //           tilePadding: const EdgeInsets.all(0),
                            //           initiallyExpanded: false,
                            //           title: Text(S.of(context).advanced_options,
                            //               style: FontManager.captionMedian(
                            //                   ProtonColors.textNorm)),
                            //           iconColor: ProtonColors.textHint,
                            //           collapsedIconColor: ProtonColors.textHint,
                            //           children: [
                            //             const SizedBox(height: 10),
                            //             SizedBox(
                            //               width: MediaQuery.of(context).size.width,
                            //               child: Row(
                            //                   mainAxisAlignment:
                            //                       MainAxisAlignment.spaceBetween,
                            //                   children: [
                            //                     Text(
                            //                       S.of(context).fees_default,
                            //                       style: FontManager.captionMedian(
                            //                           ProtonColors.textNorm),
                            //                     ),
                            //                     GestureDetector(
                            //                         onTap: () {
                            //                           showSelectTransactionFeeMode(
                            //                               context, viewModel);
                            //                         },
                            //                         child:
                            //                             getTransactionFeeModeWidget(
                            //                                 context, viewModel)),
                            //                   ]),
                            //             ),
                            //             const SizedBox(height: 10),
                            //           ])
                            //     ])),
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
    double amount = 0.0;
    try {
      amount = double.parse(viewModel.amountTextController.text);
    } catch (e) {
      amount = 0.0;
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Text(S.of(context).you_are_sending,
          style: FontManager.titleSubHeadline(ProtonColors.textHint)),
      Text(
          "${Provider.of<UserSettingProvider>(context).getFiatCurrencySign()}${viewModel.amountTextController.text}",
          style: FontManager.sendAmount(ProtonColors.textNorm)),
      Text(
          Provider.of<UserSettingProvider>(context)
              .getBitcoinUnitLabel(viewModel.sendAmountInSAT),
          style: FontManager.body2Regular(ProtonColors.textNorm)),
    ]);
  }

  Widget getTransactionTotalValueWidget(
      BuildContext context, SendViewModel viewModel, int estimatedFee) {
    double amount = 0.0;
    try {
      amount = double.parse(viewModel.amountTextController.text);
    } catch (e) {
      amount = 0.0;
    }
    double esitmateValue =
        Provider.of<UserSettingProvider>(context).getNotionalInBTC(amount);
    int validCount = 0;
    for (String recipent in viewModel.recipents) {
      if (viewModel.bitcoinAddresses.containsKey(recipent) &&
          viewModel.bitcoinAddresses[recipent]! != "") {
        validCount++;
      }
    }
    amount *= validCount;
    esitmateValue *= validCount;
    double estimatedFeeInNotional = Provider.of<UserSettingProvider>(context)
        .getNotionalInFiatCurrency(estimatedFee);
    return TransactionHistoryItem(
      title: S.of(context).trans_total,
      content:
          "${Provider.of<UserSettingProvider>(context).getFiatCurrencySign()}${(estimatedFeeInNotional + amount).toStringAsFixed(3)}",
      memo: Provider.of<UserSettingProvider>(context).getBitcoinUnitLabel(
          (esitmateValue * 100000000).ceil() + estimatedFee),
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
                                    if (viewModel.balance > 0) {
                                      viewModel.addRecipient();
                                    } else {
                                      LocalToast.showErrorToast(
                                          context,
                                          S
                                              .of(context)
                                              .error_you_dont_have_sufficient_balance);
                                    }
                                  }),
                              const SizedBox(height: 5),
                            ]),
                            if (viewModel.recipents.isNotEmpty)
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
                                index < viewModel.recipents.length;
                                index++)
                              RecipientDetail(
                                name: viewModel.recipents[index],
                                email: viewModel.recipents[index],
                                bitcoinAddress: viewModel.bitcoinAddresses
                                        .containsKey(viewModel.recipents[index])
                                    ? viewModel.bitcoinAddresses[
                                            viewModel.recipents[index]] ??
                                        ""
                                    : "",
                                callback: () {
                                  viewModel.removeRecipient(index);
                                },
                              ),
                            const SizedBox(height: 20),
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
                                      .map((v) => FiatCurrencyHelper.getText(v))
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
                  enable: viewModel.validRecipientCount > 0,
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
        return Container(
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 5,
                  ),
                  ListTile(
                    leading: const Icon(Icons.keyboard_double_arrow_up_rounded,
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
                    onTap: () {
                      viewModel.updateTransactionFeeMode(
                          TransactionFeeMode.highPriority);
                      Navigator.of(context).pop();
                    },
                  ),
                  const Divider(
                    thickness: 0.2,
                    height: 1,
                  ),
                  ListTile(
                    leading:
                        const Icon(Icons.horizontal_rule_rounded, size: 18),
                    title: getEstimatedFeeInfo(
                        context, viewModel, TransactionFeeMode.medianPriority),
                    trailing: viewModel.userTransactionFeeMode ==
                            TransactionFeeMode.medianPriority
                        ? SvgPicture.asset(
                            "assets/images/icon/ic-checkmark.svg",
                            fit: BoxFit.fill,
                            width: 20,
                            height: 20)
                        : null,
                    onTap: () {
                      viewModel.updateTransactionFeeMode(
                          TransactionFeeMode.medianPriority);
                      Navigator.of(context).pop();
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
                    onTap: () {
                      viewModel.updateTransactionFeeMode(
                          TransactionFeeMode.lowPriority);
                      Navigator.of(context).pop();
                    },
                  ),
                ]));
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
      "${Provider.of<UserSettingProvider>(context).getFiatCurrencySign()}${Provider.of<UserSettingProvider>(context).getNotionalInFiatCurrency(estimatedFee).toStringAsFixed(3)}";
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
          return SingleChildScrollView(
              child: Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset("assets/images/icon/no_wallet_found.svg",
                          fit: BoxFit.fill, width: 86, height: 87),
                      const SizedBox(height: 10),
                      Text(S.of(context).placeholder,
                          style:
                              FontManager.body1Median(ProtonColors.textNorm)),
                      const SizedBox(height: 5),
                      Text(S.of(context).placeholder,
                          style:
                              FontManager.body2Regular(ProtonColors.textWeak)),
                      const SizedBox(height: 20),
                      ButtonV5(
                        text: S.of(context).ok,
                        width: MediaQuery.of(context).size.width,
                        backgroundColor: ProtonColors.protonBlue,
                        textStyle: FontManager.body1Median(ProtonColors.white),
                        height: 48,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      const SizedBox(height: 10),
                    ],
                  )));
        });
      });
}
