import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/components/dropdown.button.v1.dart';
import 'package:wallet/components/tag.text.dart';
import 'package:wallet/components/text.choices.dart';
import 'package:wallet/components/textfield.autocomplete.dart';
import 'package:wallet/components/textfield.big.text.dart';
import 'package:wallet/components/textfield.text.dart';
import 'package:wallet/components/transaction.fee.box.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/fiat.currency.helper.dart';
import 'package:wallet/helper/local_toast.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/send/send.viewmodel.dart';
import 'package:flutter_gen/gen_l10n/locale.dart';
import 'package:wallet/theme/theme.font.dart';

class SendView extends ViewBase<SendViewModel> {
  SendView(SendViewModel viewModel) : super(viewModel, const Key("SendView"));

  @override
  Widget buildWithViewModel(
      BuildContext context, SendViewModel viewModel, ViewSize viewSize) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
          statusBarBrightness: Brightness.light, // For iOS (dark icons)
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text(S.of(context).send_bitcoin,
            style: FontManager.titleHeadline(
                Theme.of(context).colorScheme.primary)),
        centerTitle: true,
        scrolledUnderElevation:
            0.0, // don't change background color when scroll down
      ),
      body: buildContent(context, viewModel, viewSize),
    );
  }

  Widget buildContent(
      BuildContext context, SendViewModel viewModel, ViewSize viewSize) {
    return Stack(children: [
      ListView(scrollDirection: Axis.vertical, children: [
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26),
            child: Center(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                  const SizedBox(height: 40),
                  TextFieldBigText(
                    width:
                        MediaQuery.of(context).size.width - defaultPadding * 2,
                    height: 140,
                    controller: viewModel.amountTextController,
                    digitOnly: true,
                    hintText: "0",
                  ),
                  const SizedBox(height: 10),
                  Text(
                    S.of(context).current_balance_usd(
                        viewModel.fiatCurrencyAmount),
                    style: FontManager.captionMedian(ProtonColors.textHint),
                  ),
                  const SizedBox(height: 10),
                  TextChoices(
                      choices: const ["BTC", "SATS", "USD"],
                      selectedValue: viewModel.coinController.text,
                      controller: viewModel.coinController),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(S.of(context).available_funds),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            S.of(context).current_balance_btc(
                                viewModel.balance / 100000000),
                            style: FontManager.captionMedian(
                                ProtonColors.textHint),
                          ),
                          Text(
                            S.of(context).current_balance_usd(
                                viewModel.getFiatCurrencyValue(
                                    satsAmount: viewModel.balance.toDouble())),
                            style: FontManager.captionMedian(
                                ProtonColors.textHint),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: defaultPadding),
                      child: Text("Transaction Fees",
                          style: FontManager.body1Median(
                              Theme.of(context).colorScheme.primary))),
                  const SizedBox(height: 10),
                  Container(
                      width: MediaQuery.of(context).size.width,
                      height: 110,
                      child: ListView(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          children: [
                            TransactionFeeBox(
                              priorityText: "High Priority",
                              timeEstimate: "In ~10 minutes",
                              fee: viewModel.bitcoinTransactionFee.block1Fee,
                            ),
                            const SizedBox(width: 10),
                            TransactionFeeBox(
                              priorityText: "Median Priority",
                              timeEstimate: "In ~30 minutes",
                              fee: viewModel.bitcoinTransactionFee.block3Fee,
                            ),
                            const SizedBox(width: 10),
                            TransactionFeeBox(
                              priorityText: "Low Priority",
                              timeEstimate: "In ~50 minutes",
                              fee: viewModel.bitcoinTransactionFee.block5Fee,
                            ),
                            const SizedBox(width: 10),
                            TransactionFeeBox(
                              priorityText: "No Priority",
                              timeEstimate: "In ~3.5 hours",
                              fee: viewModel.bitcoinTransactionFee.block20Fee,
                            ),
                          ])),
                  const SizedBox(height: 30),
                  ButtonV5(
                      onPressed: () {
                        viewModel.sendCoin();
                        viewModel.coordinator.end();
                        Navigator.of(context).pop();
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
