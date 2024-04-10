import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/components/protonmail.autocomplete.dart';
import 'package:wallet/components/tag.text.dart';
import 'package:wallet/components/textfield.send.btc.dart';
import 'package:wallet/components/textfield.text.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/local_toast.dart';
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
      backgroundColor: ProtonColors.backgroundProton,
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
          statusBarBrightness: Brightness.light, // For iOS (dark icons)
        ),
        backgroundColor: ProtonColors.backgroundProton,
        title: Text(
            viewModel.inReview
                ? "Review your transaction"
                : S.of(context).send_bitcoin,
            style: FontManager.titleSubHeadline(ProtonColors.textNorm)),
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
    return ListView(scrollDirection: Axis.vertical, children: [
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            const SizedBox(height: 40),
            getTransactionValueWidget(context, viewModel),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(S.of(context).trans_to,
                    style: FontManager.body2Regular(ProtonColors.textNorm)),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  for (TextEditingController textEditingController
                      in viewModel.recipientTextControllers)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      child: Column(children: [
                        TagText(
                            text: textEditingController.text,
                            textColor: ProtonColors.textNorm,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            hint: viewModel.bitcoinAddresses
                                    .containsKey(textEditingController.text)
                                ? viewModel.bitcoinAddresses[
                                    textEditingController.text]!
                                : null),
                      ]),
                    ),
                ]),
              ],
            ),
            const Divider(thickness: 1),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("Network Fee",
                  style: FontManager.body2Regular(ProtonColors.textNorm)),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                getTransactionFeeModeWidget(context, viewModel),
                const SizedBox(
                  height: 5,
                ),
                Text("0.00 USD",
                    style: FontManager.body2Regular(ProtonColors.textNorm)),
                Text("0.00000000 BTC",
                    style: FontManager.overlineRegular(ProtonColors.textNorm)),
              ]),
            ]),
            const Divider(thickness: 1),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("Total",
                    style: FontManager.body2Regular(ProtonColors.textNorm)),
                Text("Amount + Fee",
                    style: FontManager.overlineRegular(ProtonColors.textNorm)),
              ]),
              getTransactionTotalValueWidget(context, viewModel),
            ]),
            const SizedBox(height: 80),
            ButtonV5(
                onPressed: () {
                  // TODO:: Send bitcoin with Esplora client
                  viewModel.sendCoin();
                  viewModel.coordinator.end();
                  Navigator.of(context).pop();
                },
                text: S.of(context).submit,
                width: MediaQuery.of(context).size.width,
                textStyle: FontManager.body1Median(ProtonColors.white),
                height: 48),
            const SizedBox(height: 20),
          ]))
    ]);
  }

  Widget getTransactionValueWidget(
      BuildContext context, SendViewModel viewModel) {
    bool isBitcoinBase = viewModel.isBitcoinBaseValueNotifier.value;
    double amount = 0.0;
    try {
      amount = double.parse(viewModel.amountTextController.text);
    } catch (e) {
      amount = 0.0;
    }
    int currencyExchangeRate = viewModel.fiatCurrency2exchangeRate.isNotEmpty
        ? viewModel.fiatCurrency2exchangeRate[viewModel.userFiatCurrency]!
        : 1;
    double esitmateValue = CommonHelper.getEstimateValue(
        amount: amount,
        isBitcoinBase: isBitcoinBase,
        currencyExchangeRate: currencyExchangeRate);
    if (isBitcoinBase) {
      return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Text(
            "${esitmateValue.toStringAsFixed(3)} ${viewModel.userFiatCurrency.name.toUpperCase()}",
            style: FontManager.sendAmount(ProtonColors.textNorm)),
        Text("${viewModel.amountTextController.text} BTC",
            style: FontManager.body2Regular(ProtonColors.textNorm)),
      ]);
    } else {
      return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Text(
            "${viewModel.amountTextController.text} ${viewModel.userFiatCurrency.name.toUpperCase()}",
            style: FontManager.sendAmount(ProtonColors.textNorm)),
        Text("${esitmateValue.toStringAsFixed(8)} BTC",
            style: FontManager.body2Regular(ProtonColors.textNorm)),
      ]);
    }
  }

  Widget getTransactionTotalValueWidget(
      BuildContext context, SendViewModel viewModel) {
    bool isBitcoinBase = viewModel.isBitcoinBaseValueNotifier.value;
    double amount = 0.0;
    try {
      amount = double.parse(viewModel.amountTextController.text);
    } catch (e) {
      amount = 0.0;
    }
    int currencyExchangeRate = viewModel.fiatCurrency2exchangeRate.isNotEmpty
        ? viewModel.fiatCurrency2exchangeRate[viewModel.userFiatCurrency]!
        : 1;
    double esitmateValue = CommonHelper.getEstimateValue(
        amount: amount,
        isBitcoinBase: isBitcoinBase,
        currencyExchangeRate: currencyExchangeRate);
    if (isBitcoinBase) {
      return Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(
            "${esitmateValue.toStringAsFixed(3)} ${viewModel.userFiatCurrency.name.toUpperCase()}",
            style: FontManager.body2Regular(ProtonColors.textNorm)),
        Text("${viewModel.amountTextController.text} BTC",
            style: FontManager.overlineRegular(ProtonColors.textNorm)),
      ]);
    } else {
      return Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(
            "${viewModel.amountTextController.text} ${viewModel.userFiatCurrency.name.toUpperCase()}",
            style: FontManager.body2Regular(ProtonColors.textNorm)),
        Text("${esitmateValue.toStringAsFixed(8)} BTC",
            style: FontManager.overlineRegular(ProtonColors.textNorm)),
      ]);
    }
  }

  Widget buildContent(
      BuildContext context, SendViewModel viewModel, ViewSize viewSize) {
    return Stack(children: [
      ListView(scrollDirection: Axis.vertical, children: [
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
            child: Center(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                  const SizedBox(height: 20),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      S.of(context).send_to_recipient_s,
                      style: FontManager.captionMedian(ProtonColors.textNorm),
                    ),
                  ),
                  const SizedBox(height: 5),
                  for (int index = 0;
                      index < viewModel.recipientTextControllers.length;
                      index++)
                    Column(children: [
                      ProtonMailAutoComplete(
                          emails: viewModel.contactsEmail,
                          color: ProtonColors.backgroundSecondary,
                          focusNode: FocusNode(),
                          textEditingController:
                              viewModel.recipientTextControllers[index],
                          callback: index > 0
                              ? () {
                                  viewModel.removeRecipient(index);
                                }
                              : null),
                      const SizedBox(height: 5),
                    ]),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: GestureDetector(
                        onTap: () {
                          if (viewModel.recipientTextControllers.length <
                              viewModel.maxRecipientCount) {
                            viewModel.addRecipient();
                          } else {
                            LocalToast.showToast(context,
                                "Maximum ${viewModel.maxRecipientCount} recipients",
                                icon: null);
                          }
                        },
                        child: Text(
                          S.of(context).add_recipient,
                          style: FontManager.captionMedian(
                              ProtonColors.interactionNorm),
                        )),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      S.of(context).amount,
                      style: FontManager.captionMedian(ProtonColors.textNorm),
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextFieldSendBTC(
                    width: double.infinity,
                    height: 50,
                    color: ProtonColors.backgroundSecondary,
                    controller: viewModel.amountTextController,
                    isBitcoinBaseValueNotifier:
                        viewModel.isBitcoinBaseValueNotifier,
                    currency: viewModel.userFiatCurrency,
                    currencyExchangeRate:
                        viewModel.fiatCurrency2exchangeRate.isNotEmpty
                            ? viewModel.fiatCurrency2exchangeRate[
                                viewModel.userFiatCurrency]!
                            : 1,
                    btcBalance: 1,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      S.of(context).message_to_recipient_optional,
                      style: FontManager.captionMedian(ProtonColors.textNorm),
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextFieldText(
                    width: MediaQuery.of(context).size.width,
                    height: 100,
                    multiLine: true,
                    color: ProtonColors.backgroundSecondary,
                    showSuffixIcon: false,
                    showEnabledBorder: false,
                    controller: viewModel.memoTextController,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            S.of(context).fees_default,
                            style: FontManager.captionSemiBold(
                                ProtonColors.textNorm),
                          ),
                          GestureDetector(
                              onTap: () {
                                showSelectTransactionFeeMode(
                                    context, viewModel);
                              },
                              child: getTransactionFeeModeWidget(
                                  context, viewModel)),
                        ]),
                  ),
                  const SizedBox(height: 80),
                  ButtonV5(
                      onPressed: () {
                        viewModel.updatePageStatus(inReview: true);
                      },
                      text: S.of(context).review_transaction,
                      width: MediaQuery.of(context).size.width,
                      textStyle: FontManager.body1Median(ProtonColors.white),
                      height: 48),
                  const SizedBox(height: 20),
                ])))
      ])
    ]);
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
            padding: const EdgeInsets.symmetric(vertical: 16),
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
                    title: Text("High Priority",
                        style: FontManager.body2Regular(ProtonColors.textNorm)),
                    onTap: () {
                      viewModel.updateTransactionFeeMode(
                          TransactionFeeMode.highPriority);
                    },
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  ListTile(
                    leading:
                        const Icon(Icons.horizontal_rule_rounded, size: 18),
                    title: Text("Median Priority",
                        style: FontManager.body2Regular(ProtonColors.textNorm)),
                    onTap: () {
                      viewModel.updateTransactionFeeMode(
                          TransactionFeeMode.medianPriority);
                    },
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  ListTile(
                    leading: const Icon(
                        Icons.keyboard_double_arrow_down_rounded,
                        size: 18),
                    title: Text("Low Priority",
                        style: FontManager.body2Regular(ProtonColors.textNorm)),
                    onTap: () {
                      viewModel.updateTransactionFeeMode(
                          TransactionFeeMode.lowPriority);
                    },
                  ),
                ]));
      });
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
